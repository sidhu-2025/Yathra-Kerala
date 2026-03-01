import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRViewScreen extends StatelessWidget {
  final String token;

  const QRViewScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Show this QR at the Gate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: token,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            Text('Token: $token', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
