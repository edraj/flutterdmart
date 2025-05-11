import 'package:dmart/dmart.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    // test('Check dio init', () async {
    //   const baseUrl = 'https://dmart.cc/dmart';
    //   Dmart.dmartServerUrl = baseUrl;
    //   Dmart.initDmart();
    //   expect(true, true);
    // });
    //
    // test('Test login', () async {
    //   const baseUrl = 'https://dmart.cc/dmart';
    //   Dmart.dmartServerUrl = baseUrl;
    //   Dmart.initDmart();
    //   final response = await Dmart.login(
    //     LoginRequest(shortname: 'test', password: 'test'),
    //   );
    //   print(response);
    //   expect(response, isNotNull);
    // });

    test('Test get payload', () async {
      const baseUrl = 'https://dmart.cc/dmart';
      Dmart.dmartServerUrl = baseUrl;
      Dmart.initDmart();
      final _ = await Dmart.login(
        LoginRequest(shortname: 'dmart', password: 'TestTest1234'),
      );
      var (x, y) = await Dmart.getProfile();
      print(x?.records![0].attributes.language);

      (x, y) = await Dmart.updateProfile(
        ActionRequestRecord(
          shortname: 'dmart',
          resourceType: ResourceType.user,
          subpath: 'users',
          attributes: {'language': 'kurdish'},
        ),
      );

      print(y?.info);

      // final (response, error) = await Dmart.query(
      //   QueryRequest(
      //     queryType: QueryType.search,
      //     spaceName: 'management',
      //     subpath: 'users',
      //     filterTypes: [ResourceType.comment],
      //   ),
      //   scope: 'public',
      // );
      // print(response!.toJson());
      // expect(response, isNotNull);
    });
  });
}
