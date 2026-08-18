import '../models/lesson_model.dart';

/// レッスン種データ。モジュールごとに3レッスン(導入→具体例→まとめ・行動指針)。
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
  ],
};
