import 'package:cloud_functions/cloud_functions.dart';

/// Stripe決済のURL発行(Cloud Functions `createCheckoutSession` / `createBillingPortalSession`経由)。
/// 契約状態の反映はサーバー側のWebhookが行う。このサービスは決済ページのURLを取得するだけ。
class BillingService {
  final FirebaseFunctions _functions;
  BillingService([FirebaseFunctions? functions])
    : _functions = functions ?? FirebaseFunctions.instance;

  /// 人数(seats)を指定した月額契約の決済ページURLを返す。
  Future<Uri> createCheckoutUrl({
    required String companyId,
    required int seats,
  }) async {
    final result = await _functions.httpsCallable('createCheckoutSession').call(
      {'companyId': companyId, 'seats': seats},
    );
    return _urlFrom(result.data);
  }

  /// 契約中の会社が、請求書の閲覧・支払い方法の変更・解約を行うページのURLを返す。
  Future<Uri> createPortalUrl({required String companyId}) async {
    final result = await _functions
        .httpsCallable('createBillingPortalSession')
        .call({'companyId': companyId});
    return _urlFrom(result.data);
  }

  Uri _urlFrom(dynamic data) {
    final url = (data as Map?)?['url'] as String?;
    if (url == null || url.isEmpty) {
      throw StateError('決済ページのURLを取得できませんでした');
    }
    return Uri.parse(url);
  }
}
