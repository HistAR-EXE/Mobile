import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/features/billing/billing_models.dart';

class BillingRepository {
  BillingRepository(this._api);
  final ApiClient _api;

  Future<PublicPricing> publicPricing() => _api.getData(
        '/api/billing/public-pricing',
        parse: (raw) => PublicPricing.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<B2cPaymentIntent> createB2cPayment({String? returnToPath}) => _api.postData(
        '/api/billing/b2c/payment',
        data: {if (returnToPath != null) 'returnToPath': returnToPath},
        parse: (raw) => B2cPaymentIntent.fromJson(Map<String, dynamic>.from(raw as Map)),
      );

  Future<Map<String, dynamic>> b2cPaymentStatus(String orderCode) => _api.getData(
        '/api/billing/b2c/payment/$orderCode',
        parse: (raw) => Map<String, dynamic>.from(raw as Map),
      );
}
