import 'package:flutter_test/flutter_test.dart';
import 'package:safy/features/invite_entry/invite_entry_screen.dart';

void main() {
  test('招待コードの入力から空白を除き、全角英数字を半角にそろえる', () {
    expect(normalizeInviteCode('5DJ4UA2T'), '5DJ4UA2T');
    expect(normalizeInviteCode(' 5 DJ4UA2T '), '5DJ4UA2T');
    expect(normalizeInviteCode('５ＤＪ４ＵＡ２Ｔ'), '5DJ4UA2T');
    expect(normalizeInviteCode('5D\u3000J4UA2T'), '5DJ4UA2T');
  });
}
