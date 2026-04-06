/// The types of exceptions that can be thrown by the Dmart client.
enum DmartExceptionEnum { notInitialized, notValidToken }

/// Human-readable messages for each [DmartExceptionEnum] value.
class DmartExceptionMessages {
  static const Map<DmartExceptionEnum, String> messages = {
    DmartExceptionEnum.notInitialized:
        'Dmart is not initialized, make sure that you did call Dmart.initDmart() before calling this method.',
    DmartExceptionEnum.notValidToken:
        'No token has been passed, make sure that you did call Dmart.login() or you did pass a token.',
  };
}

/// Exception thrown by the Dmart client for initialization and auth errors.
class DmartException implements Exception {
  DmartException(this.code, this.message);

  final DmartExceptionEnum code;
  final String message;

  @override
  String toString() {
    return 'DmartException: [${code.name}] $message';
  }
}
