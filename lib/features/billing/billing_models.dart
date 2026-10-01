class PublicPricing {
  const PublicPricing({
    required this.b2cPremiumPriceVnd,
    this.chatFreeDailyLimit,
    this.orgPlans = const [],
  });

  final int b2cPremiumPriceVnd;
  final int? chatFreeDailyLimit;
  final List<OrgPlanInfo> orgPlans;

  factory PublicPricing.fromJson(Map<String, dynamic> json) {
    final plans = <OrgPlanInfo>[];
    final raw = json['orgPlans'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) plans.add(OrgPlanInfo.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return PublicPricing(
      b2cPremiumPriceVnd: (json['b2cPremiumPriceVnd'] as num?)?.toInt() ?? 49000,
      chatFreeDailyLimit: (json['chatFreeDailyLimit'] as num?)?.toInt(),
      orgPlans: plans,
    );
  }
}

class OrgPlanInfo {
  const OrgPlanInfo({
    required this.planType,
    required this.label,
    required this.priceVnd,
  });

  final String planType;
  final String label;
  final int priceVnd;

  factory OrgPlanInfo.fromJson(Map<String, dynamic> json) {
    return OrgPlanInfo(
      planType: json['planType'] as String? ?? '',
      label: json['label'] as String? ?? '',
      priceVnd: (json['priceVnd'] as num?)?.toInt() ?? 0,
    );
  }
}

class B2cPaymentIntent {
  const B2cPaymentIntent({
    required this.orderCode,
    required this.qrUrl,
    required this.amountVnd,
    required this.transferContent,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    required this.status,
  });

  final String orderCode;
  final String qrUrl;
  final int amountVnd;
  final String transferContent;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final String status;

  factory B2cPaymentIntent.fromJson(Map<String, dynamic> json) {
    return B2cPaymentIntent(
      orderCode: json['orderCode'] as String? ?? '',
      qrUrl: json['qrUrl'] as String? ?? '',
      amountVnd: (json['amountVnd'] as num?)?.toInt() ?? 0,
      transferContent: json['transferContent'] as String? ?? '',
      bankCode: json['bankCode'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
    );
  }
}
