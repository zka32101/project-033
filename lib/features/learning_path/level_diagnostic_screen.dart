import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../providers/session_provider.dart';
import 'diagnostic_recommendation.dart';

/// レベル診断画面：従業員のスキルレベルを判定して学習パス推奨
class LevelDiagnosticScreen extends ConsumerStatefulWidget {
  const LevelDiagnosticScreen({super.key});

  @override
  ConsumerState<LevelDiagnosticScreen> createState() =>
      _LevelDiagnosticScreenState();
}

class _LevelDiagnosticScreenState extends ConsumerState<LevelDiagnosticScreen> {
  int _currentQuestionIndex = 0;
  Map<int, int> _answers = {};
  bool _isSubmitting = false;
  int? _diagnosticScore;
  String? _recommendedLevel; // beginner, intermediate, advanced
  List<String> _weakCategories = []; // 回答パターンから推定した弱点分野

  final diagnosticQuestions = [
    {
      'question': 'SNSでの発信、ハラスメント防止、著作権など、情報モラルについての知識・経験は？',
      'options': [
        'ほとんど知らない・経験がない',
        '用語は聞いたことがあるが、自信がない',
        '基本は理解しており、業務で対応できる',
        '他の人に教えられる・指導できる',
      ],
    },
    {
      'question': 'パスワード管理、不審メールの見分け方、端末の管理など、セキュリティについての知識・経験は？',
      'options': [
        'ほとんど知らない・経験がない',
        '用語は聞いたことがあるが、自信がない',
        '基本は理解しており、業務で対応できる',
        '他の人に教えられる・指導できる',
      ],
    },
    {
      'question': '個人情報の取り扱いルール(個人情報保護法・マイナンバー)についての知識・経験は？',
      'options': [
        'ほとんど知らない・経験がない',
        '用語は聞いたことがあるが、自信がない',
        '基本は理解しており、業務で対応できる',
        '他の人に教えられる・指導できる',
      ],
    },
    {
      'question': '文書管理、アクセス権限、インシデント時の報告など、情報の管理についての知識・経験は？',
      'options': [
        'ほとんど知らない・経験がない',
        '用語は聞いたことがあるが、自信がない',
        '基本は理解しており、業務で対応できる',
        '他の人に教えられる・指導できる',
      ],
    },
    {
      'question': '法令遵守、取引先との関係、労務のルールなど、コンプライアンスについての知識・経験は？',
      'options': [
        'ほとんど知らない・経験がない',
        '用語は聞いたことがあるが、自信がない',
        '基本は理解しており、業務で対応できる',
        '他の人に教えられる・指導できる',
      ],
    },
    {
      'question': '生成AIの業務活用と、その注意点(情報漏えい・誤りの確認)についての知識・経験は？',
      'options': [
        'ほとんど知らない・経験がない',
        '用語は聞いたことがあるが、自信がない',
        '基本は理解しており、業務で対応できる',
        '他の人に教えられる・指導できる',
      ],
    },
    {
      'question': 'ストレスへの気づき、部下や同僚の不調への対応など、心身の健康管理についての知識・経験は？',
      'options': [
        'ほとんど知らない・経験がない',
        '用語は聞いたことがあるが、自信がない',
        '基本は理解しており、業務で対応できる',
        '他の人に教えられる・指導できる',
      ],
    },
    {
      'question': '災害・感染症などの緊急時の事業継続や、安否確認についての知識・経験は？',
      'options': [
        'ほとんど知らない・経験がない',
        '用語は聞いたことがあるが、自信がない',
        '基本は理解しており、業務で対応できる',
        '他の人に教えられる・指導できる',
      ],
    },
    {
      'question': 'SDGs、省エネ、取引先から求められる環境配慮への対応についての知識・経験は？',
      'options': [
        'ほとんど知らない・経験がない',
        '用語は聞いたことがあるが、自信がない',
        '基本は理解しており、業務で対応できる',
        '他の人に教えられる・指導できる',
      ],
    },
  ];

  Future<void> _submitDiagnostic() async {
    setState(() => _isSubmitting = true);

    try {
      final session = ref.read(sessionProvider);
      if (!session.isSignedIn) {
        throw Exception('セッション情報が取得できません');
      }

      // スコア計算：回答を集計
      int totalScore = 0;
      for (int i = 0; i < diagnosticQuestions.length; i++) {
        totalScore += _answers[i] ?? 0;
      }

      final averageScore = totalScore / diagnosticQuestions.length;
      final recommendedLevel = _determineLevel(averageScore);

      // 各質問の回答パターンから弱点分野を推定（経験・スキルが浅い分野を抽出）
      final weakCategories = determineWeakCategories(_answers);

      // Cloud Functions で診断結果を保存
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('completeLevelDiagnostic');

      await callable.call({
        'companyId': session.employee!.companyId,
        'employeeId': session.employee!.id,
        'answers': {for (final e in _answers.entries) e.key.toString(): e.value},
        'totalScore': totalScore,
        'averageScore': averageScore,
        'recommendedLevel': recommendedLevel,
        'weakCategories': weakCategories,
      });

      setState(() {
        _diagnosticScore = totalScore;
        _recommendedLevel = recommendedLevel;
        _weakCategories = weakCategories;
        _isSubmitting = false;
      });

      if (mounted) {
        _showResultsDialog();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('診断に失敗しました: $e')),
        );
      }
    }
  }

  String _determineLevel(double averageScore) {
    if (averageScore < 1.5) return 'beginner';
    if (averageScore < 2.5) return 'intermediate';
    return 'advanced';
  }

  void _showResultsDialog() {
    final levelLabels = {
      'beginner': '初級者向け',
      'intermediate': '中級者向け',
      'advanced': '上級者向け',
    };

    final levelDescriptions = {
      'beginner': '基礎スキル強化・ツール習得を優先した学習パスをお勧めします',
      'intermediate': '実践的なスキル・リーダーシップスキルの強化をお勧めします',
      'advanced': '戦略的思考・マネジメント・業界トレンドの深掘りをお勧めします',
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('診断完了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'あなたのレベル：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                levelLabels[_recommendedLevel] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              levelDescriptions[_recommendedLevel] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            if (_weakCategories.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '重点的に学習をお勧めする分野：',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _weakCategories
                    .map(
                      (category) => Chip(
                        label: Text(
                          category,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        side: BorderSide(color: Colors.orange[300]!),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('学習パスを見る'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_diagnosticScore != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('診断完了')),
        body: const Center(
          child: Text('診断が完了しました'),
        ),
      );
    }

    final question = diagnosticQuestions[_currentQuestionIndex];
    final selectedAnswer = _answers[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('スキルレベル診断 (${_currentQuestionIndex + 1}/${diagnosticQuestions.length})'),
        elevation: 0,
      ),
      body: SafeArea(top: false, child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / diagnosticQuestions.length,
            minHeight: 8,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['question'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...(question['options'] as List<String>).asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = selectedAnswer == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _answers[_currentQuestionIndex] = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? Colors.blue : Colors.grey,
                                    ),
                                    color: isSelected ? Colors.blue : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _currentQuestionIndex--);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                    ),
                    child: const Text('前へ'),
                  )
                else
                  const SizedBox(width: 80),
                const Spacer(),
                if (_currentQuestionIndex < diagnosticQuestions.length - 1)
                  ElevatedButton(
                    onPressed: _answers.containsKey(_currentQuestionIndex)
                        ? () {
                            setState(() => _currentQuestionIndex++);
                          }
                        : null,
                    child: const Text('次へ'),
                  )
                else
                  ElevatedButton(
                    onPressed: _isSubmitting ||
                            !_answers.containsKey(_currentQuestionIndex)
                        ? null
                        : _submitDiagnostic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('診断を完了'),
                  ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
