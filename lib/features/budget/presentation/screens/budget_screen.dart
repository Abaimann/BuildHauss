import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
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
  bool _saving = false;

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
      if (plan != null) {
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
              Text('Tambahkan motor terlebih dahulu', style: TextStyle(color: context.muted)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.push('/add-motor'), child: const Text('Tambah Motor')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
        title: const Text('Prioritas Servis'),
        actions: [
          TextButton(onPressed: _showEditBudget, child: const Text('Ubah Budget')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prioritas servis', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Contoh pembagian jika anggaran terbatas.',
              style: TextStyle(color: context.muted, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Budget display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0e0e0e),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ANGGARAN', style: TextStyle(color: context.muted, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.currency(_budgetAmount),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text('BuildHaus', style: TextStyle(color: context.muted, fontSize: 11)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Priority items
            _buildPriorityItem(
              context,
              priority: '1',
              title: 'Periksa rem, prioritas',
              desc: 'Utamakan keselamatan. Jika rem melemah atau terasa blong, jangan tunda dan minta mekanik memeriksa.',
              cost: 30000,
              isSafety: true,
            ),
            _buildPriorityItem(
              context,
              priority: '2',
              title: 'Periksa oli mesin',
              desc: 'Cek jarak pemakaian dan rekomendasi buku manual. Menunda terlalu lama dapat mempercepat keausan mesin.',
              cost: 75000,
            ),
            _buildPriorityItem(
              context,
              priority: '3',
              title: 'Aksesori knalpot',
              desc: 'Jika tidak ada kebocoran atau gangguan, upgrade aksesori bisa menunggu. Risiko terutama kenyamanan/preferensi.',
              cost: 185000,
              isDeferred: true,
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.soft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 14)),
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
            ElevatedButton(
              onPressed: () => context.go('/parts'),
              child: const Text('Cari Sparepart'),
            ),
          ],
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSafety ? BuildHausTheme.danger.withValues(alpha: 0.3) : context.line,
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: BuildHausTheme.dangerBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('KESELAMATAN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: BuildHausTheme.danger)),
                ),
              if (isDeferred)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.soft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('BISA DITUNDA', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: context.muted)),
                ),
              Text('$priority · $title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.ink)),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: TextStyle(color: context.muted, fontSize: 11, height: 1.5)),
          if (cost != null) ...[
            const SizedBox(height: 6),
            Text(
              'Estimasi Rp ${cost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: context.ink),
            ),
          ],
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
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

    if (result != null && result > 0) {
      setState(() => _budgetAmount = result);
      _saveBudget(result);
    }
  }

  Future<void> _saveBudget(int amount) async {
    final activeMotor = ref.read(activeMotorcycleProvider);
    if (activeMotor == null) return;

    final db = ref.read(databaseProvider);
    final existing = await db.getActiveBudgetPlan(activeMotor.id);

    if (existing != null) {
      await db.updateBudgetPlan(BudgetPlansCompanion(
        budgetAmount: Value(amount),
      ), existing.id);
    } else {
      await db.insertBudgetPlan(BudgetPlansCompanion(
        motorcycleId: Value(activeMotor.id),
        budgetAmount: Value(amount),
        period: const Value('bulanan'),
      ));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget disimpan!')),
      );
    }
  }
}
