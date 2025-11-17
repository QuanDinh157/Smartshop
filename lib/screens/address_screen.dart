import 'package:flutter/material.dart';

// --- BIẾN TOÀN CỤC LƯU ĐỊA CHỈ ---
List<Map<String, String>> globalAddresses = [
  {
    'name': 'SmartShop Store',
    'phone': '+84 786 324 07',
    'address': '69/89 Đặng Thùy Trâm, Bình Lợi',
    'city': 'Trung, HCM'
  }
];

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});
  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Địa chỉ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: globalAddresses.length,
                itemBuilder: (context, index) {
                  final item = globalAddresses[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item['address']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('${item['city']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('${item['phone']}', style: const TextStyle(color: Colors.grey)),
                              Text('${item['name']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              // Logic Xóa (Demo)
                              setState(() {
                                globalAddresses.removeAt(index);
                              });
                            },
                            child: const Text('Xóa', style: TextStyle(color: Colors.red)))
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
                if (result == true) {
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0857A0),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Thêm địa chỉ mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}


class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Thêm Địa chỉ mới', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput('Tên', Icons.person_outline, _nameController),
            const SizedBox(height: 16),
            _buildInput('Số Điện Thoại', Icons.phone_android, _phoneController),
            const SizedBox(height: 16),
            _buildInput('Đường/Số nhà', Icons.location_on_outlined, _addressController),
            const SizedBox(height: 16),
            _buildInput('Thành Phố/Tỉnh', Icons.location_city, _cityController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Lưu vào biến toàn cục
                globalAddresses.add({
                  'name': _nameController.text,
                  'phone': _phoneController.text,
                  'address': _addressController.text,
                  'city': _cityController.text,
                });
                Navigator.pop(context, true); // Trả về true để màn hình trước load lại
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0857A0),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}