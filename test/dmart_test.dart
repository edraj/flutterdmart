import 'package:dmart/dmart.dart';
import 'package:dmart/src/models/login_model.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Check dio init', () async {
      const baseUrl = 'https://dmart.cc/dmart';
      Dmart.dmartServerUrl = baseUrl;
      Dmart.initDmart();
      expect(true, true);
    });

    test('Test login', () async {
      const baseUrl = 'https://dmart.cc/dmart';
      Dmart.dmartServerUrl = baseUrl;
      Dmart.initDmart();
      final response = await Dmart.login(LoginRequest(
        shortname: 'test',
        password: 'test',
      ));
      print(response);
      expect(response, isNotNull);
    });
  });
}
