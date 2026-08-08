import 'package:firebase_remote_config/firebase_remote_config.dart';

/// LiveOps用フラグ管理（設計書 Step6.5: 強制アップデート・機能フラグ即OFF）。
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;
  RemoteConfigService([FirebaseRemoteConfig? remoteConfig])
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const _defaults = <String, Object>{
    'min_supported_version': '1.0.0',
    'audit_log_feature_enabled': true,
    'ranking_feature_enabled': true,
  };

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.setDefaults(_defaults);
    await _remoteConfig.fetchAndActivate();
  }

  String get minSupportedVersion =>
      _remoteConfig.getString('min_supported_version');

  bool get isAuditLogFeatureEnabled =>
      _remoteConfig.getBool('audit_log_feature_enabled');

  bool get isRankingFeatureEnabled =>
      _remoteConfig.getBool('ranking_feature_enabled');
}
