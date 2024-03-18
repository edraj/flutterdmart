# Dart client for Dmart

A Dart implementation of the Dmart that depends on dio.

## APIs

* :white_check_mark: `void initDmart({bool isDioVerbose = false})` - Initializes the Dio networking instance.
* :white_check_mark: `Future<(LoginResponse?, Error?)> login(LoginRequest loginRequest)` - Authenticates a user and returns login information.
* :white_check_mark: `Future<(CreateUserResponse?, Error?)> createUser(CreateUserRequest createUserRequest)` - Creates a new user.
* :white_circle: `Future<(ApiResponse?, Error?)> logout()` - Logs the user out.
* :white_check_mark: `Future<(ProfileResponse?, Error?)> getProfile()` - Retrieves the current user's profile.
* :white_check_mark: `Future<(ApiQueryResponse?, Error?)> query(QueryRequest query, {String scope = "managed"})` -  Executes a query against the Dmart backend.
* :white_check_mark: `Future<(ActionResponse?, Error?)> request(ActionRequest action)` -  Performs an action on the Dmart system.
* :white_circle: `Future<(ResponseEntry?, Error?)> retrieveEntry(RetrieveEntryRequest request, {String scope = "managed"})` -  Fetches a specific entry from Dmart.
* :white_check_mark: `Future<(ActionResponse?, Error?)> createSpace(ActionRequest action)` - Creates a new space.
* :white_check_mark: `Future<(ApiQueryResponse?, Error?)> getSpaces()` - Retrieves a list of spaces.
* :white_circle: `Future<dynamic> getPayload(GetPayloadRequest request)` - Retrieves payload data.
* :white_circle: `Future<(ApiQueryResponse?, Error?)> progressTicket(ProgressTicketRequest request)` - Updates a progress ticket.
* :white_circle: `Future<(Response?, Error?)> createAttachment({required String shortname, required String entitySubpath, required File payloadFile, required String spaceName, bool isActive = true, String resourceType = "media"})` - Uploads an attachment.
* :white_circle: `Future<(ActionResponse?, Error?)> submit(String spaceName, String schemaShortname, String subpath, Map<String, dynamic> record)` - Submits a record to Dmart.
* :white_circle: `String getAttachmentUrl(String resourceType, String spaceName, String subpath, String parentShortname, String shortname, String ext)` - Constructs an attachment URL.

## Basic Usage

* Always initialize the Dmart instance before using it.

```dart
Dmart.initDmart();
// Or with dio verbose for debugging purposes
Dmart.initDmart(isDioVerbose: true);
```

* User creation

```dart
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
```

* User login

```dart
// By using shortname and password
var (responseLogin, _) = await Dmart.login(
  LoginRequest(shortname: 'jimmy', password: '@Jimmy123_'),
);

// By using email or msisdn instead of shortname
LoginRequest.withEmail
LoginRequest.withMsisdn

// By passing directly a token
Dmart.token = 'xxx.yyy.zzz';
```

* Get user profile

```dart
var (respProfile, _) = await Dmart.getProfile();
```

* Get all spaces

```dart
var (respSpaces, _) = await Dmart.getSpaces();
```

* Create a space

```dart
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
```

* Querying a subpath

```dart
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
```

* Content creation

```dart
// folder creation
ActionRequestRecord actionRequestRecord = ActionRequestRecord(
  resourceType: ResourceType.folder,
  subpath: '/',
  shortname: 'my_subpath',
  attributes: subpathAttributes,
);
ActionRequest action = ActionRequest(
  spaceName: 'my_space',
  requestType: RequestType.create,
  records: [actionRequestRecord],
);
var (respRequestFolder, err) = await Dmart.request(action);

// content creation
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
            "body": {
              "isAlive": true
            }
        }
    },
);
ActionRequest action = ActionRequest(
    spaceName: 'my_space',
    requestType: RequestType.create,
    records: [actionRequestRecord],
);
var (respRequestContent, err) = await Dmart.request(action);

// attachment creation
ActionRequestRecord actionRequestRecord = ActionRequestRecord(
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
ActionRequest action = ActionRequest(
    spaceName: 'my_space',
    requestType: RequestType.create,
    records: [actionRequestRecord],
);
var (respRequestAttachment, err) = await Dmart.request(action);
```