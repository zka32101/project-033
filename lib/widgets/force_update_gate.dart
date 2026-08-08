import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/remote_config_service.dart';
import '../core/version_compare.dart';

/// 強制アップデート画面(設計書 Step6.5)。RemoteConfigのmin_supported_versionが
/// 現在のアプリバージョンより新しい場合、それ以上の操作をブロックする。
/// Firebase未設定の間はRemoteConfig取得が失敗するため、その場合は判定をスキップして
/// 通常どおりchildを表示する(Firebase Console設定完了後に自動的に有効化される)。
class ForceUpdateGate extends StatefulWidget {
  final Widget child;

  const ForceUpdateGate({super.key, required this.child});

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate> {
  bool _updateRequired = false;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    try {
      final remoteConfig = RemoteConfigService();
      await remoteConfig.initialize();
      final packageInfo = await PackageInfo.fromPlatform();

      final required = VersionCompare.isUpdateRequired(
        currentVersion: packageInfo.version,
        minSupportedVersion: remoteConfig.minSupportedVersion,
      );
      if (mounted && required) {
        setState(() => _updateRequired = true);
      }
    } catch (_) {
      // Firebase未設定、またはネットワーク不通時は判定をスキップし通常表示を継続する。
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_updateRequired) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.system_update,
                    size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  '最新バージョンへの更新が必要です',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'ストアから最新版へアップデートしてからご利用ください。',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
