import 'package:flutter/material.dart';

class CustomBiometricDialog extends StatelessWidget {
  final String title;
  final String description;
  final Widget icon;
  final VoidCallback onAuthenticate;
  final VoidCallback onCancel;

  const CustomBiometricDialog({
    super.key,
    this.title = 'Biometric Security',
    this.description = 'Please authenticate to proceed with the action.',
    this.icon = const Icon(Icons.fingerprint, size: 64, color: Colors.blue),
    required this.onAuthenticate,
    required this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Biometric Security',
    String description = 'Please authenticate to proceed.',
    Widget? icon,
    required Future<bool> Function() authenticateAction,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomBiometricDialog(
        title: title,
        description: description,
        icon: icon ?? const Icon(Icons.security, size: 64, color: Colors.blue),
        onCancel: () => Navigator.of(context).pop(false),
        onAuthenticate: () async {
          final success = await authenticateAction();
          if (context.mounted) {
            Navigator.of(context).pop(success);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: onAuthenticate,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('AUTHENTICATE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
