import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_biometric_auth_library/src/pin_auth_service.dart';

class MockPinStorage implements PinStorage {
  String? _pin;
  @override
  Future<void> deletePin() async => _pin = null;
  @override
  Future<String?> getPin() async => _pin;
  @override
  Future<void> savePin(String pin) async => _pin = pin;
}

void main() {
  late PinAuthService service;
  late MockPinStorage mockStorage;

  setUp(() {
    mockStorage = MockPinStorage();
    service = PinAuthService(storage: mockStorage);
  });

  test('isPinSet returns false when no pin', () async {
    expect(await service.isPinSet(), false);
  });

  test('isPinSet returns true when pin is set', () async {
    await service.setPin('1234');
    expect(await service.isPinSet(), true);
  });

  test('verifyPin returns true for correct pin', () async {
    await service.setPin('1234');
    expect(await service.verifyPin('1234'), true);
  });

  test('verifyPin returns false for incorrect pin', () async {
    await service.setPin('1234');
    expect(await service.verifyPin('5678'), false);
  });

  test('clearPin deletes pin', () async {
    await service.setPin('1234');
    await service.clearPin();
    expect(await service.isPinSet(), false);
  });
}
