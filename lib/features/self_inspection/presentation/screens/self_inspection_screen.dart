import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/engines/self_inspection_engine.dart';

class SelfInspectionScreen extends ConsumerStatefulWidget {
  final int motorcycleId;
  const SelfInspectionScreen({super.key, required this.motorcycleId});

  @override
  ConsumerState<SelfInspectionScreen> createState() =>
      _SelfInspectionScreenState();
}

class _SelfInspectionScreenState extends ConsumerState<SelfInspectionScreen> {
  int _step = 0;
  final Map<String, String> _answers = {};
  bool _saving = false;

  final List<InspectionQuestion> _questions = SelfInspectionEngine.questions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Pemeriksaan Mandiri'),
        actions: [
          if (_step > 0 && _step < _questions.length)
            TextButton(
              onPressed: () => setState(() => _step--),
              child: const Text('← Back'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_step + 1) / (_questions.length + 1),
            backgroundColor: context.soft,
            color: context.ink,
          ),

          Expanded(
            child: _step < _questions.length
                ? _buildQuestion(_questions[_step])
                : _buildResult(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(InspectionQuestion q) {
    final currentAnswer = _answers[q.code];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.soft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  q.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: context.muted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Pertanyaan ${_step + 1} dari ${_questions.length}',
                style: TextStyle(fontSize: 11, color: context.muted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(q.question, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: q.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final opt = q.options[i];
                final isSelected = currentAnswer == opt.code;
                return _AnswerButton(
                  label: opt.label,
                  icon: opt.icon,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _answers[q.code] = opt.code;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_step > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  child: const Text('Kembali'),
                ),
              const Spacer(),
              if (currentAnswer != null)
                ElevatedButton(
                  onPressed: () => setState(() => _step++),
                  child: Text(
                    _step == _questions.length - 1 ? 'Selesai' : 'Lanjut',
                  ),
                )
              else
                TextButton(
                  onPressed: () => setState(() => _step++),
                  child: const Text('Lewati'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final eval = SelfInspectionEngine.evaluate(_answers);
    final riskLevel = eval.riskLevel;

    final riskColor = riskLevel == 'high'
        ? BuildHausTheme.danger
        : riskLevel == 'medium'
        ? BuildHausTheme.warn
        : BuildHausTheme.ok;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hasil Pemeriksaan Mandiri',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            eval.disclaimer,
            style: TextStyle(fontSize: 11, color: context.muted),
          ),
          const SizedBox(height: 16),

          // Overview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riskLevel == 'high'
                      ? '🔴'
                      : riskLevel == 'medium'
                      ? '🟡'
                      : '🟢',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eval.summaryTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: riskColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eval.summaryExplanation,
                        style: TextStyle(
                          color: context.ink,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Prominent Safety Alert Banner if safety hazard detected
          if (eval.hasSafetyAlert) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BuildHausTheme.dangerBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: BuildHausTheme.danger.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🚨', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'PERINGATAN KESELAMATAN',
                        style: TextStyle(
                          color: BuildHausTheme.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ditemukan indikasi kritis pada sistem keselamatan motor Anda: '
                    '${eval.safetyAlerts.map((s) => s.componentName).toSet().join(', ')}.\n\n'
                    '⚠️ JANGAN gunakan motor sebelum diperiksa oleh mekanik profesional!',
                    style: TextStyle(
                      color: BuildHausTheme.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Findings Section
          if (eval.allFindings.isNotEmpty) ...[
            Text(
              'Indikasi yang Perlu Diperhatikan (${eval.allFindings.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...eval.allFindings.map((f) {
              final findingColor = f.isSafetyCritical || f.riskLevel == 'high'
                  ? BuildHausTheme.danger
                  : f.riskLevel == 'medium'
                  ? BuildHausTheme.warn
                  : BuildHausTheme.ok;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: findingColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          f.isSafetyCritical
                              ? '🚨'
                              : (f.riskLevel == 'high' ? '⚠️' : '🔧'),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${f.componentName} — ${f.questionTitle}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: context.ink,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: findingColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            f.isSafetyCritical
                                ? 'KESELAMATAN'
                                : f.riskLevel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: findingColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Observasi: "${f.answerLabel}"',
                      style: TextStyle(fontSize: 11, color: context.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      f.advice,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.ink,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Summary of all answers
          Text(
            'Seluruh Jawaban Pemeriksaan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._questions.map((q) {
            final ansCode = _answers[q.code];
            final opt = q.getSelectedOption(ansCode);
            final hasAnswered = opt != null;
            final isIssue = opt?.isIssue ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    !hasAnswered
                        ? '❓'
                        : isIssue
                        ? (opt.isSafetyCritical ? '🚨' : '⚠️')
                        : '✅',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.question,
                          style: TextStyle(fontSize: 11, color: context.ink),
                        ),
                        if (hasAnswered)
                          Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: isIssue
                                  ? BuildHausTheme.warn
                                  : context.muted,
                              fontWeight: isIssue
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveInspection(eval.riskLevel),
                child: const Text('Simpan Hasil Pemeriksaan'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveInspection(String riskLevel) async {
    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);

      await db.saveCompleteSelfInspection(
        motorcycleId: widget.motorcycleId,
        riskLevel: riskLevel,
        answers: _answers,
      );

      // Invalidate providers so UI instantly reflects the inspection
      ref.invalidate(latestSelfInspectionProvider(widget.motorcycleId));
      ref.invalidate(componentStatusesProvider(widget.motorcycleId));
      ref.invalidate(componentStatusesWithNamesProvider(widget.motorcycleId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hasil pemeriksaan mandiri berhasil disimpan!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? context.ink : context.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.ink : context.line,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? context.bg : context.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
