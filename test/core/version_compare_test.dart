import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/version_compare.dart';

void main() {
  group('VersionCompare.isUpdateRequired', () {
    test('現在バージョンが最小要求バージョンより古い場合はtrue', () {
      expect(
        VersionCompare.isUpdateRequired(
          currentVersion: '1.0.0',
          minSupportedVersion: '1.1.0',
        ),
        isTrue,
      );
    });

    test('現在バージョンが最小要求バージョンと同じ場合はfalse', () {
      expect(
        VersionCompare.isUpdateRequired(
          currentVersion: '1.2.3',
          minSupportedVersion: '1.2.3',
        ),
        isFalse,
      );
    });

    test('現在バージョンが最小要求バージョンより新しい場合はfalse', () {
      expect(
        VersionCompare.isUpdateRequired(
          currentVersion: '2.0.0',
          minSupportedVersion: '1.9.9',
        ),
        isFalse,
      );
    });

    test('メジャーバージョンが同じでもマイナー/パッチが古ければtrue', () {
      expect(
        VersionCompare.isUpdateRequired(
          currentVersion: '1.2.0',
          minSupportedVersion: '1.2.5',
        ),
        isTrue,
      );
    });

    test('不正な形式のバージョンは強制しない(安全側)', () {
      expect(
        VersionCompare.isUpdateRequired(
          currentVersion: 'not-a-version',
          minSupportedVersion: '1.0.0',
        ),
        isFalse,
      );
      expect(
        VersionCompare.isUpdateRequired(
          currentVersion: '1.0.0',
          minSupportedVersion: '',
        ),
        isFalse,
      );
    });
  });
}
