import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dmart/dmart.dart';

import 'consts.dart';

Future<void> main() async {
  // Dmart.dmartServerUrl = 'https://api.dmart.cc';
  // Dmart.initDmart();

  // option 1: with DmartConfig
  Dmart.init(
    configuration: DmartConfig(
      baseUrl: 'https://api.dmart.cc',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  // option 2: with Dio instance
  Dmart.init(
    dio: Dio(
      BaseOptions(
        baseUrl: 'https://api.dmart.cc',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    ),
  );

  // set token
  Dmart.setToken('your_token');

  // Creating a user
  final CreateUserAttributes createUserAttributes = CreateUserAttributes(
    displayname: Displayname(en: 'test'),
    invitation: 'ABC',
    password: '@Jimmy123_',
    roles: ['super_admin'],
  );
  CreateUserResponse responseCreateUser = await Dmart.createUser(
    CreateUserRequest(shortname: 'jimmy', attributes: createUserAttributes),
  );

  // User login
  LoginResponse responseLogin = await Dmart.login(LoginRequest(shortname: 'jimmy', password: '@Jimmy123_'));

  // Fetching user profile
  ProfileResponse responseProfile = await Dmart.getProfile();
  print(responseProfile.records?.first.shortname);

  // Get all spaces
  ActionResponse responseSpaces = await Dmart.getSpaces();
  print(responseSpaces.records?.length);

  // Create space
  ActionRequest createSpaceActionRequest = ActionRequest(
    spaceName: 'my_space',
    requestType: RequestType.create,
    records: [
      ActionRequestRecord(
        resourceType: ResourceType.space,
        shortname: 'my_space',
        subpath: '/',
        attributes: {
          'displayname': {'en': 'Space'},
          'shortname': 'space',
        },
      ),
    ],
  );

  // Get all users
  ActionResponse responseQuery = await Dmart.query(
    QueryRequest(queryType: QueryType.subpath, spaceName: 'management', subpath: 'users', retrieveJsonPayload: true),
  );

  // Accessing the record attachments
  for (ActionResponseRecord record in responseQuery.records ?? []) {
    // Accessing the record attachments
    if (record.hasAttachment) {
      // get all attachaments
      List<String> attachmentsUrls = record.attachmentsUrls(spaceName: 'management');

      // get attachment by shortname
      String? attachmentUrl = record.getAttachementByShortname(spaceName: 'management', shortname: 'thumbnail');
    }
    print(record.shortname);
  }

  // Type Safety example
  ActionResponse<Order> responseQueryExample = await Dmart.query<Order>(
    QueryRequest(queryType: QueryType.subpath, spaceName: 'management', subpath: 'users', retrieveJsonPayload: true),
  );

  ActionResponseRecord<Order> record = responseQueryExample.records!.first;
  Order order = record.body!;

  // Retrieve entry
  ResponseEntry responseEntry = await Dmart.retrieveEntry(
    RetrieveEntryRequest(
      resourceType: ResourceType.user,
      spaceName: 'management',
      subpath: 'users',
      shortname: 'jimmy',
      retrieveJsonPayload: true,
    ),
  );

  // Get entry payload
  ActionResponse responseEntryPayload = await Dmart.getPayload(
    GetPayloadRequest(
      resourceType: ResourceType.content,
      spaceName: 'myspace',
      subpath: 'mysubpath',
      shortname: 'myentry',
    ),
  );

  // Create a folder
  ActionRequestRecord actionRequestRecordFolder = ActionRequestRecord(
    resourceType: ResourceType.folder,
    subpath: '/',
    shortname: 'my_subpath',
    attributes: subpathAttributes,
  );
  ActionResponse responseRequestFolder = await Dmart.request(
    ActionRequest(spaceName: 'my_space', requestType: RequestType.create, records: [actionRequestRecordFolder]),
  );

  // Create a content
  ActionRequestRecord actionRequestRecord = ActionRequestRecord(
    resourceType: ResourceType.content,
    subpath: 'my_subpath',
    shortname: 'my_content',
    attributes: {
      "is_active": true,
      "relationships": [],
      "payload": {
        "content_type": "json",
        "schema_shortname": null,
        "body": {"isAlive": true},
      },
    },
  );
  ActionResponse responseRequestContent = await Dmart.request(
    ActionRequest(spaceName: 'my_space', requestType: RequestType.create, records: [actionRequestRecord]),
  );

  // Create an attachment for a content
  ActionRequestRecord actionRequestRecordAttachment = ActionRequestRecord(
    resourceType: ResourceType.json,
    subpath: 'my_subpath/my_content',
    shortname: 'auto',
    attributes: {
      "is_active": true,
      "payload": {
        "content_type": "json",
        "schema_shortname": null,
        "body": {"attachmentName": "my attachment", "isImportant": "very important"},
      },
    },
  );
  ActionResponse responseRequestAttachment = await Dmart.request(
    ActionRequest(spaceName: 'my_space', requestType: RequestType.create, records: [actionRequestRecordAttachment]),
  );

  // var (respCreateSpace, _) = await Dmart.createSpace(createSpaceActionRequest);

  // Create an attachment
  File img = File("/path/to/myimg.jpg");
  var (respAttachmentCreation, _) = await Dmart.createAttachment(
    spaceName: "myspace",
    entitySubpath: "mysubpath",
    entityShortname: "myshortname",
    attachmentShortname: "auto",
    attachmentBinary: img,
  );

  // Get manifests
  dynamic responseManifests = await Dmart.getManifest();

  // Get settings
  dynamic responseSettings = await Dmart.getSettings();

  // Logout
  ApiResponse responseLogout = await Dmart.logout();

  // Submit an entry
  ActionResponse responseSubmitEntry = await Dmart.submit("applications", "log", "logs", null, null, {
    "shortname": "myentry",
    "resource_type": ResourceType.content.name,
    "state": "awesome entry it is !",
  });
}

class Order {
  final String info;
  final String payment;
  final int combinedOrderId;

  Order({required this.info, required this.payment, required this.combinedOrderId});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      info: json['info'] ?? '',
      payment: json['payment'] ?? '',
      combinedOrderId: json['combined_order_id'] ?? 0,
    );
  }
}
