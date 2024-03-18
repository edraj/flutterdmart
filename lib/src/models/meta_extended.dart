class MetaExtended {
  final String? email;
  final String? msisdn;
  final bool? isEmailVerified;
  final bool? isMsisdnVerified;
  final bool? forcePasswordChange;
  final String? password;
  final String? workflowShortname;
  final String? state;
  final bool? isOpen;

  MetaExtended({
    this.email,
    this.msisdn,
    this.isEmailVerified,
    this.isMsisdnVerified,
    this.forcePasswordChange,
    this.password,
    this.workflowShortname,
    this.state,
    this.isOpen,
  });

  factory MetaExtended.fromJson(Map<String, dynamic> json) {
    return MetaExtended(
      email: json['email'],
      msisdn: json['msisdn'],
      isEmailVerified: json['is_email_verified'],
      isMsisdnVerified: json['is_msisdn_verified'],
      forcePasswordChange: json['force_password_change'],
      password: json['password'],
      workflowShortname: json['workflow_shortname'],
      state: json['state'],
      isOpen: json['is_open'],
    );
  }
}
