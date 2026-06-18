import 'package:flutter/material.dart';
import 'package:flutter_biometric_auth_library/flutter_biometric_auth_library.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biometric Auth Library',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _authManager = BiometricAuthManager();
  final _pinService = PinAuthService();
  String _status = 'Ready';

  Future<void> _setupPin() async {
    await _pinService.setPin('1234');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN set to 1234')),
      );
    }
  }

  Future<void> _handleAuth(AuthResult result) async {
    setState(() {
      switch (result) {
        case AuthResult.success:
          _status = 'Success!';
          break;
        case AuthResult.failure:
          _status = 'Auth Failed';
          break;
        case AuthResult.canceled:
          _status = 'Auth Canceled';
          break;
        case AuthResult.pinFallback:
          _status = 'Authenticated via PIN';
          break;
      }
    });
  }

  Future<void> _authWithFingerprint() async {
    final result = await _authManager.authenticate(
      context,
      localizedReason: 'Scan your fingerprint to unlock',
      forceFingerprint: true,
    );
    _handleAuth(result);
  }

  Future<void> _authWithFace() async {
    final result = await _authManager.authenticate(
      context,
      localizedReason: 'Look at the camera to unlock',
      forceFace: true,
    );
    _handleAuth(result);
  }

  Future<void> _authWithPin() async {
    if (!await _pinService.isPinSet()) {
      setState(() => _status = 'Please set PIN first');
      return;
    }
    final result = await _authManager.authenticate(
      context,
      localizedReason: 'Fallback to PIN',
      usePinFallback: true,
    );
    _handleAuth(result);
  }

  Future<void> _showCustomDialog() async {
    final success = await CustomBiometricDialog.show(
      context,
      title: 'Access Secure Vault',
      description: 'Your biometric data is required to access the secure vault.',
      icon: const Icon(Icons.lock_person, size: 64, color: Colors.indigo),
      authenticateAction: () async {
        final res = await _authManager.authenticate(
          context,
          localizedReason: 'Vault Access',
        );
        return res == AuthResult.success;
      },
    );

    if (success == true) {
      setState(() => _status = 'Vault Unlocked!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Library'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 32),
              const Text('1. CONFIGURATION', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const Divider(),
              ElevatedButton.icon(
                onPressed: _setupPin,
                icon: const Icon(Icons.pin),
                label: const Text('Setup Fallback PIN (1234)'),
              ),
              const SizedBox(height: 32),
              const Text('2. AUTH CATEGORIES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const Divider(),
              _buildAuthButton(
                icon: Icons.fingerprint,
                label: 'Fingerprint Unlock',
                onPressed: _authWithFingerprint,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildAuthButton(
                icon: Icons.face,
                label: 'Face Unlock',
                onPressed: _authWithFace,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildAuthButton(
                icon: Icons.keyboard_alt_outlined,
                label: 'Fallback PIN UI',
                onPressed: _authWithPin,
                color: Colors.orange,
              ),
              const SizedBox(height: 32),
              const Text('3. CUSTOM UI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const Divider(),
              OutlinedButton.icon(
                onPressed: _showCustomDialog,
                icon: const Icon(Icons.dashboard_customize),
                label: const Text('Custom Biometric Dialog'),
              ),
              const SizedBox(height: 20),
              const Text('Custom Wrapper (Tap Icon):', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              BiometricAuthWrapper(
                localizedReason: 'Unlock Wrapper',
                useFaceIcon: true,
                onAuthenticated: () => setState(() => _status = 'Wrapper Success!'),
                biometricIndicator: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.face, size: 48, color: Colors.indigo),
                  ),
                ),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Secured Area Content (Face Icon)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('AUTHENTICATION STATUS'),
            const SizedBox(height: 8),
            Text(
              _status,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _status.contains('Success') ? Colors.green : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
