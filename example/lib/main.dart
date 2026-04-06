// ignore_for_file: avoid_print, unused_local_variable

import 'dart:io';

import 'package:dmart/dmart.dart';

import 'consts.dart';

Future<void> main() async {
  Dmart.dmartServerUrl = 'https://api.dmart.cc';
  await Dmart.initDmart();

  // Creating a user
  final createUserAttributes = CreateUserAttributes(
    displayname: Translation(en: 'test'),
    invitation: 'ABC',
    password: '@Jimmy123_',
    roles: ['super_admin'],
  );
  final (responseCreateUser, error) = await Dmart.createUser(
    CreateUserRequest(shortname: 'jimmy', attributes: createUserAttributes),
  );

  // User login
  final (responseLogin, _) = await Dmart.login(
    LoginRequest(shortname: 'jimmy', password: '@Jimmy123_'),
  );

  // Fetching user profile
  final (respProfile, _) = await Dmart.getProfile();
  print(respProfile?.records?.first.shortname);

  // Get all spaces
  final (respSpaces, _) = await Dmart.getSpaces();
  print(respSpaces?.records?.length);

  // Create space
  final createSpaceActionRequest = ActionRequest(
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

  // var (respCreateSpace, _) = await Dmart.createSpace(createSpaceActionRequest);

  // Get all users
  final (respQuery, _) = await Dmart.query(
    QueryRequest(
      queryType: QueryType.subpath,
      spaceName: 'management',
      subpath: 'users',
      retrieveJsonPayload: true,
    ),
  );
  for (final record in respQuery?.records ?? []) {
    print(record.shortname);
  }

  // Retrieve entry
  final (respEntry, _) = await Dmart.retrieveEntry(
    RetrieveEntryRequest(
      resourceType: ResourceType.user,
      spaceName: 'management',
      subpath: 'users',
      shortname: 'jimmy',
      retrieveJsonPayload: true,
    ),
  );

  // Get entry payload
  final (respEntryPayload, _) = await Dmart.getPayload(
    GetPayloadRequest(
      resourceType: ResourceType.content,
      spaceName: 'myspace',
      subpath: 'mysubpath',
      shortname: 'myentry',
    ),
  );

  // Create a folder
  final actionRequestRecordFolder = ActionRequestRecord(
    resourceType: ResourceType.folder,
    subpath: '/',
    shortname: 'my_subpath',
    attributes: subpathAttributes,
  );
  final (respRequestFolder, err) = await Dmart.request(
    ActionRequest(
      spaceName: 'my_space',
      requestType: RequestType.create,
      records: [actionRequestRecordFolder],
    ),
  );

  // Create a content
  final actionRequestRecord = ActionRequestRecord(
    resourceType: ResourceType.content,
    subpath: 'my_subpath',
    shortname: 'my_content',
    attributes: {
      'is_active': true,
      'relationships': [],
      'payload': {
        'content_type': 'json',
        'schema_shortname': null,
        'body': {'isAlive': true},
      },
    },
  );
  final (respRequestContent, _) = await Dmart.request(
    ActionRequest(
      spaceName: 'my_space',
      requestType: RequestType.create,
      records: [actionRequestRecord],
    ),
  );

  // Create an attachment for a content
  final actionRequestRecordAttachment = ActionRequestRecord(
    resourceType: ResourceType.json,
    subpath: 'my_subpath/my_content',
    shortname: 'auto',
    attributes: {
      'is_active': true,
      'payload': {
        'content_type': 'json',
        'schema_shortname': null,
        'body': {
          'attachmentName': 'my attachment',
          'isImportant': 'very important',
        },
      },
    },
  );
  final (respRequestAttachment, _) = await Dmart.request(
    ActionRequest(
      spaceName: 'my_space',
      requestType: RequestType.create,
      records: [actionRequestRecordAttachment],
    ),
  );

  // Create an attachment
  final img = File('/path/to/myimg.jpg');
  final (respAttachmentCreation, _) = await Dmart.createAttachment(
    spaceName: 'myspace',
    entitySubpath: 'mysubpath',
    entityShortname: 'myshortname',
    attachmentShortname: 'auto',
    attachmentBinary: img,
  );

  // Get manifests
  final (respManifests, _) = await Dmart.getManifest();

  // Get settings
  final (respSettings, _) = await Dmart.getSettings();

  // Logout
  final (respLogout, _) = await Dmart.logout();

  // Submit an entry
  final (
    respSubmitEntry,
    _,
  ) = await Dmart.submit('applications', 'log', 'logs', null, null, {
    'shortname': 'myentry',
    'resource_type': ResourceType.content.name,
    'state': 'awesome entry it is !',
  });
}
