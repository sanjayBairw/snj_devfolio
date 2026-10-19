import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';

/// Service to download and export the bundled resume from assets/document/SnjR_removed.pdf
class ResumeDownloadService {
  /// Saves the bundled resume PDF to the device's Downloads directory and notifies the user.
  static Future<void> downloadResume(BuildContext context) async {
    try {
      final byteData = await rootBundle.load(kResumeAssetPath);
      final bytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Resume ready: $kResumeFileName',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      // Android public Download directory
      final standardDownloadDir = Directory('/storage/emulated/0/Download');

      if (Platform.isAndroid && await standardDownloadDir.exists()) {
        final file = File('${standardDownloadDir.path}/$kResumeFileName');
        await file.writeAsBytes(bytes, flush: true);
      } else {
        // Desktop / iOS / Fallback
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/$kResumeFileName');
        await file.writeAsBytes(bytes, flush: true);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Saved to Downloads: $kResumeFileName',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('ResumeDownloadService error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save resume: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
