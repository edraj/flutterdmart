# Dart client for Dmart

A Dart implementation of the Dmart that depends on dio.

## APIs

Methods:
* `static void init({Dio? dio, DmartConfig configuration = const DmartConfig()})` - Initializes the Dmart instance.
* `static void setToken(String token)` - Sets the authentication token.
* `static void clearToken()` - Clears the authentication token.
* `static Future<dynamic> getManifest()` - Retrieves the Dmart manifest.
* `static Future<dynamic> getSettings()` - Retrieves the Dmart settings.
* `static Future<LoginResponse> login(LoginRequest request)` - Authenticates a user.
* `static Future<CreateUserResponse> createUser(CreateUserRequest request)` - Creates a new user.
* `static Future<ApiResponse> logout()` - Logs the user out.
* `static Future<ApiResponse> otpRequest(SendOTPRequest request)` - Sends an OTP request.
* `static Future<ApiResponse> otpRequestLogin(SendOTPRequest request)` - Sends an OTP request for login.
* `static Future<ApiResponse> passwordResetRequest(PasswordResetRequest request)` - Sends a password reset request.
* `static Future<ApiResponse> confirmOTP(ConfirmOTPRequest request)` - Confirms the OTP.
* `static Future<ApiResponse> userReset(String shortname)` - Resets a user's password.
* `static Future<ApiResponse> validatePassword(String password)` - Validates the user's password.
* `static Future<ProfileResponse> getProfile()` - Retrieves the current user's profile.
* `static Future<ProfileResponse> updateProfile(ActionRequestRecord profile)` - Updates the user's profile.
* `static Future<ActionResponse<T>> query<T>(QueryRequest query, {Scope scope = Scope.public, Map<String, dynamic>? extra, T Function(dynamic)? parser})` - Executes a query.
* `static Future<ActionResponse<T>> request<T>(ActionRequest action, {Scope scope = Scope.managed, T Function(dynamic)? parser})` - Performs an action.
* `static Future<ResponseEntry> retrieveEntry(RetrieveEntryRequest request, {Scope scope = Scope.public})` - Fetches a specific entry.
* `static Future<ActionResponse<dynamic>> getSpaces()` - Retrieves a list of spaces.
* `static Future<dynamic> getPayload(GetPayloadRequest request, {Scope scope = Scope.public})` - Retrieves payload data.
* `static Future<ApiQueryResponse> progressTicket(ProgressTicketRequest request, {Scope scope = Scope.public})` - Updates a progress ticket.
* `static Future<dynamic> createAttachment({...})` - Uploads an attachment.
* `static Future<ActionResponse<T>> submit<T>(...)` - Submits a record.

## Basic Usage

* Always initialize the Dmart instance before using it.

```dart
// Option 1: with DmartConfig
Dmart.init(
  configuration: DmartConfig(
    baseUrl: 'https://api.dmart.cc',
    connectTimeout: const Duration(seconds: 30),
  ),
);

// Option 2: with custom Dio instance
Dmart.init(
  dio: Dio(
    BaseOptions(
      baseUrl: 'https://api.dmart.cc',
    ),
  ),
);
```

* Authenticate by setting the token:

```dart
Dmart.setToken('your_token');
```

* Getting manifests and settings:

```dart
// Get manifests
dynamic responseManifests = await Dmart.getManifest();
// Get settings
dynamic responseSettings = await Dmart.getSettings();
```

* User creation:

```dart
final CreateUserAttributes createUserAttributes = CreateUserAttributes(
    displayname: Displayname(en: 'test'),
    invitation: 'ABC',
    password: '@Jimmy123_',
    roles: ['super_admin'],
);
CreateUserResponse responseCreateUser = await Dmart.createUser(
  CreateUserRequest(shortname: 'jimmy', attributes: createUserAttributes),
);
```

* User login:

```dart
LoginResponse responseLogin = await Dmart.login(
  LoginRequest(shortname: 'jimmy', password: '@Jimmy123_'),
);
```

* Get user profile:

```dart
ProfileResponse responseProfile = await Dmart.getProfile();
print(responseProfile.records?.first.shortname);
```

* Get all spaces:

```dart
ActionResponse responseSpaces = await Dmart.getSpaces();
print(responseSpaces.records?.length);
```

* Querying a subpath:

```dart
ActionResponse responseQuery = await Dmart.query(
    QueryRequest(
        queryType: QueryType.subpath,
        spaceName: 'management',
        subpath: 'users',
        retrieveJsonPayload: true,
    ),
);

for (ActionResponseRecord record in responseQuery.records ?? []) {
  print(record.shortname);
}
```

* Accessing record attachments:

```dart
for (ActionResponseRecord record in responseQuery.records ?? []) {
  // check if record has attachments
  if (record.hasAttachment) {
    // Get all media attachment URLs
    List<String> urls = record.attachmentsUrls(spaceName: "management");
    
    // Get a specific attachment by its shortname
    String? thumb = record.getAttachementByShortname(
      shortname: "thumbnail", 
      spaceName: "management"
    );
  }
}
```

## Generic Usage & Type Safety

You can now use `ActionResponse` with generic types for the payload body. This improves type safety and avoids manual casting.

```dart
// 1. Define your model
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

// 2. Perform a generic query
ActionResponse<Order> response = await Dmart.query<Order>(
  QueryRequest(
    queryType: QueryType.subpath,
    spaceName: "management",
    subpath: "users",
    retrieveJsonPayload: true,
  ),
  parser: (json) => Order.fromJson(json),
);

// 3. Access typed body
if (response.records != null && response.records!.isNotEmpty) {
  ActionResponseRecord<Order> record = response.records!.first;
  
  // Access the correctly typed body via the .body getter
  Order? order = record.body;
  print("Order ID: ${order?.combinedOrderId}");
}
```

* Logout:

```dart
ApiResponse responseLogout = await Dmart.logout();
```

