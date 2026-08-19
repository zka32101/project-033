import '../models/lesson_model.dart';

/// レッスン種データ。モジュールごとに4レッスン(導入→具体例→注意点/応用→まとめ・行動指針)。
const Map<String, List<Lesson>> seedLessonsByModule = {
  'm_ethics_sns': [
    Lesson(
      id: 'l_ethics_sns_1',
      moduleId: 'm_ethics_sns',
      title: '個人アカウントでも「会社の顔」になる',
      body:
          'SNSでの発言は個人的なものであっても、勤務先が特定されれば会社の評判に直結します。'
          '実名を出していなくても、投稿写真の背景や普段の交友関係から勤務先が推測され、'
          '不適切な発言が「〇〇社の社員が炎上」として拡散される事例が後を絶ちません。'
          'プライベートの発信であっても、会社の看板を背負っているという意識を持つことが第一歩です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ethics_sns_2',
      moduleId: 'm_ethics_sns',
      title: 'よくある炎上パターン',
      body:
          '代表的な炎上パターンは、①顧客情報や社内の様子を許可なく投稿する、②取引先や同僚への不満・愚痴を書き込む、'
          '③アルバイト先で悪ふざけの動画を撮影・投稿する、の3つです。'
          'いずれも「身内だけが見ている」という思い込みから起きます。'
          'SNSの投稿はスクリーンショットで拡散され、後から削除しても意味がないことを理解しておきましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ethics_sns_3',
      moduleId: 'm_ethics_sns',
      title: '投稿前のセルフチェック',
      body:
          '投稿前に「これは家族や上司に見られても問題ないか」を自問する習慣をつけましょう。'
          '顧客・取引先が特定できる情報、社内の未公開情報、他者の顔が写った写真は特に注意が必要です。'
          '迷った場合は投稿しない、というシンプルなルールが最も効果的な防止策です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ethics_sns_4',
      moduleId: 'm_ethics_sns',
      title: '位置情報・誤情報の拡散に注意する',
      body:
          '写真に含まれる位置情報(ジオタグ)や背景の看板・景色から、自宅や勤務先が特定されてしまうことがあります。'
          'また、真偽を確かめないまま会社に関する噂やニュースをリポスト(拡散)すると、誤情報の拡散に加担してしまう場合もあります。'
          '投稿前には位置情報設定を確認し、情報の出所や事実関係を確かめる習慣を持ちましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_ethics_harassment': [
    Lesson(
      id: 'l_ethics_harassment_1',
      moduleId: 'm_ethics_harassment',
      title: 'ハラスメントの主な種類',
      body:
          '職場のハラスメントには、優越的な関係を背景にしたパワーハラスメント、性的な言動によるセクシュアルハラスメント、'
          '妊娠・出産・育児休業等に関するマタニティハラスメントなどがあります。'
          '「指導のつもり」「冗談のつもり」であっても、相手が不快に感じ、業務に支障が出ればハラスメントに該当し得ます。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ethics_harassment_2',
      moduleId: 'm_ethics_harassment',
      title: '発言者の意図より受け手の感じ方',
      body:
          'ハラスメントの判断で重要なのは、発言者の意図ではなく客観的に見て相手の尊厳を傷つけているかどうかです。'
          '同じ言葉でも関係性や状況によって受け取られ方が変わるため、'
          '相手との距離感を一方的に決めつけず、普段からの信頼関係の構築が予防につながります。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ethics_harassment_3',
      moduleId: 'm_ethics_harassment',
      title: '見かけたとき・受けたときの対応',
      body:
          '自分が受けた場合はもちろん、周囲でハラスメントらしき言動を見かけた場合も、'
          '一人で抱え込まず社内の相談窓口や上長に相談することが大切です。'
          '早期に共有することで、深刻化する前に会社として対応でき、被害の拡大を防げます。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ethics_harassment_4',
      moduleId: 'm_ethics_harassment',
      title: '顧客等からのハラスメント(カスタマーハラスメント)への対応',
      body:
          'ハラスメントは社内の人間関係だけでなく、顧客や取引先からの著しい迷惑行為(カスタマーハラスメント)としても発生します。'
          '暴言や過剰な要求、長時間の拘束などが該当し、従業員が一人で我慢し続ける必要はありません。'
          '会社としての対応方針に従い、上長や相談窓口に共有し、組織として対応することが大切です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_security_basics': [
    Lesson(
      id: 'l_security_basics_1',
      moduleId: 'm_security_basics',
      title: 'パスワードが破られる仕組み',
      body:
          '攻撃者は「よくある文字列」や「他社サービスから流出したパスワード」を大量に試す攻撃を行います。'
          '誕生日や会社名を含む単純なパスワード、複数サービスでの使い回しは非常に危険です。'
          '長く・推測されにくい・使い回さない、の3点がパスワード管理の基本です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_security_basics_2',
      moduleId: 'm_security_basics',
      title: '多要素認証(MFA)とは',
      body:
          '多要素認証は、パスワードに加えてスマートフォンアプリのコードや指紋など「別の要素」を組み合わせる仕組みです。'
          'パスワードが漏えいしても、もう一つの要素がなければログインできないため、'
          '不正アクセス対策として非常に効果が高く、業務システムでは積極的に有効化すべき機能です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_security_basics_3',
      moduleId: 'm_security_basics',
      title: '今日からできる対策',
      body:
          'パスワード管理アプリを使って複雑なパスワードを一元管理する、'
          '業務システムで多要素認証が使える場合は必ず有効にする、'
          '付箋にパスワードを書いてモニターに貼らない、といった基本を徹底しましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_security_basics_4',
      moduleId: 'm_security_basics',
      title: 'アカウント共有と退職・異動時の取り扱い',
      body:
          '複数人で1つのIDやパスワードを共有すると、誰が何を行ったのか特定できず、不正利用が起きても原因の追跡が難しくなります。'
          '異動や退職の際にアカウントを放置すると、権限が残ったままとなり不正アクセスの温床になります。'
          'アカウントは個人ごとに分け、異動・退職時は速やかに権限を見直しましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_security_phishing': [
    Lesson(
      id: 'l_security_phishing_1',
      moduleId: 'm_security_phishing',
      title: 'フィッシングメールの典型パターン',
      body:
          '「請求書の確認」「アカウント停止の警告」「荷物の不在通知」などを装い、'
          '偽サイトへのログインやファイルの実行を促すのが典型的な手口です。'
          '差出人名が取引先そっくりでも、実際のメールアドレスを確認すると不自然な文字列になっていることが多くあります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_security_phishing_2',
      moduleId: 'm_security_phishing',
      title: '標的型攻撃メールの怖さ',
      body:
          '標的型攻撃メールは、実在の取引先や上司になりすまし、業務に関係する自然な内容で送られてくるため見破りにくいのが特徴です。'
          '「至急対応してほしい」など緊急性を煽る文面や、普段と違うファイル形式の添付には特に注意しましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_security_phishing_3',
      moduleId: 'm_security_phishing',
      title: '受信したときの初動対応',
      body:
          '少しでも不審に感じたら、リンクや添付ファイルを開かず、電話など別の手段で送信元に事実確認をしましょう。'
          '万が一クリックしてしまった場合は、自己判断せずすぐに情報システム部門・上長に報告することが被害拡大の防止につながります。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_security_phishing_4',
      moduleId: 'm_security_phishing',
      title: 'メール以外のフィッシング手口(SMS・QRコード・電話)',
      body:
          'フィッシングはメールだけでなく、SMSを使った「スミッシング」、QRコードを悪用した「クイッシング」、電話を使った「ビッシング」など様々な経路で行われます。'
          '宅配便や金融機関を装うSMSや、貼り紙のQRコードにも注意が必要です。'
          '心当たりのない連絡を受けたら、公式サイトや正規の電話番号で改めて確認しましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_privacy_basics': [
    Lesson(
      id: 'l_privacy_basics_1',
      moduleId: 'm_privacy_basics',
      title: '個人情報とは何か',
      body:
          '個人情報とは、氏名・生年月日などにより特定の個人を識別できる情報を指します。'
          '病歴や犯罪歴などは「要配慮個人情報」として、より厳格な取り扱いが求められます。'
          '名刺やメールアドレスの一覧も個人情報に該当することを理解しておきましょう。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_privacy_basics_2',
      moduleId: 'm_privacy_basics',
      title: '取得・利用・提供の基本ルール',
      body:
          '個人情報を取得する際は利用目的を明示し、目的外の利用は原則できません。'
          '第三者へ提供する場合は、原則として本人の同意が必要です。'
          '社内で「なんとなく」共有・転用することが最も起こりやすい違反であり、注意が必要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_privacy_basics_3',
      moduleId: 'm_privacy_basics',
      title: '違反した場合の影響',
      body:
          '個人情報保護法違反は、行政からの指導・命令だけでなく、会社の信用失墜や損害賠償請求にもつながります。'
          '一人ひとりが「この情報は誰の同意のもとに使ってよいのか」を意識することが、会社全体を守ることになります。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_privacy_basics_4',
      moduleId: 'm_privacy_basics',
      title: '本人からの開示・訂正等の請求への対応',
      body:
          '個人情報保護法では、本人は自分の情報について開示・訂正・利用停止などを会社に請求する権利を持っています。'
          '請求を受けた際は正当な理由なく拒否せず、社内の窓口を通じて適切かつ速やかに対応することが求められます。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_privacy_customer': [
    Lesson(
      id: 'l_privacy_customer_1',
      moduleId: 'm_privacy_customer',
      title: '顧客名簿の安全管理措置',
      body:
          '顧客名簿は「必要な人だけがアクセスできる」状態を保つことが基本です。'
          '共有フォルダの権限設定、USBメモリでの持ち出し禁止、印刷した名簿の管理徹底など、'
          '技術的・物理的な安全管理措置を組み合わせて漏えいリスクを下げます。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_privacy_customer_2',
      moduleId: 'm_privacy_customer',
      title: '外部委託時の注意点',
      body:
          '顧客情報の処理を外部業者に委託する場合、委託先が適切に管理しているかを確認する義務が委託元にもあります。'
          '契約書に安全管理に関する条項を盛り込み、定期的な確認を行うことが望まれます。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_privacy_customer_3',
      moduleId: 'm_privacy_customer',
      title: '漏えい時の初動対応',
      body:
          '万が一情報漏えいが疑われる場合は、被害拡大防止のための初動対応(該当システムの遮断など)と、'
          '事実関係の記録、社内報告を同時並行で進めることが重要です。個人の判断で隠さず、必ず報告してください。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_privacy_customer_4',
      moduleId: 'm_privacy_customer',
      title: '問い合わせ対応時の本人確認の徹底',
      body:
          '電話やメールでの問い合わせ対応では、相手が本人や正当な代理人であるかを確認せずに個人情報を伝えてしまう事故が多く発生しています。'
          '氏名を名乗られただけで信用せず、生年月日や会員番号など複数の情報で本人確認を行うことが大切です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_infomgmt_document': [
    Lesson(
      id: 'l_infomgmt_document_1',
      moduleId: 'm_infomgmt_document',
      title: '情報の機密レベル分類',
      body:
          '社内文書は「社外秘」「関係者限り」「公開可」など機密レベルで分類し、'
          'レベルに応じたアクセス権限・保管方法を設定することで、不要な情報漏えいリスクを減らせます。'
          '分類ルールが曖昧だと、本来守るべき情報が誰でも見られる状態になりがちです。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_infomgmt_document_2',
      moduleId: 'm_infomgmt_document',
      title: '保存期間と廃棄のルール',
      body:
          '文書には法令や社内規程で定められた保存期間があります。'
          '期間を過ぎた文書は、シュレッダーや専用の廃棄業者を使って復元不可能な形で処分することが原則です。'
          '「とりあえず保管しておく」という判断が、不要な情報漏えいリスクを長期化させます。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_infomgmt_document_3',
      moduleId: 'm_infomgmt_document',
      title: 'クラウド共有の注意点',
      body:
          'クラウドストレージでの共有は便利な反面、共有リンクの設定次第で誰でも閲覧できる状態になり得ます。'
          '共有範囲を「社内のみ」「特定の相手のみ」に限定し、定期的に共有設定を見直す習慣をつけましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_infomgmt_document_4',
      moduleId: 'm_infomgmt_document',
      title: 'メール送信時の誤送信防止',
      body:
          '電子メールは複数の宛先へ同時に文書を送れる便利な手段ですが、宛先の入力ミスやCC・BCCの使い分け誤りにより、'
          '意図しない相手に機密文書を送ってしまう誤送信事故が後を絶ちません。'
          '送信前に宛先・添付ファイル・本文を必ず見直し、多数の社外関係者へ一斉送信する際はBCCを使用するなどの配慮が必要です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_infomgmt_incident': [
    Lesson(
      id: 'l_infomgmt_incident_1',
      moduleId: 'm_infomgmt_incident',
      title: 'インシデントとは何か',
      body:
          '情報漏えい、システム障害、不正アクセスなど、情報資産に影響を与える事象を「インシデント」と呼びます。'
          '小さな異常でも放置すると被害が拡大するため、「いつもと違う」と感じた時点で報告する意識が重要です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_infomgmt_incident_2',
      moduleId: 'm_infomgmt_incident',
      title: '初動対応の基本',
      body:
          '被害拡大を防ぐため、疑わしい端末をネットワークから切り離す、証拠となるログを保全する、'
          'といった初動対応が求められます。自己判断で復旧作業を進めず、まず所定の窓口へ連絡することが原則です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_infomgmt_incident_3',
      moduleId: 'm_infomgmt_incident',
      title: '報告フローの重要性',
      body:
          '誰に・どの経路で・どのタイミングで報告するかが事前に決まっていないと、対応が遅れ被害が拡大します。'
          '自分の役割と報告先を普段から確認しておくことが、いざという時の被害を最小限に抑えます。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_infomgmt_incident_4',
      moduleId: 'm_infomgmt_incident',
      title: 'インシデント収束後の振り返りと再発防止',
      body:
          'インシデントへの対応が一段落した後は、原因究明の結果をもとに再発防止策を検討し、社内で共有することが重要です。'
          '対応の過程を記録に残して振り返ることで、次に同様の事態が起きた際の対応スピードと精度を高めることができます。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_compliance_basics': [
    Lesson(
      id: 'l_compliance_basics_1',
      moduleId: 'm_compliance_basics',
      title: 'コンプライアンスとは',
      body:
          'コンプライアンスとは単なる法令遵守にとどまらず、社会規範や企業倫理に沿った行動を意味します。'
          '一人の不適切な行動が、会社全体の信用を大きく損なうことがあるため、日々の業務の中で意識することが重要です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_compliance_basics_2',
      moduleId: 'm_compliance_basics',
      title: '社内規程が存在する理由',
      body:
          '就業規則や各種マニュアルは、過去のトラブルや法改正を踏まえて整備されています。'
          '「面倒なルール」に見えても、その背景にあるリスクを理解することで、規程を守る納得感が生まれます。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_compliance_basics_3',
      moduleId: 'm_compliance_basics',
      title: '違反に気づいたときの行動',
      body:
          '自分や周囲の違反行為に気づいた場合、見て見ぬふりをすることも問題を深刻化させる一因です。'
          '内部通報窓口や上長への相談など、会社が用意している仕組みを積極的に活用しましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_compliance_basics_4',
      moduleId: 'm_compliance_basics',
      title: 'コンプライアンス違反が企業にもたらすリスク',
      body:
          'コンプライアンス違反が発覚すると、行政処分や罰則にとどまらず、取引先からの信用低下や契約解除、株価下落など会社全体に大きな影響が及びます。'
          '一人の軽率な行動が、多くの同僚の雇用や取引先との関係にまで影響を及ぼすことを理解しておく必要があります。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_compliance_labor': [
    Lesson(
      id: 'l_compliance_labor_1',
      moduleId: 'm_compliance_labor',
      title: '下請法の基本ルール',
      body:
          '下請法は、発注者が優越的な立場を利用して下請事業者に不利益を与えることを防ぐための法律です。'
          '代金の支払遅延や一方的な減額、不当なやり直し要求などが規制対象になります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_compliance_labor_2',
      moduleId: 'm_compliance_labor',
      title: '労働時間管理の基本',
      body:
          '長時間労働は従業員の健康を害するだけでなく、未払い残業代などの法的リスクにも直結します。'
          '勤怠は正確に記録し、上長は部下の労働時間を日常的に把握する責任があります。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_compliance_labor_3',
      moduleId: 'm_compliance_labor',
      title: '取引先との適正な関係構築',
      body:
          '取引先を「対等なパートナー」として扱う意識が、下請法違反や不適切な労務慣行を防ぐ土台になります。'
          '価格交渉や納期調整も、一方的な押し付けにならないよう配慮することが求められます。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_compliance_labor_4',
      moduleId: 'm_compliance_labor',
      title: '偽装請負に注意する',
      body:
          '業務委託契約でありながら、実態として発注者が受託会社の従業員に直接指揮命令を行う「偽装請負」は、労働者派遣法などの法令に違反するおそれがあります。'
          '契約形態と実際の業務の進め方に矛盾がないか、日頃から確認することが大切です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_ai_basics': [
    Lesson(
      id: 'l_ai_basics_1',
      moduleId: 'm_ai_basics',
      title: '生成AIでできること',
      body:
          '生成AIは、文章の要約・下書き作成、アイデア出し、簡単なコード生成など、幅広い業務の補助に活用できます。'
          '定型的な作業を効率化することで、人にしかできない判断業務に時間を使えるようになります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ai_basics_2',
      moduleId: 'm_ai_basics',
      title: 'AIの回答は「間違うことがある」',
      body:
          '生成AIはもっともらしい誤った情報(ハルシネーション)を出力することがあります。'
          '重要な業務判断や顧客への回答には、必ず人間による事実確認を挟むことが必要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ai_basics_3',
      moduleId: 'm_ai_basics',
      title: '業務での上手な付き合い方',
      body:
          'AIの出力を「たたき台」として扱い、最終判断は必ず人が行う、という役割分担を明確にしましょう。'
          '社内でAI活用ルールを共有し、属人的な使い方にならないようにすることも重要です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ai_basics_4',
      moduleId: 'm_ai_basics',
      title: '良い指示(プロンプト)の出し方',
      body:
          '生成AIは指示があいまいだと、期待した回答を返してくれないことがあります。'
          '目的や背景、欲しい形式などを具体的に伝えることで、より的確で業務に使いやすい回答を得やすくなります。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_ai_ethics': [
    Lesson(
      id: 'l_ai_ethics_1',
      moduleId: 'm_ai_ethics',
      title: '入力データが漏えいするリスク',
      body:
          '生成AIに顧客情報や社外秘情報を入力すると、サービスによっては学習データとして利用され、'
          '意図せず情報が外部に流出するリスクがあります。入力前に社内ルールを確認しましょう。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ai_ethics_2',
      moduleId: 'm_ai_ethics',
      title: '著作権侵害のリスク',
      body:
          'AIが生成した文章や画像が、既存の著作物と酷似してしまう場合があります。'
          '公開・商用利用する前に、既存作品との類似性を確認し、必要に応じて出典や利用条件を確認しましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ai_ethics_3',
      moduleId: 'm_ai_ethics',
      title: '安全に活用するためのチェックリスト',
      body:
          '「社外秘情報を入力していないか」「出力内容の事実確認をしたか」「著作権上問題ないか」の3点を、'
          'AI活用のたびに確認する習慣をつけることで、多くのリスクを未然に防ぐことができます。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ai_ethics_4',
      moduleId: 'm_ai_ethics',
      title: '未承認AIツールの利用(シャドーIT)によるリスク',
      body:
          '会社が把握していない無料のAIツールを個人の判断で業務に使うと、情報管理やセキュリティ対策が不十分なまま社外秘情報を扱ってしまう恐れがあります。'
          '業務で使うAIツールは、会社が許可したものを利用することが大切です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_ethics_customer': [
    Lesson(
      id: 'l_ethics_customer_1',
      moduleId: 'm_ethics_customer',
      title: 'クレーム対応の基本姿勢',
      body:
          'クレームを受けた際は、まず相手の話を最後まで聞き、不快な思いをさせたことに対して誠実に対応する姿勢が重要です。'
          '言い訳や反論を先にすると、相手の怒りをさらに強めてしまいます。'
          '事実確認と謝罪は分けて考え、まず気持ちに寄り添うことが信頼回復の第一歩です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ethics_customer_2',
      moduleId: 'm_ethics_customer',
      title: '言葉遣いが与える印象',
      body:
          '同じ内容を伝える場合でも、言葉遣い一つで相手の受け取り方は大きく変わります。'
          '「できません」ではなく「〇〇であれば対応可能です」といった代替案を示す言い方は、'
          '誠実さと前向きな姿勢を伝えることができます。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ethics_customer_3',
      moduleId: 'm_ethics_customer',
      title: '一人で抱え込まない',
      body:
          '対応が難しいクレームや、自分の裁量を超える要求を受けた場合は、無理に一人で解決しようとせず、'
          '早めに上長へエスカレーションすることが会社としての適切な対応につながります。'
          '誠実な対応と適切な報告・連携の両方が、顧客との信頼関係を支えます。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ethics_customer_4',
      moduleId: 'm_ethics_customer',
      title: '顧客情報の適切な管理と守秘義務',
      body:
          '電話やメールでの顧客対応では、氏名や契約内容を伝える前に本人確認を行い、誤った相手に情報を漏らさないよう注意が必要です。'
          'メールの宛先間違いや添付ファイルの誤送信も顧客情報の漏えいにつながります。'
          '業務で知り得た顧客情報をSNSや私的な会話で話題にしないなど、守秘義務を常に意識しましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_security_device': [
    Lesson(
      id: 'l_security_device_1',
      moduleId: 'm_security_device',
      title: '社外持ち出しの基本ルール',
      body:
          'ノートPCやスマートフォンを社外に持ち出す際は、画面ロックの設定、暗号化の有無、'
          '持ち出し申請の要否など、社内ルールに従うことが基本です。'
          'カフェや電車内での作業は、画面のぞき見や置き忘れのリスクが高いことを意識しましょう。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_security_device_2',
      moduleId: 'm_security_device',
      title: '紛失・盗難が起きる典型的な場面',
      body:
          '電車の網棚に荷物を置き忘れる、飲食店の席にスマートフォンを置いたまま離席するなど、'
          '一瞬の油断が紛失・盗難につながります。'
          '公共の場では常にデバイスを身につけるか、目の届く範囲に置く習慣が重要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_security_device_3',
      moduleId: 'm_security_device',
      title: '紛失・盗難時の初動対応',
      body:
          'デバイスを紛失・盗難された場合は、速やかに情報システム部門へ報告し、'
          'リモートロックやリモートワイプ(遠隔データ消去)などの対応を依頼することが被害拡大の防止につながります。'
          '「見つかるかもしれない」と様子を見て報告を遅らせることは避けましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_security_device_4',
      moduleId: 'm_security_device',
      title: '公共Wi-Fiと外部記憶媒体の取り扱い',
      body:
          'カフェや駅などの無料Wi-Fiは通信内容を盗み見られる恐れがあるため、業務での利用は避けるか、やむを得ない場合はVPNを使いましょう。'
          '出所不明のUSBメモリを安易にパソコンへ接続すると、ウイルス感染の原因になります。'
          '私物のUSBメモリやスマートフォンで業務データを扱う際も、会社のルールに従いましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_privacy_employee': [
    Lesson(
      id: 'l_privacy_employee_1',
      moduleId: 'm_privacy_employee',
      title: '人事情報の機密性',
      body:
          '人事評価、給与、健康診断結果、家族構成などの従業員情報は、非常に機密性の高い個人情報です。'
          '業務上必要な範囲を超えて閲覧・共有することは、たとえ社内であっても許されません。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_privacy_employee_2',
      moduleId: 'm_privacy_employee',
      title: '「知る必要がある人」だけがアクセスする原則',
      body:
          '人事データは、人事部門や直属の上長など、業務上「知る必要がある人」に限定してアクセス権を与えることが原則です。'
          '雑談の延長で同僚の評価や給与について話題にすることも避けるべき行為です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_privacy_employee_3',
      moduleId: 'm_privacy_employee',
      title: '健康情報の特別な配慮',
      body:
          '健康診断結果や病歴などの情報は要配慮個人情報に該当し、通常の人事情報よりもさらに厳格な管理が必要です。'
          '本人の同意なく上司や同僚に伝えることのないよう、特に注意しましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_privacy_employee_4',
      moduleId: 'm_privacy_employee',
      title: '退職者の個人情報の取り扱い',
      body:
          '退職した従業員の個人情報も、在職中と同様に適切な管理が必要です。'
          '源泉徴収や社会保険の手続きなど法令で必要な範囲を超えて保管や利用をしてはならず、'
          '不要になった書類は定めた保管期間の経過後に適切に廃棄します。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_infomgmt_access': [
    Lesson(
      id: 'l_infomgmt_access_1',
      moduleId: 'm_infomgmt_access',
      title: 'アクセス権限管理の重要性',
      body:
          '必要以上に広い権限を持つアカウントが多いほど、情報漏えいや誤操作のリスクは高まります。'
          '「業務に必要な最小限の権限だけを付与する」という原則を徹底することが基本です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_infomgmt_access_2',
      moduleId: 'm_infomgmt_access',
      title: '退職者・異動者アカウントの落とし穴',
      body:
          '退職者や異動者のアカウントが削除・権限変更されずに残っていると、'
          '本来アクセスできないはずの情報に触れられる状態が放置されてしまいます。'
          '人事異動のタイミングでの権限見直しをルール化することが重要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_infomgmt_access_3',
      moduleId: 'm_infomgmt_access',
      title: '定期的な棚卸しの実施',
      body:
          '半年や1年に一度など、定期的にアカウント・権限の棚卸しを行うことで、'
          '不要な権限の放置や設定ミスを早期に発見できます。'
          '棚卸しは面倒に感じても、情報漏えいリスクを大きく下げる効果的な取り組みです。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_infomgmt_access_4',
      moduleId: 'm_infomgmt_access',
      title: 'パスワード管理と多要素認証(MFA)',
      body:
          '簡単なパスワードの設定や複数システムでの使い回しは、不正アクセスの大きな原因となります。'
          'パスワードは推測されにくいものを設定した上で使い回しを避け、可能な場合はID・パスワードに加えて'
          'スマートフォンアプリ等で認証する多要素認証(MFA)を導入することで、不正アクセスのリスクを大幅に減らすことができます。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_compliance_bribery': [
    Lesson(
      id: 'l_compliance_bribery_1',
      moduleId: 'm_compliance_bribery',
      title: '贈収賄が問題となる理由',
      body:
          '取引先との会食や贈答が行き過ぎると、公正な取引をゆがめる「贈収賄」とみなされる可能性があります。'
          '発注や評価に影響を与えかねない高額な贈答・接待は、たとえ悪意がなくても問題視されます。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_compliance_bribery_2',
      moduleId: 'm_compliance_bribery',
      title: '社内ルールの確認が基本',
      body:
          '多くの会社では、接待交際費の上限額や、贈答品の金額の目安、事前申請の要否などを社内規程で定めています。'
          '「今までの慣習」だけに頼らず、最新の社内ルールを確認する習慣をつけましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_compliance_bribery_3',
      moduleId: 'm_compliance_bribery',
      title: '迷ったときの相談先',
      body:
          '接待や贈答の是非に迷った場合は、自己判断せず上長やコンプライアンス担当部署に事前相談することが望まれます。'
          '事前相談を徹底することが、会社と自分自身を不要なリスクから守ります。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_compliance_bribery_4',
      moduleId: 'm_compliance_bribery',
      title: '公務員等への接待・贈答は特に注意',
      body:
          '取引先の民間企業担当者だけでなく、公務員に対する接待や贈答は国家公務員倫理法などにより特に厳しく規制されています。'
          '少額であっても問題となる場合があるため、相手が公務員である場合は必ず事前に社内ルールを確認してください。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_ai_data': [
    Lesson(
      id: 'l_ai_data_1',
      moduleId: 'm_ai_data',
      title: '業務データ活用のメリット',
      body:
          '売上データや顧客の問い合わせ履歴をAIで分析することで、需要予測や業務改善のヒントを得ることができます。'
          '人手では気づきにくい傾向やパターンを発見できる点が、業務データ活用の大きな利点です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ai_data_2',
      moduleId: 'm_ai_data',
      title: 'データ活用における注意点',
      body:
          '業務データには顧客情報や従業員情報が含まれることが多く、AI分析に使う際も個人情報保護のルールが適用されます。'
          '匿名化・仮名化などの処理を行い、必要以上に個人が特定できる形でデータを扱わないようにしましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ai_data_3',
      moduleId: 'm_ai_data',
      title: '社内ガイドラインの必要性',
      body:
          'AI活用が個人の判断に委ねられていると、部署ごとにルールがばらつき、リスク管理が困難になります。'
          'どのデータを、どの範囲で、どのように活用してよいかを定めた社内ガイドラインを整備することが望まれます。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ai_data_4',
      moduleId: 'm_ai_data',
      title: 'AI分析結果に潜む偏り(バイアス)',
      body:
          'AIは学習データに偏りがあると、その偏りを反映した分析結果を出すことがあります。'
          '特定の属性に不利な判断をしてしまう可能性もあるため、分析結果をそのまま鵜呑みにせず、'
          '人が公平性の観点から確認することが重要です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ①情報モラル(追加)
  'm_ethics_remote': [
    Lesson(
      id: 'l_ethics_remote_1',
      moduleId: 'm_ethics_remote',
      title: 'オンライン会議での映り込みリスク',
      body:
          'Web会議のカメラには、背後の書類・ホワイトボードの記載・家族の様子まで映り込むことがあります。'
          '社外の相手が参加する会議では、機密資料が映らない場所・角度を選び、必要ならバーチャル背景を使いましょう。'
          '画面共有時も、関係のないウィンドウやチャット通知が映らないよう事前に閉じておくことが大切です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ethics_remote_2',
      moduleId: 'm_ethics_remote',
      title: '録画・録音への配慮',
      body:
          '会議を録画・録音する際は、開始前に参加者全員へ目的と用途を伝え、同意を得るのがマナーです。'
          '無断での録画は相手に不信感を与えるだけでなく、発言者の意図しない形で内容が共有されるリスクもあります。'
          '録画データは会議関係者以外がアクセスできない場所に保存し、不要になれば削除しましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ethics_remote_3',
      moduleId: 'm_ethics_remote',
      title: 'リモートワーク中に気をつけたいこと',
      body:
          'カフェや新幹線など公共の場でWeb会議に参加すると、会話内容や画面が周囲に漏れる恐れがあります。'
          '社外秘の話題がある会議は、個室や自宅など人の目・耳を気にせずに済む環境で参加しましょう。'
          '離席時は画面ロックを忘れず、家族や同居者にも会社の情報が見えないよう配慮することが基本です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ethics_remote_4',
      moduleId: 'm_ethics_remote',
      title: 'チャットツールでのコミュニケーションマナー',
      body:
          'テキストだけのやり取りは表情や声の調子が伝わらないため、意図せず冷たい印象を与えたり誤解を招いたりすることがあります。'
          '深夜や早朝に緊急でない連絡を送ると相手の休息時間を妨げる場合もあります。'
          '絵文字や一言を添えて柔らかい表現を心がけ、送信時間にも配慮することが円滑なコミュニケーションにつながります。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ②セキュリティ(追加)
  'm_security_ransomware': [
    Lesson(
      id: 'l_security_ransomware_1',
      moduleId: 'm_security_ransomware',
      title: 'ランサムウェアとは',
      body:
          'ランサムウェアは、感染するとファイルを勝手に暗号化して使えなくし、元に戻す代わりに身代金を要求するマルウェアです。'
          '不審なメールの添付ファイルを開く、偽サイトからソフトをダウンロードする、といった経路で感染することが多く、'
          '一度感染すると業務が完全に停止してしまう深刻な被害につながります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_security_ransomware_2',
      moduleId: 'm_security_ransomware',
      title: 'バックアップが最大の防御',
      body:
          'ランサムウェア被害からの復旧で最も重要なのは、日頃からの定期的なバックアップです。'
          'データを2種類以上の媒体に保存し、うち1つは社内ネットワークから切り離した場所に保管する、という考え方が基本とされています。'
          'ネットワークにつながったままのバックアップは、それ自体も暗号化される危険があるため注意が必要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_security_ransomware_3',
      moduleId: 'm_security_ransomware',
      title: '感染してしまったら',
      body:
          '感染が疑われるパソコンは、被害拡大を防ぐため直ちにネットワークから切り離し(LANケーブルを抜く・Wi-Fiを切る)、'
          '速やかに情報システム部門や管理者へ報告してください。'
          '身代金を支払っても復旧する保証はなく、犯罪者への資金提供にもなるため、自己判断で支払わないことが原則です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_security_ransomware_4',
      moduleId: 'm_security_ransomware',
      title: '二重恐喝の手口と組織としての備え',
      body:
          '近年のランサムウェアは、ファイルを暗号化するだけでなく事前に情報を盗み出し、「支払わなければ公開する」と脅す二重恐喝が主流になっています。'
          '取引先やソフトウェアの更新経路を悪用したサプライチェーン攻撃にも注意が必要です。'
          '日頃から緊急連絡体制や対応手順を確認し、訓練を通じて備えておくことが被害の拡大を防ぎます。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ③個人情報保護(追加)
  'm_privacy_mynumber': [
    Lesson(
      id: 'l_privacy_mynumber_1',
      moduleId: 'm_privacy_mynumber',
      title: 'マイナンバーは特に厳格な管理が必要',
      body:
          'マイナンバー(個人番号)は「特定個人情報」として、通常の個人情報よりも厳しい法律上の規制が定められています。'
          '税務・社会保険の手続きなど法律で定められた目的以外には利用できず、目的外の利用は認められません。'
          '取り扱う担当者を限定し、他の書類とは分けて管理することが求められます。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_privacy_mynumber_2',
      moduleId: 'm_privacy_mynumber',
      title: '収集・保管のルール',
      body:
          '従業員からマイナンバーを収集する際は、利用目的を明示したうえで、必要な範囲だけを取得します。'
          '保管する書類は鍵のかかるキャビネットに、電子データはアクセス制限やパスワードを設定して管理し、'
          '担当者以外が閲覧できない状態を維持することが基本です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_privacy_mynumber_3',
      moduleId: 'm_privacy_mynumber',
      title: '不要になったら確実に廃棄する',
      body:
          '雇用契約の終了など、マイナンバーが必要なくなった場合は、法律で定められた保管期間の経過後、速やかに廃棄しなければなりません。'
          '紙の書類はシュレッダーで裁断し、電子データは復元できない方法で消去します。'
          '「念のため」といって漫然と保管し続けることは、法令違反につながるため避けましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_privacy_mynumber_4',
      moduleId: 'm_privacy_mynumber',
      title: '取得時に行う本人確認の二段階チェック',
      body:
          'マイナンバーを取得する際は、番号が正しいかを確認する「番号確認」と、なりすましを防ぐための「身元確認」の両方を行う必要があります。'
          'マイナンバーカードがあれば1枚で両方を確認でき、ない場合は通知カードと運転免許証など複数書類の組み合わせで確認します。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ④情報マネジメント(追加)
  'm_infomgmt_byod': [
    Lesson(
      id: 'l_infomgmt_byod_1',
      moduleId: 'm_infomgmt_byod',
      title: 'BYODのメリットとリスク',
      body:
          'BYOD(Bring Your Own Device)とは、私物のスマートフォンやパソコンを業務に利用することです。'
          '会社支給の端末を持ち歩かずに済む利便性がある一方、私物端末は会社の管理が及びにくく、'
          '紛失・盗難時の情報漏えいやウイルス感染のリスクが高まる点に注意が必要です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_infomgmt_byod_2',
      moduleId: 'm_infomgmt_byod',
      title: '私物端末を使う際に守るべきルール',
      body:
          '会社のファイルを私物端末の個人用クラウドストレージに保存したり、個人のメールアドレスに転送したりしてはいけません。'
          '画面ロック(パスコードや生体認証)を必ず設定し、OSやアプリは常に最新の状態に保ちましょう。'
          '公衆Wi-Fiでの業務データのやり取りも避けるべきです。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_infomgmt_byod_3',
      moduleId: 'm_infomgmt_byod',
      title: '退職・機種変更時の対応',
      body:
          '私物端末に会社のデータやアプリを入れていた場合、退職時や機種変更時には確実にデータを削除する必要があります。'
          '会社がMDM(モバイル端末管理)ツールを導入している場合は、リモートでのデータ消去に協力してください。'
          '「消したはず」ではなく、削除できたことを確認するまでが対応の完了です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_infomgmt_byod_4',
      moduleId: 'm_infomgmt_byod',
      title: '公衆Wi-Fi利用と業務アプリのインストールに関する注意',
      body:
          'カフェや駅など誰でも使える公衆Wi-Fiは通信内容を盗み見られる危険があるため、私物端末で業務データを扱う際はむやみに接続せず、'
          'VPN接続や信頼できる回線を利用することが大切です。'
          'また出所不明のアプリのインストールはマルウェア感染の原因となるため、業務利用端末には許可されたアプリのみを入れるようにしましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ⑤コンプライアンス(追加)
  'm_compliance_insider': [
    Lesson(
      id: 'l_compliance_insider_1',
      moduleId: 'm_compliance_insider',
      title: 'インサイダー取引とは',
      body:
          '取引先の合併や決算情報など、公表前の重要な会社情報(未公開情報)を知る立場で、'
          'その情報をもとに関連会社の株式を売買することはインサイダー取引として法律で禁止されています。'
          '本人だけでなく、その情報を家族や知人に伝えて取引させることも同様に処罰の対象です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_compliance_insider_2',
      moduleId: 'm_compliance_insider',
      title: '利益相反とは',
      body:
          '利益相反とは、会社の利益と自分自身(または家族)の利益がぶつかる状況のことです。'
          '例えば、自分が経営に関わる会社を取引先として選んだり、副業先の利益を優先して会社の意思決定を歪めたりする行為が該当します。'
          '個人的な利害関係がある取引には関与せず、事前に会社へ申告することが求められます。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_compliance_insider_3',
      moduleId: 'm_compliance_insider',
      title: '疑わしい場面での行動指針',
      body:
          '未公表の重要情報を偶然知ってしまった場合は、その情報が公表されるまで関連する株式の売買を控えてください。'
          '取引先との関係で個人的な利害が生じそうな場合は、自己判断で進めず、必ず上長やコンプライアンス担当へ事前に相談・申告しましょう。'
          '「バレなければ大丈夫」という考えが、会社全体の信用を損なう重大な問題に発展します。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_compliance_insider_4',
      moduleId: 'm_compliance_insider',
      title: '重要情報の管理と情報漏えい防止',
      body:
          '未公表の重要な会社情報は、業務上必要な範囲を超えて社内外に話したり、SNSに投稿したりしてはいけません。'
          '家族や友人への何気ない会話がインサイダー取引や情報漏えいにつながるおそれがあるため、情報管理には常に注意が必要です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ⑥AI活用(追加)
  'm_ai_deepfake': [
    Lesson(
      id: 'l_ai_deepfake_1',
      moduleId: 'm_ai_deepfake',
      title: 'ディープフェイクとは',
      body:
          'ディープフェイクとは、AIによって作られた本物そっくりの偽の画像・音声・動画のことです。'
          '経営者の声を模倣した偽の音声で緊急送金を指示する詐欺や、実在の人物になりすました偽動画による詐欺被害が'
          '国内外で報告されており、誰にとっても無関係ではないリスクとなっています。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ai_deepfake_2',
      moduleId: 'm_ai_deepfake',
      title: '見抜くためのポイント',
      body:
          'AI生成音声・動画は技術的に精度が向上していますが、不自然な瞬きの少なさ・口の動きと音声のわずかなズレ、'
          '感情がこもらない機械的な話し方などの違和感が残ることがあります。'
          'また「今すぐ」「他言無用」など、冷静に確認する時間を与えず急がせる手口には特に警戒しましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ai_deepfake_3',
      moduleId: 'm_ai_deepfake',
      title: '不審な連絡を受けたときの対応',
      body:
          '経営者や上司からの緊急指示に見える連絡を受けた場合でも、電話やメッセージの内容だけで即断せず、'
          '普段使っている別の連絡手段(社内システムや対面など)で本人に事実確認を取りましょう。'
          '確認が取れるまで送金や情報開示などの重要な対応は保留し、一人で抱え込まず周囲に相談することが被害防止の鍵です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ai_deepfake_4',
      moduleId: 'm_ai_deepfake',
      title: 'ディープフェイク詐欺への事前対策',
      body:
          '経営者になりすます詐欺に備え、社内で「合言葉」を決めておく、送金や重要な意思決定は複数人の承認を必須にするなど、'
          '事前にルールを整備しておくことが被害防止に有効です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ①情報モラル(5つ目)
  'm_ethics_copyright': [
    Lesson(
      id: 'l_ethics_copyright_1',
      moduleId: 'm_ethics_copyright',
      title: '他社の文章や画像を無断で使うリスク',
      body:
          '業務資料や自社サイト作成時に他社サイトの文章や画像をそのままコピーして使うと、社内用の一部であっても著作権侵害にあたる可能性があります。'
          '実際に他社ブログの文章を転用してSNSで批判を受けた企業もあります。'
          '「参考にする」つもりでも文章や画像をそのまま複製すれば違法となり得るため、必ずオリジナルで作成するか許諾を得ることが大切です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ethics_copyright_2',
      moduleId: 'm_ethics_copyright',
      title: 'フリー素材と有償素材の違いを理解する',
      body:
          '「フリー素材」と表示されていても、商用利用不可やクレジット表記必須など細かい利用条件が定められている場合があります。'
          '有償素材を契約範囲外の媒体で無断使用し、後から使用料を請求された事例もあります。'
          '素材を使う際は必ず利用規約(ライセンス)を確認し、条件に合わない場合は別の素材を選ぶか許諾を得ましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ethics_copyright_3',
      moduleId: 'm_ethics_copyright',
      title: 'SNS投稿で気をつけたい肖像権',
      body:
          '社内イベントや店舗の様子をSNSに投稿する際、写り込んだ同僚や来店客の顔がそのまま公開されると、本人の肖像権を侵害するおそれがあります。'
          '無断で撮影・掲載された写真を削除してほしいと苦情が寄せられた例もあります。'
          '投稿前に本人の同意を得るか、顔にぼかしを入れるなどの配慮を行いましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ethics_copyright_4',
      moduleId: 'm_ethics_copyright',
      title: '正しい引用のルールとまとめ',
      body:
          '他社の文章を紹介する際は、出典を明記し、自分の文章が主で引用部分が従となる関係を保つことが著作権法上の「引用」の条件です。'
          '出典を書かずに他サイトの文章を丸ごと掲載すると、引用ではなく無断転載とみなされます。'
          '著作権・肖像権は「知らなかった」では済まされないため、迷ったら使用前に確認する習慣を持ちましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ②セキュリティ(5つ目)
  'm_security_patch': [
    Lesson(
      id: 'l_security_patch_1',
      moduleId: 'm_security_patch',
      title: '脆弱性とは何か',
      body:
          '脆弱性とは、ソフトウェアの設計や実装に存在する欠陥のことです。'
          '悪意のある第三者に悪用されると、不正アクセスや情報漏えい、ウイルス感染などの被害につながります。'
          '脆弱性は日々新たに発見されており、開発元は修正プログラム(パッチ)を提供して対応しています。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_security_patch_2',
      moduleId: 'm_security_patch',
      title: '更新を放置するリスク',
      body:
          '修正済みの脆弱性を狙う攻撃は、手口がすでに広く知られているため被害が拡大しやすいという特徴があります。'
          '更新の通知を「あとで」と先延ばしにすることは、鍵の壊れた扉をそのまま放置しているのと同じ状態です。'
          '放置期間が長いほど攻撃を受ける危険性は高まります。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_security_patch_3',
      moduleId: 'm_security_patch',
      title: '自動更新の活用',
      body:
          'OSやブラウザ、業務アプリの多くには自動更新の機能があり、有効にしておくことで更新忘れを防げます。'
          '更新のための再起動を求められた際は、後回しにせず業務に支障のないタイミングで速やかに反映しましょう。'
          '手動更新に頼らない仕組みづくりが安全性を高めます。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_security_patch_4',
      moduleId: 'm_security_patch',
      title: 'サポート終了ソフトへの対応',
      body:
          '開発元によるサポートが終了したソフトウェアは、新たな脆弱性が見つかっても修正が提供されず、使い続けるほど危険性が高まります。'
          '業務システムでサポート終了が近いソフトを見つけた場合は、自己判断せず情報システム部門へ報告し、更新や移行の計画を確認しましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ③個人情報保護(5つ目)
  'm_privacy_outsourcing': [
    Lesson(
      id: 'l_privacy_outsourcing_1',
      moduleId: 'm_privacy_outsourcing',
      title: '委託先を選ぶときに確認すべきこと',
      body:
          '個人情報の取り扱いを外部に委託する際は、委託先が十分な安全管理体制を持っているかを事前に確認する必要があります。'
          '過去の実績やセキュリティ対策の状況、担当者の教育体制などを確認し、委託先の選定段階からリスクを見極めることが重要です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_privacy_outsourcing_2',
      moduleId: 'm_privacy_outsourcing',
      title: '委託契約に安全管理条項を盛り込む',
      body:
          '個人情報保護法では、委託者は委託先に対して必要かつ適切な監督を行う義務があります。'
          '委託契約書には安全管理措置の内容、目的外利用の禁止、漏えい時の報告義務、契約終了後のデータ返却・消去などを明記し、'
          '口頭の合意だけに頼らないようにしましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_privacy_outsourcing_3',
      moduleId: 'm_privacy_outsourcing',
      title: 'クラウドサービス利用時の注意点',
      body:
          'クラウドサービスに個人情報を保存する場合は、利用規約でサーバーの設置国やデータの取り扱い方針を確認することが大切です。'
          '海外にサーバーがあると外国の法律の適用を受ける可能性もあるため、契約前に法務担当や情報システム部門に相談しましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_privacy_outsourcing_4',
      moduleId: 'm_privacy_outsourcing',
      title: '再委託(孫請け)の管理も忘れずに',
      body:
          '委託先がさらに別の業者に業務を再委託する場合、委託元の会社は再委託先まで含めて安全管理体制を把握しておく必要があります。'
          '再委託を行う際は事前の承諾を条件とするなど、契約段階で再委託のルールを明確にしておきましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ④情報マネジメント(5つ目)
  'm_infomgmt_office': [
    Lesson(
      id: 'l_infomgmt_office_1',
      moduleId: 'm_infomgmt_office',
      title: 'FAXの誤送信を防ぐには',
      body:
          'FAXは宛先を手入力や短縮ダイヤルで指定するため、番号の押し間違いや古い短縮ダイヤル登録により誤送信が起こりやすい通信手段です。'
          '送信前に宛先番号を目視で再確認し、重要書類は送信後に相手へ電話で着信確認を行うことが有効です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_infomgmt_office_2',
      moduleId: 'm_infomgmt_office',
      title: '複合機のハードディスクに残るデータ',
      body:
          '複合機(コピー機)には印刷・コピー・スキャンした文書の画像データが内蔵ハードディスクに一時的に保存される仕組みがあり、'
          '消去せずに廃棄・返却するとデータが第三者に読み取られる危険があります。'
          'リース契約終了や機器入れ替えの際は、必ずデータ消去を業者に依頼し、証明書を受け取るようにしましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_infomgmt_office_3',
      moduleId: 'm_infomgmt_office',
      title: '印刷物の取り忘れに注意',
      body:
          'プリンターや複合機に出力した書類をその場で受け取らず放置すると、他部署の人や来訪者の目に触れたり持ち去られたりするおそれがあります。'
          '個人認証で出力するセキュアプリント機能の活用や、印刷物はすぐに取りに行く習慣づけが情報漏えい防止につながります。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_infomgmt_office_4',
      moduleId: 'm_infomgmt_office',
      title: 'シュレッダーと機密文書回収ボックスの活用',
      body:
          '不要になった機密文書をそのままゴミ箱に捨てると、外部からの覗き見や持ち去りにより情報が漏えいする可能性があります。'
          'オフィスに設置されたシュレッダーや施錠式の機密文書回収ボックスを利用し、専門業者による溶解処理などの確実な廃棄ルートを使うことが重要です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ⑤コンプライアンス(5つ目)
  'm_compliance_antisocial': [
    Lesson(
      id: 'l_compliance_antisocial_1',
      moduleId: 'm_compliance_antisocial',
      title: '反社会的勢力とは何か',
      body:
          '反社会的勢力とは、暴力団やその関係者など、暴力的な要求行為や不当な要求によって経済的利益を得ようとする集団・個人を指します。'
          '全国の暴力団排除条例により、企業は反社会的勢力との取引や関係を遮断する責務を負っており、'
          '一度でも関係を持てば会社の信用が大きく損なわれます。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_compliance_antisocial_2',
      moduleId: 'm_compliance_antisocial',
      title: '新規取引先の反社チェック',
      body:
          '新規の取引先や契約相手とは、契約前に反社チェックサービスやデータベースを利用し、反社会的勢力に該当しないかを確認します。'
          'あわせて契約書に暴力団排除条項(暴排条項)を盛り込み、該当した場合に契約を解除できるようにしておくことが重要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_compliance_antisocial_3',
      moduleId: 'm_compliance_antisocial',
      title: '不当要求を受けた場合の対応',
      body:
          '取引先や来訪者から脅迫的な言動や不当な要求を受けても、担当者が一人で対応したりその場で約束・譲歩をしてはいけません。'
          '速やかに上長へ報告し、警察や顧問弁護士など専門機関に相談して、組織として対応することが基本です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_compliance_antisocial_4',
      moduleId: 'm_compliance_antisocial',
      title: '取引開始後に判明した場合の対応',
      body:
          '取引を開始した後に相手が反社会的勢力であると判明した場合は、直ちに上長やコンプライアンス担当部署へ報告し、'
          '暴排条項に基づいて速やかに取引を解消します。'
          '穏便に済ませようと自己判断せず、会社として組織的に対応することが求められます。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ⑥AI活用(5つ目)
  'm_ai_customer': [
    Lesson(
      id: 'l_ai_customer_1',
      moduleId: 'm_ai_customer',
      title: 'AIチャットボット導入のメリット',
      body:
          'AIチャットボットは24時間365日、休みなく顧客からの問い合わせに対応できます。'
          'よくある質問への一次対応をAIが担うことで、担当者は複雑な相談やクレーム対応など、人の判断が必要な業務に集中できるようになります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_ai_customer_2',
      moduleId: 'm_ai_customer',
      title: 'AIの誤回答が招く顧客トラブル',
      body:
          'AIチャットボットは学習データにない質問や複雑な事情に対して、事実と異なる案内をしてしまうことがあります。'
          '誤った回答をそのまま信じた顧客とのトラブルに発展する恐れがあるため、回答内容の定期的な点検が欠かせません。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_ai_customer_3',
      moduleId: 'm_ai_customer',
      title: '人へのエスカレーション基準の重要性',
      body:
          'クレームや契約変更、金銭が関わる相談など、AIだけでは対応しきれない場面では、速やかに人の担当者へ引き継ぐ基準をあらかじめ決めておく必要があります。'
          '基準が曖昧だと顧客の不満を長引かせる原因になります。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_ai_customer_4',
      moduleId: 'm_ai_customer',
      title: 'AI対応であることの適切な開示',
      body:
          '顧客と対応しているのがAIか人かを偽ったり、あいまいにしたりすることは信頼を損ないます。'
          'チャット開始時に「AIが対応しています」と明示し、必要に応じて人による対応へ切り替えられる案内をしておくことが望まれます。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ⑦メンタルヘルス・健康経営
  'm_mental_selfcare': [
    Lesson(
      id: 'l_mental_selfcare_1',
      moduleId: 'm_mental_selfcare',
      title: 'ストレスのサインに気づく',
      body:
          'ストレスは誰にでも起こる自然な反応です。睡眠の質の低下、食欲の変化、集中力の低下、いつもならしないミスの増加などは、心身からの重要なサインです。'
          '「気合で乗り切れる」と我慢を続けると不調が進行しやすいため、小さな変化に早めに気づくことが最初の一歩です。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_mental_selfcare_2',
      moduleId: 'm_mental_selfcare',
      title: 'ストレスチェック制度を知る',
      body:
          '労働者50人以上の事業場では、年1回のストレスチェックの実施が法律で義務付けられています。'
          '結果は本人に直接通知され、会社が同意なく閲覧することはできません。'
          '高ストレスと判定された場合は、希望すれば医師による面接指導を無料で受けられます。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_mental_selfcare_3',
      moduleId: 'm_mental_selfcare',
      title: '日常のセルフケア習慣',
      body:
          '十分な睡眠、規則正しい食事、適度な運動は、ストレスへの耐性を高める基本です。'
          '深呼吸や軽いストレッチ、趣味の時間を意識的に確保するなど、自分に合ったリラクゼーション方法を複数持っておくと、'
          '忙しい時期でも心身のバランスを保ちやすくなります。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_mental_selfcare_4',
      moduleId: 'm_mental_selfcare',
      title: '相談窓口を活用する',
      body:
          '不調を感じたら一人で抱え込まず、産業医や保健師、外部のEAP(従業員支援プログラム)などの相談窓口を早めに利用しましょう。'
          '相談内容の秘密は守られ、利用したことで人事評価が下がることもありません。'
          '早期の相談が、深刻化を防ぐ最も確実な方法です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_mental_linecare': [
    Lesson(
      id: 'l_mental_linecare_1',
      moduleId: 'm_mental_linecare',
      title: '「いつもと違う」に気づく',
      body:
          '部下の「いつもと違う」様子は不調の初期サインです。遅刻や欠勤の増加、表情の暗さ、業務ミスの増加、周囲との会話の減少などに気づいたら、'
          'それは見過ごさず声をかけるべきタイミングです。日頃から部下の通常の状態を把握しておくことが、変化への気づきにつながります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_mental_linecare_2',
      moduleId: 'm_mental_linecare',
      title: '声のかけ方の基本',
      body:
          '声をかける際は、業務の話ではなく「最近眠れているか」など体調を気遣う言葉から始めましょう。'
          '決めつけや詰問は避け、相手の話をさえぎらずに聴く姿勢が大切です。'
          '場所やタイミングにも配慮し、周囲に内容が漏れないプライベートな環境を選びましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_mental_linecare_3',
      moduleId: 'm_mental_linecare',
      title: '専門家へ繋ぐ',
      body:
          '上長だけで抱え込まず、産業医や保健師、人事部門、外部のEAPなど専門家へ早めに繋ぐことがラインケアの重要な役割です。'
          '「専門家に相談してみないか」と提案するだけでも、本人の負担を大きく減らせます。専門的な判断や治療は専門家に委ねましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_mental_linecare_4',
      moduleId: 'm_mental_linecare',
      title: '組織で支える・自分も守る',
      body:
          '部下の不調対応は上長一人の責任ではありません。対応に迷ったら人事や産業保健スタッフに相談し、組織として支えることが基本です。'
          'また、部下を支える上長自身が疲弊しないよう、自分自身のセルフケアや相談も忘れずに行いましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_mental_overwork': [
    Lesson(
      id: 'l_mental_overwork_1',
      moduleId: 'm_mental_overwork',
      title: '長時間労働がもたらす健康リスク',
      body:
          '長時間労働が続くと、睡眠不足や疲労の蓄積により、心疾患や脳血管疾患、メンタル不調のリスクが高まることが医学的にも知られています。'
          '過重労働は個人の頑張りだけで乗り切れる問題ではなく、健康を損なう前に業務量そのものを見直す視点が欠かせません。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_mental_overwork_2',
      moduleId: 'm_mental_overwork',
      title: '時間外労働と健康リスクの目安',
      body:
          '医学的な知見では、時間外・休日労働がおおむね月80時間を超えると健康障害のリスクが高まり、月100時間に近づくとさらにリスクが増すとされています。'
          'これは疲労の蓄積度合いを示す一つの目安であり、この水準に近づく前に業務分担の見直しが必要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_mental_overwork_3',
      moduleId: 'm_mental_overwork',
      title: '上長による早期の業務調整',
      body:
          '上長は部下の労働時間の推移を日頃から把握し、時間外労働が増加傾向にある部下には早めに声をかけ、業務量の調整や応援体制の検討を行うことが求められます。'
          '「本人が頑張っているから」と放置せず、組織として業務の偏りを是正する姿勢が重要です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_mental_overwork_4',
      moduleId: 'm_mental_overwork',
      title: '疲労蓄積のサインと休養',
      body:
          '慢性的な疲労は、だるさが取れない、休日も回復しない、ミスが増えるといった形で現れます。'
          'こうしたサインが見られたら、十分な休養を取れる環境を整えることが優先されます。'
          '疲労は「見えにくいリスク」であるからこそ、周囲が気づき対応する仕組みが必要です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_mental_return': [
    Lesson(
      id: 'l_mental_return_1',
      moduleId: 'm_mental_return',
      title: '休職中の連絡への配慮',
      body:
          '休職中の従業員への連絡は、療養を妨げないよう配慮が必要です。過度な業務連絡は控えつつ、給与や手続きに関する必要な連絡は定期的に行い、'
          '本人に「見捨てられていない」という安心感を持ってもらうことが大切です。連絡の頻度や方法は事前に本人と相談して決めましょう。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_mental_return_2',
      moduleId: 'm_mental_return',
      title: '復職判定の考え方',
      body:
          '復職の可否は、主治医の診断書だけでなく、産業医が本人と面談し、実際の業務に耐えられる状態かを総合的に判断することが望まれます。'
          '「主治医が復職可としたら即現場復帰」ではなく、職場の状況も踏まえた段階的な判断が重要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_mental_return_3',
      moduleId: 'm_mental_return',
      title: '試し出勤制度の考え方',
      body:
          '試し出勤制度は、本格的な復職の前に短時間勤務や軽作業から始め、段階的に元の業務に近づけていく仕組みです。'
          '無理に元の業務量へ一気に戻すと再発のリスクが高まるため、本人の状態を見ながら勤務時間や業務内容を段階的に調整することが再発防止につながります。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_mental_return_4',
      moduleId: 'm_mental_return',
      title: '周囲の理解とサポート体制',
      body:
          '復職した従業員が孤立しないよう、上長や同僚が状況を理解し、当面の業務量や役割を調整するなど職場全体でサポートする体制が必要です。'
          '特別扱いのしすぎもかえって負担になる場合があるため、本人・産業医・人事で情報を共有しながら適切な受け入れ方を検討しましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_mental_psychsafety': [
    Lesson(
      id: 'l_mental_psychsafety_1',
      moduleId: 'm_mental_psychsafety',
      title: '心理的安全性とは',
      body:
          '心理的安全性とは、チームの中で自分の意見や懸念、疑問を発言しても、否定されたり評価が下がったりしないという安心感を指します。'
          'Googleの調査でも、心理的安全性の高いチームほど成果を出しやすいことが示されており、良い職場文化の基盤として注目されています。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_mental_psychsafety_2',
      moduleId: 'm_mental_psychsafety',
      title: '失敗を責めない文化',
      body:
          '失敗が起きた際に「誰が悪いか」を追及するのではなく、「なぜ起きたのか」「次にどう防ぐか」を建設的に振り返る文化が、心理的安全性を育てます。'
          '失敗を過度に責める雰囲気があると、メンバーは問題やミスを報告しづらくなり、かえって深刻な事態を招きかねません。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_mental_psychsafety_3',
      moduleId: 'm_mental_psychsafety',
      title: '1on1の活用',
      body:
          '定期的な1on1ミーティングは、上長と部下が業務の進捗だけでなく、悩みやキャリアの考えを気軽に話せる場として有効です。'
          '上長が聴く姿勢に徹し、部下の話をさえぎらず受け止めることで、日頃言いにくい懸念も表に出やすくなります。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_mental_psychsafety_4',
      moduleId: 'm_mental_psychsafety',
      title: '日常のフィードバック習慣',
      body:
          '日常的に「良かった点」と「改善点」を率直に伝え合うフィードバック習慣は、信頼関係の土台になります。'
          '評価のタイミングだけでなく、日々の業務の中でこまめに声をかけ合うことで、意見を言いやすい雰囲気が自然と醸成されていきます。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ⑧BCP・危機管理/防災
  'm_bcp_basics': [
    Lesson(
      id: 'l_bcp_basics_1',
      moduleId: 'm_bcp_basics',
      title: 'BCPとは何か',
      body:
          'BCP(事業継続計画)とは、地震や感染症などの緊急事態が発生した際にも、重要な事業を中断させない、または中断しても早期に復旧させるための方針や体制をあらかじめ定めておく計画です。'
          '企業の存続と従業員・取引先の安心を守る土台となります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_bcp_basics_2',
      moduleId: 'm_bcp_basics',
      title: '中小企業の策定率が低い現状',
      body:
          '内閣府の調査では、大企業のBCP策定率は7割超に対し、中小企業は3割程度にとどまります。'
          '「人手や時間が足りない」「何から始めればよいかわからない」という声が多く、未策定のまま被災すると廃業に至るケースも少なくありません。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_bcp_basics_3',
      moduleId: 'm_bcp_basics',
      title: '重要業務の洗い出し',
      body:
          'BCP策定の第一歩は、自社の事業の中から「止めてはいけない重要業務」を洗い出すことです。'
          'すべての業務を平時と同じ水準で継続するのは困難なため、売上や取引先への影響が大きい業務から優先順位をつけて対応を検討します。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_bcp_basics_4',
      moduleId: 'm_bcp_basics',
      title: '目標復旧時間(RTO)の考え方',
      body:
          '目標復旧時間(RTO)とは、重要業務を「発災から何時間・何日以内に復旧させるか」という目標です。'
          'RTOを設定することで、必要な人員・設備・代替手段の準備水準が明確になり、実効性のあるBCPにつながります。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_bcp_disaster': [
    Lesson(
      id: 'l_bcp_disaster_1',
      moduleId: 'm_bcp_disaster',
      title: '防災用品・備蓄の準備',
      body:
          '地震や水害などの災害発生時には、ライフラインの停止や交通の混乱で従業員が帰宅困難になることがあります。'
          '飲料水・食料・簡易トイレ・懐中電灯などを最低3日分、社内に備蓄しておくことが推奨されています。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_bcp_disaster_2',
      moduleId: 'm_bcp_disaster',
      title: 'ハザードマップの確認',
      body:
          '自社の所在地が洪水・土砂災害・津波などのリスクにどの程度さらされているかは、市区町村が公開するハザードマップで確認できます。'
          '浸水想定区域や避難指示の発令基準を事前に把握し、対策に反映することが重要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_bcp_disaster_3',
      moduleId: 'm_bcp_disaster',
      title: '避難経路・避難場所の周知',
      body:
          '避難経路や避難場所は決めているだけでは不十分で、従業員全員が日頃から把握していなければ緊急時に機能しません。'
          '掲示や訓練を通じて周知を徹底し、複数の避難ルートを想定しておくことが望まれます。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_bcp_disaster_4',
      moduleId: 'm_bcp_disaster',
      title: 'データのオフサイトバックアップ',
      body:
          '社内サーバーやパソコンのみにデータを保管していると、被災により機器が損壊した際に重要な情報を失うおそれがあります。'
          'クラウドサービスや遠隔地の拠点にデータを定期的にバックアップしておくことが有効です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_bcp_infectious': [
    Lesson(
      id: 'l_bcp_infectious_1',
      moduleId: 'm_bcp_infectious',
      title: '感染症流行時特有のリスク',
      body:
          '感染症の流行時は、地震などと異なり施設や設備は無事でも、従業員の感染や濃厚接触により出社できる人員が大幅に減少する点が特有のリスクです。'
          '特定の担当者しかできない業務があると、その業務自体が停止してしまいます。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_bcp_infectious_2',
      moduleId: 'm_bcp_infectious',
      title: 'テレワーク環境の事前整備',
      body:
          '出社が困難な状況でも事業を続けられるよう、平時からテレワークに必要な機器・通信環境・社内規程を整えておくことが有効です。'
          '流行が拡大してから慌てて準備すると対応が後手に回り、業務停止の期間が長引きます。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_bcp_infectious_3',
      moduleId: 'm_bcp_infectious',
      title: '出社基準の明確化',
      body:
          '発熱や咳などの症状がある従業員が無理に出社すると、社内で感染が拡大するおそれがあります。'
          '体調不良時の出社・休業の基準や報告ルールをあらかじめ定め、従業員に周知しておくことが重要です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_bcp_infectious_4',
      moduleId: 'm_bcp_infectious',
      title: '業務の属人化解消と代替要員',
      body:
          '特定の担当者しか対応できない業務は、感染症流行時にその担当者が不在になると業務全体が止まってしまいます。'
          'マニュアル化や複数人での対応体制を整え、代替要員が業務を引き継げるようにしておくことが求められます。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_bcp_safety_confirm': [
    Lesson(
      id: 'l_bcp_safety_confirm_1',
      moduleId: 'm_bcp_safety_confirm',
      title: '安否確認が初動対応で重要な理由',
      body:
          '災害発生直後は、従業員の生命・安全の確認が最優先事項です。'
          '安否が確認できなければ、事業再開に必要な人員配置や重要業務の継続可否を判断できず、初動対応全体が遅れてしまいます。安否確認はBCPの出発点と言えます。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_bcp_safety_confirm_2',
      moduleId: 'm_bcp_safety_confirm',
      title: '安否確認システムの整備',
      body:
          '電話がつながりにくい災害直後でも安否情報を集約できるよう、専用の安否確認システムやチャットツールなどをあらかじめ導入しておくことが有効です。'
          '自動送信・自動集計機能により、迅速な状況把握につながります。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_bcp_safety_confirm_3',
      moduleId: 'm_bcp_safety_confirm',
      title: '緊急連絡網の整備',
      body:
          '安否確認システムに加えて、システムが使えない場合を想定した緊急連絡網も整備しておく必要があります。'
          '連絡先は定期的に更新し、家族の連絡先や複数の連絡手段も控えておくと確実性が高まります。異動や退職時の更新も忘れずに行いましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_bcp_safety_confirm_4',
      moduleId: 'm_bcp_safety_confirm',
      title: '平時からの訓練の必要性',
      body:
          '安否確認の仕組みは、実際に使ってみなければ不具合や従業員の理解不足に気づけません。'
          '定期的に安否確認訓練を実施し、回答率や所要時間を確認しながら仕組みを改善していくことが求められます。訓練を年に一度は行う企業もあります。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_bcp_supplychain': [
    Lesson(
      id: 'l_bcp_supplychain_1',
      moduleId: 'm_bcp_supplychain',
      title: 'サプライチェーン寸断の影響',
      body:
          '自社が被災していなくても、原材料や部品を供給する仕入先が被災すると、調達が止まり自社の生産・販売に大きな影響が及ぶことがあります。'
          '特定の仕入先に依存している場合、その影響はより深刻になります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_bcp_supplychain_2',
      moduleId: 'm_bcp_supplychain',
      title: '仕入先の複数化',
      body:
          '重要な原材料・部品を単一の仕入先のみに依存していると、その仕入先が被災した際に調達が完全に止まってしまいます。'
          '地域やルートの異なる複数の仕入先を確保しておくことで、リスクを分散できます。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_bcp_supplychain_3',
      moduleId: 'm_bcp_supplychain',
      title: '代替調達先の検討',
      body:
          '平時から代替となる調達先の候補をリストアップし、必要な発注量や品質基準を満たせるか確認しておくと、緊急時に速やかに切り替えが可能になります。'
          '事前の情報収集と関係構築が対応の速さを左右します。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_bcp_supplychain_4',
      moduleId: 'm_bcp_supplychain',
      title: '取引先とのBCP事前確認',
      body:
          '自社の重要な取引先や仕入先がBCPを策定しているか、被災時にどの程度の期間で復旧できる見込みかを事前に確認しておくことも有効です。'
          '相互の状況を共有しておくことで、緊急時の連携がスムーズになります。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],

  // ⑨環境・サステナビリティ(SDGs)
  'm_sustainability_sdgs': [
    Lesson(
      id: 'l_sustainability_sdgs_1',
      moduleId: 'm_sustainability_sdgs',
      title: 'SDGsとは何か',
      body:
          'SDGs(持続可能な開発目標)は、2015年に国連総会で採択された、2030年までに達成を目指す17の目標です。'
          '貧困、気候変動、働きがいなど、世界が直面する幅広い課題を対象としています。まずは自社が17の目標のどれに関わっているかを考えてみましょう。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_sustainability_sdgs_2',
      moduleId: 'm_sustainability_sdgs',
      title: '大企業だけの話ではない',
      body:
          '「SDGsは大企業や海外の話」と考えがちですが、中小企業も社会や取引先とのつながりの中でSDGsと無関係ではいられません。'
          '近年は取引先や金融機関がSDGsへの取り組みを評価する場面も増えています。規模の大小にかかわらず、できることから関わる姿勢が大切です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_sustainability_sdgs_3',
      moduleId: 'm_sustainability_sdgs',
      title: '身近にできる取り組み',
      body:
          'SDGsへの取り組みは、特別な新事業を始めることだけではありません。省エネや働きやすい職場づくり、地域清掃への参加など、日常業務の延長でできることも数多くあります。'
          'まずは自社の既存の活動をSDGsの視点で見直すことから始めましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_sustainability_sdgs_4',
      moduleId: 'm_sustainability_sdgs',
      title: '取り組む意義とメリット',
      body:
          'SDGsに取り組むことは、企業イメージの向上や取引先からの信頼獲得、採用活動での評価につながります。'
          '一方で、実態が伴わない一時的なアピールだけでは信頼を損なう恐れもあります。日々の業務に地道に取り入れ、継続することが重要です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_sustainability_energy': [
    Lesson(
      id: 'l_sustainability_energy_1',
      moduleId: 'm_sustainability_energy',
      title: '電力使用量の削減',
      body:
          'オフィスでの省エネは、照明のLED化や使用していない部屋の消灯、空調の温度設定の見直しなど、身近なところから始められます。'
          '夏は28度、冬は20度を目安にするなど、無理のない範囲での節電が効果的です。日々の小さな積み重ねが電力使用量の削減につながります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_sustainability_energy_2',
      moduleId: 'm_sustainability_energy',
      title: 'ペーパーレス化',
      body:
          '紙の使用量削減は、印刷前に本当に必要か確認する、両面印刷を徹底する、資料をクラウドで共有するなどの工夫で進められます。'
          '「とりあえず印刷する」習慣を見直すだけでも、紙代やインク代の削減、廃棄物の減少につながります。日々の業務フローの中で意識しましょう。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_sustainability_energy_3',
      moduleId: 'm_sustainability_energy',
      title: '廃棄物の分別・リサイクル',
      body:
          '職場から出るゴミは、可燃・不燃・資源物などのルールに従って正しく分別することが基本です。'
          '産業廃棄物が発生する現場では、許可を持つ業者への委託など、法令に沿った適正処理が求められます。分別ルールを社内で共有し、誰もが守れる仕組みを作りましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_sustainability_energy_4',
      moduleId: 'm_sustainability_energy',
      title: '社員一人ひとりの意識づけ',
      body:
          '省エネや廃棄物削減は、担当者だけでなく社員一人ひとりの日々の行動の積み重ねで実現します。'
          '「使わない電気は消す」「ゴミは分別する」といった小さな習慣が、職場全体の環境負荷を大きく減らします。定期的な声かけや目標の共有で、意識を継続させましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_sustainability_procurement': [
    Lesson(
      id: 'l_sustainability_procurement_1',
      moduleId: 'm_sustainability_procurement',
      title: 'CSR調達とは',
      body:
          'CSR調達とは、大手企業が製品やサービスを調達する際、価格や品質だけでなく、取引先の環境配慮や労働環境、法令遵守の状況も基準に含める考え方です。'
          'サプライチェーン全体で社会的責任を果たすことが求められており、下請けとなる中小企業にも対応が波及しています。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_sustainability_procurement_2',
      moduleId: 'm_sustainability_procurement',
      title: '取引先からのアンケート・監査',
      body:
          '大手取引先から、環境方針の有無や廃棄物管理、労働時間管理などに関するアンケートや監査を求められることがあります。'
          '回答内容は自社の取引継続や新規取引の判断材料になるため、事実に基づき誠実に回答することが重要です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_sustainability_procurement_3',
      moduleId: 'm_sustainability_procurement',
      title: '対応できない場合のリスク',
      body:
          'CSR調達の基準を満たせない、あるいはアンケートに適切に回答できない場合、取引の縮小や新規取引の見送りにつながることがあります。'
          '特に大手企業との取引比率が高い企業ほど、事業全体への影響が大きくなる点に注意が必要です。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_sustainability_procurement_4',
      moduleId: 'm_sustainability_procurement',
      title: '日頃からの備え',
      body:
          'CSR調達への対応は、求められてから慌てて準備するのではなく、日頃から環境方針や社内ルールを文書化し、実態を把握しておくことが大切です。'
          '分からない項目は取引先に確認しながら、できる範囲で誠実に対応する姿勢を持ちましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_sustainability_greenwash': [
    Lesson(
      id: 'l_sustainability_greenwash_1',
      moduleId: 'm_sustainability_greenwash',
      title: 'グリーンウォッシュとは',
      body:
          'グリーンウォッシュとは、実際の取り組みが伴っていないにもかかわらず、環境に配慮しているかのように見せかける情報発信のことです。'
          '意図的でなくても、根拠のあいまいな表現が結果的にグリーンウォッシュとみなされることがあります。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_sustainability_greenwash_2',
      moduleId: 'm_sustainability_greenwash',
      title: '根拠のない表示のリスク',
      body:
          '「エコ」「環境に優しい」といった表現を、具体的な根拠なく使うと、景品表示法上の優良誤認などの問題につながるおそれがあります。'
          '消費者や取引先の信頼を損ない、企業の評判に悪影響を及ぼしかねません。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_sustainability_greenwash_3',
      moduleId: 'm_sustainability_greenwash',
      title: '事実に基づいた発信の重要性',
      body:
          '環境配慮をアピールする際は、具体的なデータや第三者認証など、客観的な根拠に基づいて説明することが大切です。'
          '実態以上に良く見せようとする誇張表現は避け、できていることとできていないことを正直に伝えましょう。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_sustainability_greenwash_4',
      moduleId: 'm_sustainability_greenwash',
      title: '発信前のチェック体制',
      body:
          '環境に関する広告やウェブサイトの表現は、担当者一人の判断で公開せず、社内で複数人が確認する体制を作ることが望ましいです。'
          '誰が見ても誤解を生まない表現かどうかを、公開前に必ずチェックしましょう。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
  'm_sustainability_carbon': [
    Lesson(
      id: 'l_sustainability_carbon_1',
      moduleId: 'm_sustainability_carbon',
      title: 'カーボンニュートラルとは',
      body:
          'カーボンニュートラルとは、温室効果ガスの排出量から、森林などによる吸収量を差し引き、実質的な排出量をゼロにする考え方です。'
          '日本は2050年までのカーボンニュートラル実現を目標として掲げています。',
      imageUrls: [],
      sortOrder: 1,
    ),
    Lesson(
      id: 'l_sustainability_carbon_2',
      moduleId: 'm_sustainability_carbon',
      title: 'Scope1・2・3の基本',
      body:
          '温室効果ガスの排出量は、自社での燃料燃焼などによる「Scope1」、購入した電力使用による「Scope2」、原材料調達や物流など取引先を含むサプライチェーン全体の「Scope3」に分けて把握されます。'
          '特にScope3は自社以外の排出量も含む点が特徴です。',
      imageUrls: [],
      sortOrder: 2,
    ),
    Lesson(
      id: 'l_sustainability_carbon_3',
      moduleId: 'm_sustainability_carbon',
      title: '中小企業への波及',
      body:
          '大手企業がScope3排出量を算定する際、取引先である中小企業に対しても排出量データの提供を求める動きが広がっています。'
          '直接の規制対象でなくても、取引関係を通じて脱炭素対応が求められる場面が増えていくと考えられます。',
      imageUrls: [],
      sortOrder: 3,
    ),
    Lesson(
      id: 'l_sustainability_carbon_4',
      moduleId: 'm_sustainability_carbon',
      title: 'できることから始める',
      body:
          '排出量の算定は専門知識が必要で難しく感じるかもしれませんが、まずは自社の電力使用量やエネルギー使用状況を把握することから始められます。'
          '省エネの推進や再生可能エネルギーの活用など、できることから段階的に取り組む姿勢が大切です。',
      imageUrls: [],
      sortOrder: 4,
    ),
  ],
};
