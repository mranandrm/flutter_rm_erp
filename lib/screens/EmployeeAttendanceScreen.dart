import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../utils/Constants.dart';
import 'QrScannerScreen.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({Key? key}) : super(key: key);

  @override
  _EmployeeAttendanceScreenState createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  final storage = const FlutterSecureStorage();

  String? employeeName;
  String? employeeCode;
  int? employeeId;
  bool isLoading = true;
  String _scanType = 'checkin';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final token = await storage.read(key: 'token');

      if (token == null) {
        print('No token found');
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${Constants.BASE_URL}${Constants.USER_ROUTE}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Profile Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          employeeName = data['employee_name'] ?? 'N/A';
          employeeCode = data['employee_code'] ?? 'N/A';
          employeeId = data['employee_id'];
          isLoading = false;
        });
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Attendance')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Employee Name: ${employeeName ?? 'N/A'}',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Employee Code: ${employeeCode ?? 'N/A'}',
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Employee ID: ${employeeId ?? '-'}',
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Select Attendance Type:',
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            ListTile(
              title: const Text('Check-In'),
              leading: Radio<String>(
                value: 'checkin',
                groupValue: _scanType,
                onChanged: (value) {
                  setState(() {
                    _scanType = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Check-Out'),
              leading: Radio<String>(
                value: 'checkout',
                groupValue: _scanType,
                onChanged: (value) {
                  setState(() {
                    _scanType = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                if (employeeId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrScannerScreen(
                        employeeId: employeeId!,
                        scanType: _scanType,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Employee information not found.')),
                  );
                }
              },

            ),
          ],
        ),
      ),
    );
  }
}
