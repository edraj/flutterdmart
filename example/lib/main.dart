import 'dart:io';

import 'package:dmart/dmart.dart';
import 'package:dmart/src/enums/query_type.dart';
import 'package:dmart/src/enums/request_type.dart';
import 'package:dmart/src/enums/resource_type.dart';
import 'package:dmart/src/models/create_user_model.dart';
import 'package:dmart/src/models/displayname.dart';
import 'package:dmart/src/models/get_payload_request.dart';
import 'package:dmart/src/models/login_model.dart';
import 'package:dmart/src/models/progress_ticket_request.dart';
import 'package:dmart/src/models/query/query_request.dart';
import 'package:dmart/src/models/request/action_request.dart';
import 'package:dmart/src/models/retrieve_entry_request.dart';

import 'consts.dart';


Future<void> main() async {
  const baseUrl = 'https://dmart.cc/dmart';
  Dmart.dmartServerUrl = baseUrl;
  Dmart.initDmart();

  // Creating a user
  final CreateUserAttributes createUserAttributes = CreateUserAttributes(
    displayname: Displayname(en: 'test'),
    invitation: 'ABC',
    password: '@Jimmy123_',
    roles: ['super_admin'],
  );
  var (responseCreateUser, error) = await Dmart.createUser(CreateUserRequest(
    shortname: 'jimmy',
    attributes: createUserAttributes,
  ));

  // User login
  var (responseLogin, _) = await Dmart.login(
    LoginRequest(shortname: 'jimmy', password: '@Jimmy123_'),
  );

  // Fetching user profile
  var (respProfile, _) = await Dmart.getProfile();
  print(respProfile?.records?.first.shortname);

  // Get all spaces
  var (respSpaces, _) = await Dmart.getSpaces();
  print(respSpaces?.records.length);

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
      ]);

  var (respCreateSpace, _) = await Dmart.createSpace(createSpaceActionRequest);


  // Get all users
  var (respQuery, _) = await Dmart.query(
    QueryRequest(
      queryType: QueryType.subpath,
      spaceName: 'management',
      subpath: 'users',
      retrieveJsonPayload: true,
    ),
  );
  for (var record in respQuery?.records ?? []) {
    print(record.shortname);
  }

  // Retrieve entry
  var (respEntry, _) = await Dmart.retrieveEntry(
      RetrieveEntryRequest(
          resourceType: ResourceType.user,
          spaceName: 'management',
          subpath: 'users',
          shortname: 'jimmy',
          retrieveJsonPayload: true,
      )
  );

  // Get entry payload
  var (respEntryPayload, _) = await Dmart.getPayload(
      GetPayloadRequest(
        resourceType: ResourceType.content,
        spaceName: 'myspace',
        subpath: 'mysubpath',
        shortname: 'myentry'
      )
  );

  // Create a folder
  ActionRequestRecord actionRequestRecordFolder = ActionRequestRecord(
    resourceType: ResourceType.folder,
    subpath: '/',
    shortname: 'my_subpath',
    attributes: subpathAttributes,
  );
  var (respRequestFolder, err) = await Dmart.request(ActionRequest(
    spaceName: 'my_space',
    requestType: RequestType.create,
    records: [actionRequestRecordFolder],
  ));

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
        "body": {"isAlive": true}
      }
    },
  );
  var (respRequestContent, _) = await Dmart.request(ActionRequest(
    spaceName: 'my_space',
    requestType: RequestType.create,
    records: [actionRequestRecord],
  ));

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
        "body": {
          "attachmentName": "my attachment",
          "isImportant": "very important"
        }
      }
    },
  );
  var (respRequestAttachment, _) = await Dmart.request(
      ActionRequest(
        spaceName: 'my_space',
        requestType: RequestType.create,
        records: [actionRequestRecordAttachment],
      )
  );

  // Progress a ticket
  var (respProgression, _) = await Dmart.progressTicket(
      ProgressTicketRequest(
        spaceName: "myspace",
        subpath: "test",
        shortname: "myticket",
        action: "rejected",
      )
  );

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
  var (respManifests, _) = await Dmart.getManifest();

  // Get settings
  var (respSettings, _) = await Dmart.getSettings();

  // Logout
  var (respLogout, _) = await Dmart.logout();
}
