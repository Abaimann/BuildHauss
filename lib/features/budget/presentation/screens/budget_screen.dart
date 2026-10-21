import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/engines/budget_engine.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _budgetController = TextEditingController();
  int _budgetAmount = 200000;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _budgetController.text = '200000';
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final activeMotor = ref.read(activeMotorcycleProvider);
    if (activeMotor != null) {
      final db = ref.read(databaseProvider);
      final plan = await db.getActiveBudgetPlan(activeMotor.id);
      if (plan != null && mounted) {
        setState(() {
          _budgetAmount = plan.budgetAmount;
          _budgetController.text = plan.budgetAmount.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMotor = ref.watch(activeMotorcycleProvider);

    if (activeMotor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prioritas Servis')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tambahkan motor terlebih dahulu',
                style: TextStyle(color: context.muted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/add-motor'),
                child: const Text('Tambah Motor'),
              ),
            ],
          ),
        ),
      );
    }

    final budgetSummaryAsync = ref.watch(
      budgetPlanSummaryProvider(_budgetAmount),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Prioritas Servis'),
        actions: [
          TextButton(
            onPressed: _showEditBudget,
            child: const Text('Ubah Budget'),
          ),
        ],
      ),
      body: budgetSummaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Gagal memuat rekomendasi budget: $err',
              style: TextStyle(color: context.muted),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prioritas servis',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Rekomendasi dinamis berbasis kondisi motor & anggaran ${activeMotor.nickname}.',
                style: TextStyle(color: context.muted, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Budget card display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0e0e0e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ANGGARAN TERSEDIA',
                              style: TextStyle(
                                color: context.muted,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Formatters.currency(_budgetAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'BuildHaus',
                          style: TextStyle(color: context.muted, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 1,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alokasi terpakai: ${Formatters.currency(summary.totalFundedCost)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          summary.shortfall > 0
                              ? 'Kekurangan: ${Formatters.currency(summary.shortfall)}'
                              : 'Sisa: ${Formatters.currency(summary.remainingBudget)}',
                          style: TextStyle(
                            color: summary.shortfall > 0
                                ? context.statusWarn
                                : context.statusOk,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Dynamic Priority items list
              if (summary.recommendations.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.line),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: context.statusOk,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Semua Komponen Normal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: context.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Belum ada jadwal servis mendesak atau penggantian sparepart yang diperlukan saat ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...summary.recommendations.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final rec = entry.value;

                  String itemTitle;
                  if (rec.action == 'replace') {
                    itemTitle = 'Ganti ${rec.componentName}';
                  } else if (rec.action == 'repair') {
                    itemTitle = 'Perbaikan ${rec.componentName}';
                  } else {
                    itemTitle = 'Periksa ${rec.componentName}';
                  }

                  final descBuffer = StringBuffer(rec.reason);
                  if (rec.consequenceIfDelayed != null) {
                    descBuffer.write(
                      ' Risiko jika ditunda: ${rec.consequenceIfDelayed}',
                    );
                  }
                  if (rec.matchedSparepart != null) {
                    final part = rec.matchedSparepart!;
                    final fitmentLabel = rec.fitmentStatus == 'verified'
                        ? 'Fitment Resmi Terverifikasi'
                        : 'Referensi';
                    descBuffer.write(
                      '\n• Rekomendasi Part: ${part.name} (${part.partNumber ?? '-'}) [$fitmentLabel]',
                    );
                  }

                  return _buildPriorityItem(
                    context,
                    priority: index.toString(),
                    title: itemTitle,
                    desc: descBuffer.toString(),
                    cost: rec.hasKnownCost ? rec.estimatedCost : null,
                    isSafety: rec.isSafetyCritical,
                    isDeferred: rec.budgetStatus == 'belum_terdanai',
                    budgetStatus: rec.budgetStatus,
                  );
                }),

              // Savings Plan card if shortfall exists
              if (summary.savingsPlan != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.statusWarnBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.statusWarn.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.savings_outlined,
                            color: context.statusWarn,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Perencanaan Menabung',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: context.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary.savingsPlan!.advice,
                        style: TextStyle(
                          color: context.muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target Tabungan: ${Formatters.currency(summary.savingsPlan!.weeklyTarget)} / minggu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: context.statusWarn,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Disclaimer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: context.soft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rekomendasi bersifat estimasi, bukan diagnosis mekanik resmi.',
                        style: TextStyle(color: context.muted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () => _saveCompletePlan(summary),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bookmark_outline, size: 16),
                      label: const Text('Simpan Rencana'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/parts'),
                      child: const Text('Cari Sparepart'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityItem(
    BuildContext context, {
    required String priority,
    required String title,
    required String desc,
    int? cost,
    bool isSafety = false,
    bool isDeferred = false,
    String? budgetStatus,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSafety
              ? BuildHausTheme.danger.withValues(alpha: 0.3)
              : context.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSafety)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: BuildHausTheme.dangerBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'KESELAMATAN',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: BuildHausTheme.danger,
                    ),
                  ),
                ),
              if (isDeferred)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.soft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BISA DITUNDA',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: context.muted,
                    ),
                  ),
                ),
              if (budgetStatus == 'terdanai' && !isSafety)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.statusOkBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'TERDANAI',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: context.statusOk,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  '$priority · $title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: context.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(color: context.muted, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 6),
          if (cost != null)
            Text(
              'Estimasi ${Formatters.currency(cost)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: context.ink,
              ),
            )
          else
            Text(
              'Estimasi biaya belum tersedia',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: context.muted,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showEditBudget() async {
    final controller = TextEditingController(text: _budgetAmount.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Jumlah (Rp)',
            hintText: 'Contoh: 200000',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              Navigator.pop(context, val);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null && result > 0 && mounted) {
      setState(() => _budgetAmount = result);
    }
  }

  Future<void> _saveCompletePlan(BudgetPlanSummary summary) async {
    final activeMotor = ref.read(activeMotorcycleProvider);
    if (activeMotor == null) return;

    setState(() => _isSaving = true);
    try {
      final db = ref.read(databaseProvider);
      await db.saveCompleteBudgetPlan(
        motorcycleId: activeMotor.id,
        budgetAmount: _budgetAmount,
        period: 'bulanan',
        recommendations: summary.recommendations,
        notes: 'Disimpan dari layar Prioritas Servis',
      );

      ref.invalidate(activeBudgetPlanProvider(activeMotor.id));
      ref.invalidate(budgetPlanHistoryProvider(activeMotor.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rencana budget & snapshot berhasil disimpan!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan rencana: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
