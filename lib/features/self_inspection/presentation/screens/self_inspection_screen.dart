import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class SelfInspectionScreen extends ConsumerStatefulWidget {
  final int motorcycleId;
  const SelfInspectionScreen({super.key, required this.motorcycleId});

  @override
  ConsumerState<SelfInspectionScreen> createState() => _SelfInspectionScreenState();
}

class _SelfInspectionScreenState extends ConsumerState<SelfInspectionScreen> {
  int _step = 0;
  final Map<String, String> _answers = {};
  bool _saving = false;

  final _questions = [
    {'code': 'mesin_suara', 'question': 'Apakah mesin terdengar normal?', 'category': 'mesin'},
    {'code': 'mesin_getar', 'question': 'Apakah ada getaran异常 yang tidak biasa?', 'category': 'mesin'},
    {'code': 'mesin_starter', 'question': 'Apakah motor mudah distarter?', 'category': 'mesin'},
    {'code': 'rem_respons', 'question': 'Apakah rem merespons dengan baik?', 'category': 'pengereman'},
    {'code': 'rem_berisik', 'question': 'Apakah rem berbunyi aneh?', 'category': 'pengereman'},
    {'code': 'ban_tekanan', 'question': 'Apakah tekanan ban terasa normal?', 'category': 'roda'},
    {'code': 'ban_usangan', 'question': 'Apakah ada keausan tidak merata pada ban?', 'category': 'roda'},
    {'code': 'kebocoran_oli', 'question': 'Apakah ada tanda kebocoran oli?', 'category': 'mesin'},
    {'code': 'kelistrikan', 'question': 'Apakah lampu dan kelistrikan berfungsi normal?', 'category': 'kelistrikan'},
    {'code': 'cvt_normal', 'question': 'Apakah transmisi CVT (jika ada) halus?', 'category': 'transmisi'},
    {'code': 'knalpot_normal', 'question': 'Apakah knalpot tidak bocor atau berbunyi aneh?', 'category': 'mesin'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Pemeriksaan Mandiri'),
        actions: [
          if (_step > 0)
            TextButton(
              onPressed: () => setState(() => _step--),
              child: const Text('← Back'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (_step + 1) / _questions.length,
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

  Widget _buildQuestion(Map<String, String> q) {
    final answer = _answers[q['code']!];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.soft,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              q['category']!.toUpperCase(),
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.muted),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            q['question']!,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          _AnswerButton(
            label: 'Ya, normal',
            icon: '✅',
            isSelected: answer == 'yes',
            onTap: () => setState(() { _answers[q['code']!] = 'yes'; }),
          ),
          const SizedBox(height: 8),
          _AnswerButton(
            label: 'Tidak / Ada masalah',
            icon: '⚠️',
            isSelected: answer == 'no',
            onTap: () => setState(() { _answers[q['code']!] = 'no'; }),
          ),
          const SizedBox(height: 8),
          _AnswerButton(
            label: 'Tidak tahu',
            icon: '❓',
            isSelected: answer == 'unknown',
            onTap: () => setState(() { _answers[q['code']!] = 'unknown'; }),
          ),
          const Spacer(),
          if (answer != null)
            ElevatedButton(
              onPressed: () => setState(() => _step++),
              child: const Text('Lanjut'),
            )
          else
            OutlinedButton(
              onPressed: () => setState(() => _step++),
              child: const Text('Lewati'),
            ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final riskCount = _answers.values.where((v) => v == 'no').length;
    final riskLevel = riskCount >= 4 ? 'high' : riskCount >= 2 ? 'medium' : 'low';
    final riskColor = riskLevel == 'high' ? BuildHausTheme.danger
      : riskLevel == 'medium' ? BuildHausTheme.warn : BuildHausTheme.ok;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hasil Inspeksi', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(riskLevel == 'high' ? '🔴' : riskLevel == 'medium' ? '🟡' : '🟢',
                  style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riskLevel == 'high' ? 'Risiko Tinggi'
                          : riskLevel == 'medium' ? 'Perhatian'
                          : 'Baik',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: riskColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        riskLevel == 'high'
                          ? 'Ditemukan ${riskCount} masalah. Sebaiknya segera periksakan ke mekanik.'
                          : riskLevel == 'medium'
                            ? 'Ditemukan ${riskCount} hal yang perlu diperhatikan.'
                            : 'Tidak ada masalah serius yang terdeteksi.',
                        style: TextStyle(color: context.ink, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (riskLevel == 'high') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BuildHausTheme.dangerBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Text('🚨', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jika ada masalah rem, ban, atau kebocoran bahan bakar: JANGAN gunakan motor dan segera bawa ke mekanik profesional.',
                      style: TextStyle(color: BuildHausTheme.danger, fontSize: 11, fontWeight: FontWeight.bold, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text('Ringkasan Jawaban', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          ..._questions.map((q) {
            final a = _answers[q['code']!];
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(a == 'yes' ? '✅' : a == 'no' ? '⚠️' : '❓', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(q['question']!, style: TextStyle(fontSize: 11, color: context.ink)),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          if (_saving)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () => _saveInspection(riskLevel),
              child: const Text('Simpan Hasil Inspeksi'),
            ),
        ],
      ),
    );
  }

  Future<void> _saveInspection(String riskLevel) async {
    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);

      final inspectionId = await db.insertSelfInspection(SelfInspectionsCompanion(
        motorcycleId: Value(widget.motorcycleId),
        riskLevel: Value(riskLevel),
        status: const Value('completed'),
      ));

      for (final entry in _answers.entries) {
        final isRisk = entry.value == 'no';
        await db.insertInspectionAnswer(InspectionAnswersCompanion(
          inspectionId: Value(inspectionId),
          questionCode: Value(entry.key),
          answer: Value(entry.value),
          answerType: const Value('multiple_choice'),
          riskFlag: Value(isRisk),
        ));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspeksi disimpan!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
        padding: const EdgeInsets.all(16),
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
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? context.bg : context.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
