import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  File? _avatarFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Ở đây bạn có thể tách họ / tên theo ý.
    final fullName = user.displayName ?? '';
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      _lastNameController.text = parts.last;
      _firstNameController.text =
          parts.sublist(0, parts.length - 1).join(' ');
    } else {
      _firstNameController.text = fullName;
    }

    _phoneController.text = user.phoneNumber ?? '';
    // _addressController: nếu bạn lưu ở Firestore có thể load thêm.
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    String? photoUrl = user.photoURL;

    // Upload avatar nếu người dùng chọn ảnh mới
    if (_avatarFile != null) {
      try {
        final ref = _storage
            .ref()
            .child('avatars')
            .child('${user.uid}.jpg');

        await ref.putFile(_avatarFile!);
        photoUrl = await ref.getDownloadURL();
        await user.updatePhotoURL(photoUrl);
      } catch (e) {
        debugPrint('Upload avatar error: $e');
      }
    }

    // Cập nhật tên hiển thị (displayName)
    final fullName =
    '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
        .trim();
    if (fullName.isNotEmpty) {
      await user.updateDisplayName(fullName);
    }

    // Nếu bạn có collection "users" trong Firestore,
    // có thể lưu thêm phone & address ở đây.

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
    );

    Navigator.pop(context);
  }

  Widget _buildTextField(
      String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.person_outline),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null),
                      child: (_avatarFile == null &&
                          (user?.photoURL == null))
                          ? const Icon(Icons.camera_alt,
                          size: 30, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chạm để đổi ảnh đại diện',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            _buildTextField('Họ', _firstNameController),
            const SizedBox(height: 12),

            _buildTextField('Tên', _lastNameController),
            const SizedBox(height: 12),

            _buildTextField(
              'Số điện thoại',
              _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            _buildTextField('Địa chỉ', _addressController),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text(
                  'Lưu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
