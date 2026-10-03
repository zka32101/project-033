import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/generated_content_draft.dart';
import '../../../data/models/module_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';
import 'draft_editor.dart';

enum ContentGenerationMode { extend, create }

/// AIによるオリジナルコンテンツ生成画面(プレミアムプラン)。
/// テーマを入力してAI生成→内容を確認・編集→保存、の3ステップで進む。
class AiContentGeneratorScreen extends ConsumerStatefulWidget {
  final ContentGenerationMode mode;

  const AiContentGeneratorScreen({super.key, required this.mode});

  @override
  ConsumerState<AiContentGeneratorScreen> createState() =>
      _AiContentGeneratorScreenState();
}

class _AiContentGeneratorScreenState extends ConsumerState<AiContentGeneratorScreen> {
  final _themeController = TextEditingController();
  late Future<List<Module>> _modulesFuture;
  Module? _selectedTargetModule;
  CategoryId _selectedCategoryId = CategoryId.infoMorals;

  bool _isGenerating = false;
  bool _isSaving = false;
  String? _errorMessage;
  GeneratedContentDraft? _draft;

  bool get _isExtend => widget.mode == ContentGenerationMode.extend;

  @override
  void initState() {
    super.initState();
    final company = ref.read(sessionProvider).company!;
    _modulesFuture = ref
        .read(contentServiceProvider)
        .getIndustry(company.industryId)
        .then((industry) async {
      if (industry == null) return <Module>[];
      return ref.read(contentServiceProvider).listModulesForIndustry(industry);
    });
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final theme = _themeController.text.trim();
    if (theme.isEmpty) {
      setState(() => _errorMessage = 'テーマを入力してください');
      return;
    }
    if (_isExtend && _selectedTargetModule == null) {
      setState(() => _errorMessage = '追加先のモジュールを選択してください');
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _draft = null;
    });

    try {
      final company = ref.read(sessionProvider).company!;
      final service = ref.read(contentGenerationServiceProvider);
      final draft = _isExtend
          ? await service.generateExtension(
              companyId: company.id,
              targetModuleId: _selectedTargetModule!.id,
              theme: theme,
            )
          : await service.generateNewModule(
              companyId: company.id,
              categoryId: _selectedCategoryId.name,
              theme: theme,
            );
      if (!mounted) return;
      setState(() => _draft = draft);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'AI生成に失敗しました。時間をおいて再度お試しください');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final session = ref.read(sessionProvider);
      final company = session.company!;
      final custom = ref.read(customContentServiceProvider);
      if (_isExtend) {
        await custom.saveModuleExtension(
          companyId: company.id,
          targetModuleId: _selectedTargetModule!.id,
          theme: _themeController.text.trim(),
          draft: draft,
        );
      } else {
        await custom.saveNewModule(
          companyId: company.id,
          categoryId: _selectedCategoryId,
          theme: _themeController.text.trim(),
          createdByEmployeeId: session.employee!.id,
          draft: draft,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存しました')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = '保存に失敗しました。時間をおいて再度お試しください');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isExtend ? '既存モジュールにコンテンツ追加' : '新規モジュールを作成')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputForm(),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isGenerating ? null : _generate,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_draft == null ? 'AIで生成する' : 'AIで再生成する'),
              ),
            ),
            if (_draft != null) ...[
              const Divider(height: 40),
              Text('生成結果の確認・編集', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '内容を確認し、必要に応じて修正してから保存してください',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              DraftEditor(draft: _draft!, showModuleFields: !_isExtend),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存する'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isExtend)
          FutureBuilder<List<Module>>(
            future: _modulesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const ErrorRetryView(message: 'モジュール一覧の読み込みに失敗しました');
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                );
              }
              final modules = snapshot.data!;
              return DropdownButtonFormField<Module>(
                initialValue: _selectedTargetModule,
                decoration: const InputDecoration(labelText: '追加先のモジュール'),
                isExpanded: true,
                items: modules
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.title)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedTargetModule = value),
              );
            },
          )
        else
          DropdownButtonFormField<CategoryId>(
            initialValue: _selectedCategoryId,
            decoration: const InputDecoration(labelText: 'カテゴリ'),
            items: Category.all
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (value) => setState(() => _selectedCategoryId = value!),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _themeController,
          maxLength: 200,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'テーマ・キーワード',
            hintText: _isExtend
                ? '例: 出張時のノートPC紛失防止と初動対応'
                : '例: 建設現場での熱中症予防と応急対応',
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
