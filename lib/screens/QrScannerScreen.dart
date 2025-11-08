import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/Constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class QrScannerScreen extends StatefulWidget {
  final int employeeId;
  final String scanType; // checkin or checkout

  const QrScannerScreen({
    Key? key,
    required this.employeeId,
    required this.scanType,
  }) : super(key: key);

  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  final storage = const FlutterSecureStorage();

  bool isScanning = true;

  Future<void> _handleQrScan(String qrData) async {
    if (!isScanning) return;

    setState(() {
      isScanning = false;
    });

    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token not found")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('${Constants.BASE_URL}${Constants.SCAN_QR_ROUTE}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'employee_id': widget.employeeId,
          'type': widget.scanType,
          // 'qr_data': qrData,
        }),
      );

      print('Attendance Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Attendance marked!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}')),
        );
        setState(() => isScanning = true);
      }
    } catch (e) {
      print('Error marking attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => isScanning = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Scanner (${widget.scanType})')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? qrData = barcodes.first.rawValue;
                if (qrData != null) {
                  _handleQrScan(qrData);
                }
              }
            },
          ),
          if (!isScanning)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
