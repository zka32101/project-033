import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/custom_module_model.dart';
import '../../../data/models/generated_content_draft.dart';
import '../../../data/models/module_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';
import 'draft_editor.dart';

/// 自社の研修・問題を、手で作成・編集する画面(AIなし。管理者なら契約にかかわらず使える)。
/// - [ManualContentEditorScreen.create]: 新しいオリジナル研修を作る
/// - [ManualContentEditorScreen.edit]: 作成済みのオリジナル研修を編集・削除する
/// - [ManualContentEditorScreen.extend]: 既存の研修に、レッスン・問題を追加する(追加済みなら編集)
class ManualContentEditorScreen extends ConsumerStatefulWidget {
  final CustomModule? module;
  final Module? targetModule;
  final bool _extend;

  const ManualContentEditorScreen.create({super.key})
      : module = null,
        targetModule = null,
        _extend = false;

  const ManualContentEditorScreen.edit({super.key, required CustomModule this.module})
      : targetModule = null,
        _extend = false;

  /// [targetModule]がnullなら、画面の上部で追加先の研修を選ぶ。
  const ManualContentEditorScreen.extend({super.key, this.targetModule})
      : module = null,
        _extend = true;

  @override
  ConsumerState<ManualContentEditorScreen> createState() => _ManualContentEditorScreenState();
}

class _ManualContentEditorScreenState extends ConsumerState<ManualContentEditorScreen> {
  GeneratedContentDraft? _draft;
  Module? _target;
  CategoryId _categoryId = CategoryId.infoMorals;
  Future<List<Module>>? _modulesFuture;
  bool _loading = false;
  bool _saving = false;
  bool _loadFailed = false;
  List<String> _errors = const [];

  bool get _isExtend => widget._extend;
  bool get _isEdit => widget.module != null;

  @override
  void initState() {
    super.initState();
    _target = widget.targetModule;
    if (_isExtend) {
      final company = ref.read(sessionProvider).company!;
      final content = ref.read(contentServiceProvider);
      _modulesFuture = content.getIndustry(company.industryId).then((industry) async {
        if (industry == null) return <Module>[];
        return content.listModulesForIndustry(industry);
      });
      if (_target != null) _loadExtension(_target!);
    } else if (_isEdit) {
      _categoryId = widget.module!.categoryId;
      _loadModule();
    } else {
      _draft = GeneratedContentDraft(moduleTitle: '', moduleDescription: '', lessons: [], quizQuestions: []);
    }
  }

  Future<void> _loadModule() async {
    setState(() => _loading = true);
    try {
      final draft = await ref.read(customContentServiceProvider).loadCustomModuleDraft(widget.module!);
      if (mounted) setState(() => _draft = draft);
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadExtension(Module target) async {
    final companyId = ref.read(sessionProvider).company!.id;
    setState(() {
      _loading = true;
      _loadFailed = false;
      _draft = null;
    });
    try {
      final draft = await ref.read(customContentServiceProvider).loadExtensionDraft(companyId, target.id);
      if (mounted) setState(() => _draft = draft);
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;
    final errors = ContentDraftValidator.validate(draft, requireModuleTitle: !_isExtend);
    if (_isExtend && _target == null) errors.insert(0, '追加先の研修を選んでください');
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() {
      _errors = const [];
      _saving = true;
    });
    try {
      ContentDraftValidator.normalize(draft);
      final session = ref.read(sessionProvider);
      final companyId = session.company!.id;
      final custom = ref.read(customContentServiceProvider);
      if (_isExtend) {
        await custom.saveManualExtension(companyId: companyId, targetModuleId: _target!.id, draft: draft);
      } else {
        await custom.saveManualModule(
          companyId: companyId,
          existing: widget.module,
          categoryId: _categoryId,
          createdByEmployeeId: session.employee!.id,
          draft: draft,
        );
      }
      if (!mounted) return;
      _toast('保存しました');
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _errors = const ['保存に失敗しました。時間をおいて再度お試しください']);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isExtend ? '追加した内容を削除しますか?' : 'この研修を削除しますか?'),
        content: Text(_isExtend
            ? '「${_target!.title}」に追加したレッスン・問題を、すべて削除します。元の研修の内容は変わりません。'
            : 'レッスンと問題も、すべて削除されます。元に戻せません。受講済みの記録は残りますが、この研修は表示されなくなります。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('削除する')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final companyId = ref.read(sessionProvider).company!.id;
      final custom = ref.read(customContentServiceProvider);
      if (_isExtend) {
        await custom.saveManualExtension(
          companyId: companyId,
          targetModuleId: _target!.id,
          draft: GeneratedContentDraft(lessons: [], quizQuestions: []),
        );
      } else {
        await custom.deleteCustomModule(companyId, widget.module!.id);
      }
      if (!mounted) return;
      _toast('削除しました');
      Navigator.of(context).pop();
    } catch (_) {
      _toast('削除に失敗しました。時間をおいて再度お試しください');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn || !session.isAdmin || session.company == null) {
      return const Scaffold(body: Center(child: Text('管理者のみ利用できます')));
    }
    final title = _isExtend
        ? '既存の研修に追加'
        : _isEdit
            ? '研修を編集'
            : '研修を新しく作る';
    final draft = _draft;
    final hasSavedExtension = _isExtend &&
        _target != null &&
        draft != null &&
        (draft.lessons.any((l) => l.id != null) || draft.quizQuestions.any((q) => q.id != null));
    final canDelete = _isEdit || hasSavedExtension;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (canDelete)
            IconButton(
              key: const ValueKey('delete'),
              tooltip: '削除',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_isExtend) _buildTargetPicker(),
          if (!_isExtend)
            DropdownButtonFormField<CategoryId>(
              key: const ValueKey('category'),
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'カテゴリ'),
              items: Category.all.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _categoryId = v!),
            ),
          const SizedBox(height: 16),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_loadFailed) const ErrorRetryView(message: '内容の読み込みに失敗しました'),
          if (draft != null) ...[
            if (_isExtend)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '元の研修のレッスン・問題の後ろに、ここで入力した内容が加わります。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            DraftEditor(
              key: ValueKey('${_target?.id}_${widget.module?.id}'),
              draft: draft,
              showModuleFields: !_isExtend,
              allowAddRemove: true,
            ),
            const SizedBox(height: 16),
            if (_errors.isNotEmpty)
              Container(
                key: const ValueKey('errors'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('保存できません。次を直してください',
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
                    for (final e in _errors.take(8)) Text(e),
                    if (_errors.length > 8) Text('ほか${_errors.length - 8}件'),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('save'),
                onPressed: _saving ? null : _save,
                child: Text(_saving ? '保存中…' : '保存する'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTargetPicker() {
    if (widget.targetModule != null) {
      return Text('追加先: ${widget.targetModule!.title}', style: Theme.of(context).textTheme.titleMedium);
    }
    return FutureBuilder<List<Module>>(
      future: _modulesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const ErrorRetryView(message: '研修一覧の読み込みに失敗しました');
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return DropdownButtonFormField<Module>(
          key: const ValueKey('target'),
          initialValue: _target,
          decoration: const InputDecoration(labelText: '追加先の研修'),
          isExpanded: true,
          items: snapshot.data!.map((m) => DropdownMenuItem(value: m, child: Text(m.title))).toList(),
          onChanged: (m) {
            if (m == null) return;
            setState(() => _target = m);
            _loadExtension(m);
          },
        );
      },
    );
  }
}
