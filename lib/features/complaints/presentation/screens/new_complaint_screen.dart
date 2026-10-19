import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class NewComplaintScreen extends ConsumerStatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  ConsumerState<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends ConsumerState<NewComplaintScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Keluhan Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tulis Keluhan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Ceritakan gejala motor yang kamu alami.',
              style: TextStyle(color: context.muted, fontSize: 12),
            ),
            const SizedBox(height: 24),

            Text(
              'Judul singkat',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Rem berbunyi',
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ceritakan keluhan motor...',
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.soft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Text('ℹ️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keluhan akan dianalisis secara lokal di HP kamu.',
                      style: TextStyle(color: context.muted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan Keluhan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi judul dan deskripsi')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);
      final activeMotor = ref.read(activeMotorcycleProvider);

      if (activeMotor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tambahkan motor terlebih dahulu')),
        );
        return;
      }

      // Get latest odometer
      double? odo;
      final latestOdo = await db.getLatestOdometer(activeMotor.id);
      if (latestOdo != null) odo = latestOdo.odometerKm;

      final complaintId = await db.insertComplaint(
        ComplaintsCompanion(
          motorcycleId: Value(activeMotor.id),
          title: Value(title),
          description: Value(desc),
          status: const Value(' baru'),
          odometerKm: Value(odo),
        ),
      );

      // Insert initial system message
      await db.insertComplaintMessage(
        ComplaintMessagesCompanion(
          complaintId: Value(complaintId),
          role: const Value('system'),
          content: Value(
            'Keluhan "$title" dicatat pada ${DateTime.now().toString().substring(0, 16)}. '
            'Deskripsi: $desc',
          ),
        ),
      );

      // Insert initial rule-based analysis
      final risk = _assessRisk(desc);
      await db.insertComplaintAnalysis(
        ComplaintAnalysesCompanion(
          complaintId: Value(complaintId),
          symptomsJson: Value(
            '["${desc.substring(0, desc.length > 50 ? 50 : desc.length)}"]',
          ),
          riskLevel: Value(risk),
          summary: Value(_generateSummary(desc, risk)),
          analysisMode: const Value('rule_based'),
        ),
      );

      ref.invalidate(complaintsProvider(activeMotor.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keluhan berhasil disimpan!')),
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

  String _assessRisk(String desc) {
    final lower = desc.toLowerCase();
    final dangerKeywords = [
      'rem tidak fungsi',
      'rem blong',
      'ban pecah',
      'bahan bakar bocor',
      'oli bocor',
      'mesin mati mendadak',
      'kemudi tidak responsif',
    ];
    final warnKeywords = [
      'berisik',
      'bergetar',
      'susah starter',
      'lambat',
      'berasa',
      'kurang',
      'lemah',
    ];

    for (final kw in dangerKeywords) {
      if (lower.contains(kw)) return 'high';
    }
    for (final kw in warnKeywords) {
      if (lower.contains(kw)) return 'medium';
    }
    return 'low';
  }

  String _generateSummary(String desc, String risk) {
    if (risk == 'high') {
      return 'Keluhan ini mengandung indikasi risiko tinggi. '
          'Disarankan segera diperiksa oleh mekanik profesional. '
          'Jangan menggunakan motor jika menyangkut keselamatan (rem, ban, kebocoran).';
    }
    return 'Keluhan telah dicatat. buildhaus akan membantu memonitor dan menganalisis '
        'keluhan ini berdasarkan data perawatan motor kamu.';
  }
}
