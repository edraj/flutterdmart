/// The server settings a client needs, from `GET /public/client-config`
/// (`Dmart.getClientConfig`, dmart >= 1.6.12).
///
/// Read these instead of hard-coding a 6-digit code box, a resend countdown,
/// an upload cap or a page size: they follow the server's configuration.
class ClientConfig {
  /// The least time to wait for an answer, in milliseconds. A little longer
  /// than the server's own timeout, so its timeout error arrives first.
  final int? backendTimeout;

  /// How many digits a one-time code has.
  final int? otpLength;

  /// Seconds before another code can be requested for the same address.
  final int? otpResendAfter;

  /// Seconds a code stays valid.
  final int? otpTokenTtl;

  /// The largest upload the server takes, in megabytes.
  final int? maxUploadSizeMb;

  /// The page size a query gets when it sends no `limit`.
  final int? defaultQueryLimit;

  /// The largest `limit` a query may ask for.
  final int? maxQueryLimit;

  /// The page size the server's own UIs use for lists.
  final int? uiListLimit;

  /// Whether the server applies its own password rule rather than the
  /// default one. [passwordHint] then describes it.
  final bool passwordRuleCustom;

  /// What the password rule asks for, when the server gives one.
  final String? passwordHint;

  /// Whether the server applies its own username rule (dmart >= 1.7.9).
  final bool usernameRuleCustom;

  /// What the username rule asks for, when the server gives one
  /// (dmart >= 1.7.9).
  final String? usernameHint;

  /// The response's attributes as sent, including any key this version does
  /// not know.
  final Map<String, dynamic> raw;

  const ClientConfig({
    this.backendTimeout,
    this.otpLength,
    this.otpResendAfter,
    this.otpTokenTtl,
    this.maxUploadSizeMb,
    this.defaultQueryLimit,
    this.maxQueryLimit,
    this.uiListLimit,
    this.passwordRuleCustom = false,
    this.passwordHint,
    this.usernameRuleCustom = false,
    this.usernameHint,
    this.raw = const {},
  });

  factory ClientConfig.fromJson(Map<String, dynamic> json) {
    int? asInt(Object? v) => v is num ? v.toInt() : null;
    return ClientConfig(
      backendTimeout: asInt(json['backend_timeout']),
      otpLength: asInt(json['otp_length']),
      otpResendAfter: asInt(json['otp_resend_after']),
      otpTokenTtl: asInt(json['otp_token_ttl']),
      maxUploadSizeMb: asInt(json['max_upload_size_mb']),
      defaultQueryLimit: asInt(json['default_query_limit']),
      maxQueryLimit: asInt(json['max_query_limit']),
      uiListLimit: asInt(json['ui_list_limit']),
      passwordRuleCustom: json['password_rule_custom'] == true,
      passwordHint: json['password_hint'],
      usernameRuleCustom: json['username_rule_custom'] == true,
      usernameHint: json['username_hint'],
      raw: Map<String, dynamic>.unmodifiable(json),
    );
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
