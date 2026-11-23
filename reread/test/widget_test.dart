import 'package:flutter_test/flutter_test.dart';
import 'package:reread/services/account_validation.dart';

void main() {
  group('marketplace account validation', () {
    test('accepts valid email addresses and rejects malformed addresses', () {
      expect(AccountValidation.validateEmail('reader@example.co.id'), isNull);
      expect(AccountValidation.validateEmail('not-an-email'), isNotNull);
    });

    test('requires a usable marketplace password', () {
      expect(AccountValidation.validateNewPassword('BukuBagus123'), isNull);
      expect(AccountValidation.validateNewPassword('short7'), isNotNull);
      expect(AccountValidation.validateNewPassword('onlyletters'), isNotNull);
    });

    test('validates regular account name and Indonesian phone number', () {
      expect(AccountValidation.validateFullName('Rina Kusuma'), isNull);
      expect(AccountValidation.validateFullName('Li'), isNull);
      expect(AccountValidation.validateFullName('R'), isNotNull);
      expect(AccountValidation.validatePhone('+62 812-3456-7890'), isNull);
      expect(AccountValidation.validatePhone('12345'), isNotNull);
    });
  });
}
