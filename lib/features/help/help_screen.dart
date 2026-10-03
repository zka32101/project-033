import 'package:flutter/material.dart';

/// ヘルプの1項目(見出しと本文)。
class HelpEntry {
  final String title;
  final String body;

  const HelpEntry(this.title, this.body);
}

/// ヘルプの1つの分類。
class HelpSection {
  final String title;
  final IconData icon;
  final List<HelpEntry> entries;

  const HelpSection(this.title, this.icon, this.entries);
}

/// 受講者向けの使い方。
const List<HelpSection> learnerHelpSections = [
  HelpSection('はじめに', Icons.waving_hand_outlined, [
    HelpEntry(
      'Safyでできること',
      '仕事で必要なセキュリティ・コンプライアンス・安全衛生などの研修を、スマートフォンで短時間ずつ受けられるアプリです。'
          'レッスンを読み、確認クイズに合格すると修了となり、修了証が発行されます。',
    ),
    HelpEntry(
      '14日間のお試し',
      '「14日間お試しで始める」で登録すると、お試しチームが作られ、14日間はすべての研修を無料で利用できます。'
          '最大5名まで、招待コードでメンバーを招待して、チームでの使い勝手を試せます。'
          'ホーム画面の上部に、お試しの残り日数が表示されます。',
    ),
    HelpEntry(
      'チームに参加するには',
      '管理者から受け取った「チームID(招待コード)」と自分の名前を入力し、「チームIDで参加する」を押します。'
          'コードの有効期限が切れている、または人数の上限に達しているときは、管理者に確認してください。',
    ),
  ]),
  HelpSection('研修の受け方', Icons.menu_book_outlined, [
    HelpEntry(
      'ホーム画面の見方',
      'ホームには、あなたの業種に合わせて並び替えられた研修が表示されます。「必須」は特に優先して受けてほしい研修、'
          '「今月の必須モジュール」は今月のおすすめです。カードをタップすると、レッスンが始まります。',
    ),
    HelpEntry(
      '職種を選ぶ',
      'ホーム上部の「あなたの職種」から、自分の職種(新入社員、経理・財務、人事・総務、営業、購買・調達、情報システム、管理職)を選べます。'
          '選ぶと、全員向けの研修と自分の職種向けの研修だけが表示されます。「すべて」に戻すと、全研修が表示されます。',
    ),
    HelpEntry(
      'レッスンとクイズ',
      '研修は、数ページのレッスンと、最後の確認クイズで構成されています。クイズが合格ライン(初期値は80%)に達すると修了です。'
          '不合格でも、レッスンを読み直して何度でも再挑戦できます。',
    ),
    HelpEntry(
      '無料体験と有料の研修',
      '通常は、各分野の最初の研修が無料体験です。お試し期間中は、すべての研修を受けられます。'
          '期間が終わると、無料体験の研修だけが受けられる状態になり、続けるにはプランの契約が必要です。',
    ),
  ]),
  HelpSection('学習を続ける', Icons.trending_up, [
    HelpEntry(
      '学習パス',
      '「学習パス」では、レベルに合わせたおすすめの研修が表示されます。まだ受講していない研修や、優先度の高い研修が上に並びます。',
    ),
    HelpEntry(
      '成長',
      '「成長」タブでは、分野ごとの学習の進み具合がレーダーチャートで表示されます。分野を修了するごとにバッジがもらえます。',
    ),
    HelpEntry(
      '修了証',
      'ホーム右上の修了証のアイコンから、修了した研修の修了証を確認できます。',
    ),
    HelpEntry(
      'Q&Aフォーラム',
      '「Q&A」タブでは、研修や仕事の疑問を質問したり、ほかの人の質問に回答したりできます。',
    ),
  ]),
];

/// 管理者向けの使い方。
const List<HelpSection> adminHelpSections = [
  HelpSection('メンバーの招待', Icons.group_add_outlined, [
    HelpEntry(
      '招待コードの発行',
      'ホーム右上の「管理者メニュー」から、チームの管理を開き、招待コードを発行します。'
          'コードをメンバーに共有すると、メンバーは「チームIDで参加する」から参加できます。',
    ),
    HelpEntry(
      '人数の上限',
      'お試しチームは、最大5名(管理者を含む)です。上限に達すると、新しい参加は受け付けられません。'
          '5名を超えて使うには、プランの契約が必要です。',
    ),
    HelpEntry(
      'コードの発行は、チームごとに一度だけ',
      '招待コードは、チームごとに一度だけ発行できます。発行後の再発行や変更はできないため、共有する相手に注意してください。'
          '人ごとに分けて配りたいときは、下の「社員の一括登録」を使います。',
    ),
    HelpEntry(
      '社員の一括登録',
      '管理者メニューの「社員の一括登録」で、名簿(名前, チーム名, 職種)を貼り付けると、1人ごとの使い切りの招待コードを発行できます。'
          'Excelからコピーして、そのまま貼り付けられます。「内容を確認する」で、チーム名や職種の誤り・重複・空き席の不足が行ごとに分かります。'
          '社員がそのコードを入力すると、名簿どおりの名前・チーム・職種で参加します。'
          '発行した人数分の席は、参加前から確保されます。未参加のコードは「取り消す」で無効にできます。コード一覧はExcelで出力できます。',
    ),
  ]),
  HelpSection('メンバー管理', Icons.manage_accounts_outlined, [
    HelpEntry(
      '管理者の追加と戻し',
      '管理者メニューの「メンバー管理」で、メンバーを管理者にしたり、メンバーに戻したりできます。'
          '管理者が1人だけのときは、メンバーに戻すことも無効にすることもできません。',
    ),
    HelpEntry(
      '職種の設定',
      'メンバーの職種は、本人がホームで選ぶほか、管理者が「メンバー管理」の「職種を設定する」で設定できます。職種別の必須研修の対象になります。',
    ),
    HelpEntry(
      '退職などの無効化と再有効化',
      '退職した人などは「無効化する」で利用を止められます。無効化すると席が空き、その人はアプリを使えなくなります(受講記録は残ります)。'
          '再び使うときは「再有効化」します。空き席がないときは再有効化できません。',
    ),
  ]),
  HelpSection('受講する研修の決め方', Icons.fact_check_outlined, [
    HelpEntry(
      '全社共通の必須研修',
      '管理者メニューの「受講コンテンツの設定」で、全員が受ける必須研修を選びます。会社情報(従業員数・事業の特徴)を入れておくと、'
          '法令や規模に合う研修が、最初からチェックされた状態で表示されます。',
    ),
    HelpEntry(
      'チームごとの追加',
      '「チーム管理」の「このチームの必須研修を設定する」で、そのチームだけに追加する必須研修を選べます。',
    ),
    HelpEntry(
      '職種ごとの追加',
      '管理者メニューの「職種別の必須研修」で、職種ごとに追加する必須研修を選べます。'
          '一人ひとりの必須は、全社共通 + チームの追加 + 職種の追加の合計で決まり、受講率やレポートもこの合計で集計されます。',
    ),
    HelpEntry(
      '会社情報の設定',
      '「会社情報の設定(規模・事業)」で、従業員数と事業の特徴(例: 個人情報の取り扱い、運送など)を入力します。推奨される研修の選び方に使われます。',
    ),
  ]),
  HelpSection('お試し期間と契約', Icons.timer_outlined, [
    HelpEntry(
      'お試しの期間',
      '登録から14日間、すべての研修を利用できます。ホーム上部のバナーで残り日数を確認できます。',
    ),
    HelpEntry(
      '契約のしかた',
      '管理者メニューの「ご契約について」で、契約の流れを確認できます。請求書払い(Web)では、人数を入力して決済ページに進みます。'
          'お試し期間の終了の3日前・1日前・当日には、管理者に通知が届きます。なお、適格請求書(インボイス)には現在対応していません。',
    ),
    HelpEntry(
      '期間が終わったら',
      '期間が終わると、無料体験の研修だけが受けられる状態になります。継続して全研修を使うには、プランを契約してください。'
          'お試し期間の終了後は、新しいメンバーの招待もできなくなります。',
    ),
  ]),
  HelpSection('進捗の確認と設定', Icons.insights_outlined, [
    HelpEntry(
      '進捗と受講状況',
      '管理者メニューで、メンバーごとの受講状況やチームの進捗を確認できます。受講が遅れている人には、リマインダーを送れます。',
    ),
    HelpEntry(
      '期限と合格ラインの設定',
      '研修ごとに受講期限を設定できます。合格ラインは、会社の規模に応じた推奨値が表示され、必要に応じて変更できます。',
    ),
    HelpEntry(
      'レポートの出力',
      '受講状況のレポートを出力したり、月次のレポートを指定のメールアドレスに送ったりできます。監査や社内報告に使えます。',
    ),
    HelpEntry(
      '優先する分野の変更',
      '業種に合わせて自動で決まる優先度を、会社の状況に合わせて変更できます。',
    ),
  ]),
  HelpSection('記録と監査', Icons.verified_user_outlined, [
    HelpEntry(
      '修了証・受講記録の出力',
      '管理者メニューの「修了証・受講記録の出力」で、修了証や受講記録をまとめて出力できます。監査や取引先への提出に使えます。',
    ),
    HelpEntry(
      '操作履歴(監査ログ)',
      '管理者メニューの「操作履歴」で、メンバーの追加・管理者の変更・必須研修の変更などを、誰がいつ行ったか確認できます。'
          '記録はサーバーが自動で残し、管理者でも書き換えや削除はできません。Excelで出力することもできます。',
    ),
  ]),
];

/// よくある質問。
const List<HelpEntry> helpFaq = [
  HelpEntry(
    'アプリを開くたびに登録し直す必要がありますか',
    'いいえ。一度登録すると、同じ端末では、次回からそのままホームが開きます。',
  ),
  HelpEntry(
    '端末を変えたり、アプリを削除したりしたらどうなりますか',
    'この端末の登録情報は引き継がれないため、管理者から招待コードをもらい、もう一度参加してください。',
  ),
  HelpEntry(
    '合格できないときは',
    'レッスンを読み直し、クイズにもう一度挑戦してください。何度でも再挑戦できます。',
  ),
  HelpEntry(
    '自分の職種の研修が見つからないときは',
    'ホーム上部の「あなたの職種」が、別の職種になっていないか確認してください。「すべて」を選ぶと、全研修が表示されます。',
  ),
  HelpEntry(
    '研修の内容の法令は最新ですか',
    '教材は、作成時点の法令にもとづいています。最新の情報は、所管省庁の公表資料も確認してください。',
  ),
];

/// アプリ内ヘルプ画面。管理者には管理者向けの使い方も表示する。
class HelpScreen extends StatelessWidget {
  final bool isAdmin;

  const HelpScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final sections = [
      ...learnerHelpSections,
      if (isAdmin) ...adminHelpSections,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('使い方')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final section in sections) ...[
            _SectionHeader(section: section),
            for (final entry in section.entries) _HelpTile(entry: entry),
          ],
          const _SectionHeader(
            section: HelpSection('よくある質問', Icons.help_outline, []),
          ),
          for (final entry in helpFaq) _HelpTile(entry: entry),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final HelpSection section;

  const _SectionHeader({required this.section});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Icon(section.icon, color: color),
          const SizedBox(width: 8),
          Text(
            section.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final HelpEntry entry;

  const _HelpTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(entry.title),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(entry.body, style: const TextStyle(height: 1.6))],
    );
  }
}
