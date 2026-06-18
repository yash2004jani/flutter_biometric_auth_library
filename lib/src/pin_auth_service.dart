import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class PinStorage {
  Future<void> savePin(String pin);
  Future<String?> getPin();
  Future<void> deletePin();
}

class SecurePinStorage implements PinStorage {
  final _storage = const FlutterSecureStorage();
  static const _pinKey = 'biometric_auth_library_pin';

  @override
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  @override
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  @override
  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }
}

class PinAuthService {
  final PinStorage _storage;

  PinAuthService({PinStorage? storage})
      : _storage = storage ?? SecurePinStorage();

  Future<bool> isPinSet() async {
    final pin = await _storage.getPin();
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    await _storage.savePin(pin);
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.getPin();
    return storedPin == pin;
  }

  Future<void> clearPin() async {
    await _storage.deletePin();
  }
}
