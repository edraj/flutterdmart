enum DmartExceptionEnum {
  NOT_INITIALIZED,
  NOT_VALID_TOKEN,
}

class DmartExceptionMessages {
  static const Map<DmartExceptionEnum, String> messages = {
    DmartExceptionEnum.NOT_INITIALIZED:
        "Dmart is not initialized, make sure that you did call Dmart.initDmart() before calling this method.",
    DmartExceptionEnum.NOT_VALID_TOKEN:
        "No token has been passed, make sure that you did call Dmart.login() or you did pass a token.",
  };
}

class DmartException implements Exception {
  DmartExceptionEnum code;
  String message;

  DmartException(this.code, this.message);

  @override
  String toString() {
    return 'DmartException: [${code.name}] $message';
  }
}
