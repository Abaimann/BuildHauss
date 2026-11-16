import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

/// Kategori cepat pencatatan pengeluaran perawatan / operasional motor.
class _ExpenseCategoryOption {
  final String id;
  final String label;
  final String componentKeyword;
  final String defaultAction;
  final bool defaultCountsAsReplacement;
  final IconData icon;

  const _ExpenseCategoryOption({
    required this.id,
    required this.label,
    required this.componentKeyword,
    required this.defaultAction,
    required this.defaultCountsAsReplacement,
    required this.icon,
  });
}

/// Layar cepat untuk mencatat pengeluaran perawatan motor (pembelian part,
/// jasa bengkel ringan, cuci/perawatan bodi, tambal ban, dll.) untuk `/motor/:id/expense/add`.
class AddExpenseScreen extends ConsumerStatefulWidget {
  final int? motorcycleId;

  const AddExpenseScreen({super.key, this.motorcycleId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  static const _categories = [
    _ExpenseCategoryOption(
      id: 'sparepart',
      label: 'Beli Sparepart',
      componentKeyword: 'kampas rem',
      defaultAction: 'inspect',
      defaultCountsAsReplacement: false,
      icon: Icons.shopping_bag_outlined,
    ),
    _ExpenseCategoryOption(
      id: 'servis_ringan',
      label: 'Servis Ringan / Oli',
      componentKeyword: 'oli mesin',
      defaultAction: 'replace',
      defaultCountsAsReplacement: true,
      icon: Icons.oil_barrel_outlined,
    ),
    _ExpenseCategoryOption(
      id: 'ban_tambal',
      label: 'Ban / Tambal',
      componentKeyword: 'ban',
      defaultAction: 'repair',
      defaultCountsAsReplacement: false,
      icon: Icons.tire_repair_outlined,
    ),
    _ExpenseCategoryOption(
      id: 'cuci_perawatan',
      label: 'Cuci & Detailing',
      componentKeyword: 'suspensi',
      defaultAction: 'clean',
      defaultCountsAsReplacement: false,
      icon: Icons.local_car_wash_outlined,
    ),
    _ExpenseCategoryOption(
      id: 'kelistrikan',
      label: 'Kelistrikan / Aki',
      componentKeyword: 'aki',
      defaultAction: 'inspect',
      defaultCountsAsReplacement: false,
      icon: Icons.battery_charging_full_outlined,
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _laborController = TextEditingController();
  final _merchantController = TextEditingController();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategoryId = 'sparepart';
  DateTime _expenseDate = DateTime.now();
  List<ComponentType> _applicableComponents = [];
  int? _selectedComponentId;
  bool _applyAsReplacement = false;
  bool _saving = false;
  Motorcycle? _targetMotor;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final db = ref.read(databaseProvider);
    final resolvedId = widget.motorcycleId ?? ref.read(activeMotorcycleProvider)?.id;
    Motorcycle? motor;
    if (resolvedId != null) {
      motor = await db.getMotorcycle(resolvedId);
    }
    final components = await db.getApplicableComponentsForModel(motor?.modelId);
    if (!mounted) return;
    setState(() {
      _targetMotor = motor;
      _applicableComponents = components;
      _selectComponentForCategory(_selectedCategoryId);
    });
  }

  void _selectComponentForCategory(String categoryId) {
    final option = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => _categories.first,
    );
    _applyAsReplacement = option.defaultCountsAsReplacement;
    if (_applicableComponents.isEmpty) return;

    final match = _applicableComponents.where(
      (c) => c.name.toLowerCase().contains(option.componentKeyword),
    );
    _selectedComponentId = match.isNotEmpty
        ? match.first.id
        : _applicableComponents.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _laborController.dispose();
    _merchantController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedComponentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih komponen terkait terlebih dahulu.')),
      );
      return;
    }

    final motorId = _targetMotor?.id ?? widget.motorcycleId;
    if (motorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Motor target tidak ditemukan.')),
      );
      return;
    }

    final partsCost = Formatters.parseCurrencyInt(_amountController.text) ?? 0;
    final laborCost = Formatters.parseCurrencyInt(_laborController.text) ?? 0;
    if (partsCost + laborCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal pengeluaran lebih dari Rp 0.')),
      );
      return;
    }

    final odoText = _odometerController.text.trim();
    final odoVal = odoText.isNotEmpty ? double.tryParse(odoText) : null;
    final option = _categories.firstWhere((c) => c.id == _selectedCategoryId);
    final noteText = _notesController.text.trim().isEmpty
        ? option.label
        : '${option.label}: ${_notesController.text.trim()}';
    final action = _applyAsReplacement ? 'replace' : option.defaultAction;

    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);
      await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: _expenseDate,
          odometerKm: Value(odoVal),
          workshopName: Value(
            _merchantController.text.trim().isEmpty
                ? null
                : _merchantController.text.trim(),
          ),
          notes: Value(noteText),
          totalCost: Value(partsCost + laborCost),
        ),
        items: [
          ServiceItemsCompanion.insert(
            serviceRecordId: 0,
            componentTypeId: Value(_selectedComponentId),
            action: action,
            partsCost: Value(partsCost),
            laborCost: Value(laborCost),
            totalCost: Value(partsCost + laborCost),
            notes: Value(noteText),
          ),
        ],
        odometerKm: odoVal,
        // Pengeluaran non-penggantian tidak otomatis menutup keluhan teknis.
        resolveComplaints: _applyAsReplacement,
      );

      ref.invalidate(serviceRecordsProvider(motorId));
      ref.invalidate(motorcycleExpenseSummaryProvider(motorId));
      ref.invalidate(latestOdometerProvider(motorId));
      ref.invalidate(odometerLogsProvider(motorId));
      ref.invalidate(componentStatusesProvider(motorId));
      ref.invalidate(componentStatusesWithNamesProvider(motorId));
      ref.invalidate(budgetPlanSummaryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengeluaran ${Formatters.currency(partsCost + laborCost)} tercatat!',
            ),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/history');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCategory = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/history');
            }
          },
        ),
        title: const Text('Catat Pengeluaran'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            if (_targetMotor != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.line),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: BuildHausTheme.ok.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: BuildHausTheme.ok,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _targetMotor!.nickname,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: context.ink,
                            ),
                          ),
                          Text(
                            'Catat biaya part, perawatan ringan, atau jasa bengkel',
                            style: TextStyle(fontSize: 11, color: context.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              'Kategori Pengeluaran',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final selected = cat.id == _selectedCategoryId;
                return ChoiceChip(
                  avatar: Icon(
                    cat.icon,
                    size: 16,
                    color: selected ? context.bg : BuildHausTheme.ok,
                  ),
                  label: Text(cat.label),
                  selected: selected,
                  selectedColor: context.ink,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? context.bg : context.ink,
                  ),
                  onSelected: (_) => setState(() {
                    _selectedCategoryId = cat.id;
                    _selectComponentForCategory(cat.id);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Nominal Biaya Utama
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biaya Utama / Part (Rp) *',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const ValueKey('expense_amount_field'),
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [IdrTextInputFormatter()],
                        decoration: const InputDecoration(
                          hintText: 'Contoh: 65.000',
                          prefixText: 'Rp ',
                        ),
                        validator: (v) {
                          final raw = v?.trim() ?? '';
                          if (raw.isEmpty) return 'Masukkan nominal';
                          final n = Formatters.parseCurrencyInt(raw);
                          if (n == null || n < 0) return 'Angka tidak valid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biaya Jasa (Rp)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const ValueKey('expense_labor_field'),
                        controller: _laborController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [IdrTextInputFormatter()],
                        decoration: const InputDecoration(
                          hintText: '0 (opsional)',
                          prefixText: 'Rp ',
                        ),
                        validator: (v) {
                          final raw = v?.trim() ?? '';
                          if (raw.isEmpty) return null;
                          final n = Formatters.parseCurrencyInt(raw);
                          if (n == null || n < 0) return 'Angka tidak valid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Komponen terkait
            if (_applicableComponents.isNotEmpty) ...[
              Text(
                'Komponen Terkait',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: context.ink,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _selectedComponentId,
                items: _applicableComponents
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedComponentId = v),
              ),
              const SizedBox(height: 10),
            ],

            // Toggle apakah langsung dipasang / reset siklus komponen
            Container(
              decoration: BoxDecoration(
                color: context.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.line),
              ),
              child: SwitchListTile.adaptive(
                value: _applyAsReplacement,
                onChanged: (v) => setState(() => _applyAsReplacement = v),
                title: Text(
                  'Reset siklus kesehatan komponen',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.ink,
                  ),
                ),
                subtitle: Text(
                  _applyAsReplacement
                      ? 'Skor komponen direset ke kondisi baru (${activeCategory.label})'
                      : 'Hanya catat pengeluaran tanpa mereset umur pakai komponen',
                  style: TextStyle(fontSize: 11, color: context.muted),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tanggal & Tempat/Toko
            Text(
              'Tanggal Pengeluaran',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expenseDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _expenseDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: context.line),
                ),
                child: Row(
                  children: [
                    Text(_fmtDate(_expenseDate), style: TextStyle(color: context.ink)),
                    const Spacer(),
                    Icon(Icons.calendar_today, size: 18, color: context.muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'Nama Toko / Bengkel (opsional)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _merchantController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Bengkel AHASS / Toko Sparepart',
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'Odometer Saat Ini (opsional)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Contoh: 14850'),
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return 'Masukkan angka km yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            Text(
              'Catatan Tambahan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Contoh: Beli kampas rem depan cadangan / cuci wax',
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              key: const ValueKey('save_expense_button'),
              onPressed: _saving ? null : _saveExpense,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: const Text('Simpan Pengeluaran'),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
