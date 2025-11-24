import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Quan trọng: Để lưu địa chỉ, sđt
import 'package:image_picker/image_picker.dart'; // Quan trọng: Để chọn ảnh

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller cho các ô nhập liệu
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Khai báo Firebase
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  File? _avatarFile; // Biến chứa file ảnh đang chọn
  bool _isLoading = false; // Biến trạng thái xoay xoay

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Mở màn hình là tải dữ liệu ngay
  }

  // --- HÀM 1: TẢI DỮ LIỆU TỪ FIREBASE VỀ MÁY ---
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Tải tên từ Auth (cái có sẵn)
      _splitName(user.displayName ?? '');

      // 2. Tải SĐT, Địa chỉ từ Firestore (cái mình lưu thêm)
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _phoneController.text = data['phone'] ?? user.phoneNumber ?? '';
        _addressController.text = data['address'] ?? '';

        // Nếu trong Firestore có lưu tên riêng thì ưu tiên lấy
        if (data['firstName'] != null) _firstNameController.text = data['firstName'];
        if (data['lastName'] != null) _lastNameController.text = data['lastName'];
      }
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
    }

    setState(() => _isLoading = false);
  }

  // Hàm tách tên "Nguyen Van A" thành "Nguyen Van" và "A"
  void _splitName(String fullName) {
    if (fullName.isEmpty) return;
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      _lastNameController.text = parts.last;
      _firstNameController.text = parts.sublist(0, parts.length - 1).join(' ');
    } else {
      _firstNameController.text = fullName;
    }
  }

  // --- HÀM 2: CHỌN ẢNH TỪ THƯ VIỆN ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Nén ảnh lại cho nhẹ
    );
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  // --- HÀM 3: LƯU TẤT CẢ LÊN FIREBASE ---
  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? photoUrl = user.photoURL;

      // A. Nếu có chọn ảnh mới -> Upload lên Storage
      if (_avatarFile != null) {
        final ref = _storage.ref().child('avatars').child('${user.uid}.jpg');
        await ref.putFile(_avatarFile!);
        photoUrl = await ref.getDownloadURL(); // Lấy link ảnh về
      }

      // B. Cập nhật thông tin cơ bản (Auth)
      String fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
      if (fullName.isNotEmpty) {
        await user.updateDisplayName(fullName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // C. QUAN TRỌNG: Lưu SĐT, Địa chỉ vào Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'fullName': fullName,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge: true để giữ lại dữ liệu cũ nếu có

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Quay lại màn hình trước
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  // Widget ô nhập liệu cho gọn code
  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- PHẦN AVATAR ---
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _avatarFile != null
                        ? FileImage(_avatarFile!)
                        : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null) as ImageProvider?,
                    child: (_avatarFile == null && user?.photoURL == null)
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF0857A0), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text('Chạm để đổi ảnh đại diện', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),

            // --- CÁC Ô NHẬP LIỆU ---
            Row(
              children: [
                Expanded(child: _buildTextField('Họ', _firstNameController)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField('Tên', _lastNameController)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Số điện thoại', _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField('Địa chỉ giao hàng', _addressController),

            const SizedBox(height: 40),

            // --- NÚT LƯU ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0857A0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('LƯU THAY ĐỔI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}