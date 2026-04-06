import 'package:dmart/dmart.dart';
import 'package:test/test.dart';

void main() {
  group('Dmart client', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('login, profile, and updateProfile succeed', () async {
      const baseUrl = 'https://dmart.cc/dmart';
      Dmart.dmartServerUrl = baseUrl;
      await Dmart.init();

      final loginResponse = await Dmart.login(
        LoginRequest(
          shortname: const String.fromEnvironment(
            'DMART_USER',
            defaultValue: 'dmart',
          ),
          password: const String.fromEnvironment(
            'DMART_PASS',
            defaultValue: '',
          ),
        ),
      );
      expect(loginResponse.token, isNotNull);

      final profile = await Dmart.getProfile();
      expect(profile.records, isNotEmpty);

      await Dmart.updateProfile(
        ActionRequestRecord(
          shortname: const String.fromEnvironment(
            'DMART_USER',
            defaultValue: 'dmart',
          ),
          resourceType: ResourceType.user,
          subpath: 'users',
          attributes: {'language': 'kurdish'},
        ),
      );
    });

    test('throws DmartApiException on bad credentials', () async {
      const baseUrl = 'https://dmart.cc/dmart';
      Dmart.dmartServerUrl = baseUrl;
      await Dmart.init();

      expect(
        () => Dmart.login(LoginRequest(shortname: 'nobody', password: 'wrong')),
        throwsA(isA<DmartApiException>()),
      );
    });

    test('throws DmartException when not initialized', () {
      expect(() => Dmart.getProfile(), throwsA(isA<DmartException>()));
    });
  });
}
