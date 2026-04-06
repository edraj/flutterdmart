import 'package:dmart/dmart.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Test get payload', () async {
      const baseUrl = 'https://dmart.cc/dmart';
      Dmart.dmartServerUrl = baseUrl;
      await Dmart.initDmart();
      final (loginResponse, loginError) = await Dmart.login(
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
      expect(loginError, isNull);
      expect(loginResponse, isNotNull);

      var (profile, profileError) = await Dmart.getProfile();
      expect(profileError, isNull);
      expect(profile, isNotNull);
      expect(profile?.records, isNotEmpty);

      final (updated, updateError) = await Dmart.updateProfile(
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

      expect(updateError, isNull);
      expect(updated, isTrue);
    });
  });
}
