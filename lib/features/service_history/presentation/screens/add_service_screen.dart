import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  final int? motorcycleId;
  const AddServiceScreen({super.key, this.motorcycleId});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workshopController = TextEditingController();
  final _notesController = TextEditingController();
  final _odometerController = TextEditingController();

  DateTime _servicedAt = DateTime.now();
  final List<_ServiceItemEntry> _items = [];
  bool _saving = false;
  List<ComponentType> _componentTypes = [];

  @override
  void initState() {
    super.initState();
    _loadComponentTypes();
  }

  Future<void> _loadComponentTypes() async {
    final db = ref.read(databaseProvider);
    final types = await db.getAllComponentTypes();
    if (mounted) setState(() => _componentTypes = types);
  }

  @override
  void dispose() {
    _workshopController.dispose();
    _notesController.dispose();
    _odometerController.dispose();
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
        title: const Text('Catat Servis'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Catat Servis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Catatan perawatan dan biaya.',
              style: TextStyle(color: context.muted, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Date picker
            Text(
              'Tanggal Servis',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _servicedAt,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _servicedAt = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: context.line),
                ),
                child: Row(
                  children: [
                    Text(
                      Formatters.date(_servicedAt),
                      style: TextStyle(color: context.ink),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today, size: 18, color: context.muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Workshop
            Text(
              'Nama Bengkel (opsional)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _workshopController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Sinar Motor',
              ),
            ),
            const SizedBox(height: 12),

            // Odometer
            Text(
              'Odometer (km)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Contoh: 12480'),
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final n = double.tryParse(v);
                  if (n == null || n < 0) return 'Masukkan angka valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Notes
            Text(
              'Catatan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Catatan tambahan...',
              ),
            ),
            const SizedBox(height: 20),

            // Service items
            Row(
              children: [
                Text(
                  'Item Servis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.soft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: [
                    Text(
                      '📋',
                      style: TextStyle(fontSize: 28, color: context.muted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada item servis. Tekan "Tambah" untuk mencatat.',
                      style: TextStyle(color: context.muted, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_items.length, (i) => _buildItemEntry(i)),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan Servis'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemEntry(int index) {
    final item = _items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: item.componentTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Komponen',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _componentTypes.map((ct) {
                    return DropdownMenuItem<int?>(
                      value: ct.id,
                      child: Text(ct.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v == null || _componentTypes.isEmpty) return;
                    final ct = _componentTypes.firstWhere((c) => c.id == v);
                    setState(() {
                      _items[index].componentTypeId = v;
                      _items[index].componentName = ct.name;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: context.muted),
                onPressed: () => setState(() => _items.removeAt(index)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: item.action,
                  decoration: const InputDecoration(
                    labelText: 'Aksi',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'inspect', child: Text('Periksa')),
                    DropdownMenuItem(value: 'replace', child: Text('Ganti')),
                    DropdownMenuItem(value: 'clean', child: Text('Bersihkan')),
                    DropdownMenuItem(value: 'repair', child: Text('Perbaiki')),
                  ],
                  onChanged: (v) => setState(() => _items[index].action = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.partsCost > 0
                      ? item.partsCost.toString()
                      : '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Biaya Part',
                    hintText: '0',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (v) =>
                      _items[index].partsCost = int.tryParse(v) ?? 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: item.laborCost > 0
                      ? item.laborCost.toString()
                      : '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jasa',
                    hintText: '0',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (v) =>
                      _items[index].laborCost = int.tryParse(v) ?? 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addItem() {
    if (_componentTypes.isEmpty) return;
    setState(() {
      _items.add(
        _ServiceItemEntry(
          action: 'replace',
          componentTypeId: _componentTypes.first.id,
          componentName: _componentTypes.first.name,
          partsCost: 0,
          laborCost: 0,
        ),
      );
    });
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu item servis')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);

      int motorId;
      if (widget.motorcycleId != null) {
        motorId = widget.motorcycleId!;
      } else {
        final activeMotor = ref.read(activeMotorcycleProvider);
        if (activeMotor == null) return;
        motorId = activeMotor.id;
      }

      final odoText = _odometerController.text.trim();
      double? odo;
      if (odoText.isNotEmpty) odo = double.tryParse(odoText);

      final totalCost = _items.fold<int>(
        0,
        (sum, item) => sum + item.partsCost + item.laborCost,
      );

      if (_items.any(
        (item) =>
            item.componentTypeId == null ||
            item.partsCost < 0 ||
            item.laborCost < 0,
      )) {
        throw StateError('Semua item harus memiliki komponen dan biaya valid.');
      }
      await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: _servicedAt,
          odometerKm: Value(odo),
          workshopName: Value(
            _workshopController.text.trim().isEmpty
                ? null
                : _workshopController.text.trim(),
          ),
          notes: Value(
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
          totalCost: Value(totalCost),
        ),
        items: _items
            .map(
              (item) => ServiceItemsCompanion(
                componentTypeId: Value(item.componentTypeId),
                action: Value(item.action),
                partsCost: Value(item.partsCost),
                laborCost: Value(item.laborCost),
                totalCost: Value(item.partsCost + item.laborCost),
                notes: Value(item.componentName),
              ),
            )
            .toList(),
        odometerKm: odo,
      );

      ref.invalidate(serviceRecordsProvider(motorId));
      ref.invalidate(latestOdometerProvider(motorId));
      ref.invalidate(componentStatusesProvider(motorId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servis berhasil dicatat!')),
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

class _ServiceItemEntry {
  String action;
  int? componentTypeId;
  String componentName;
  int partsCost;
  int laborCost;

  _ServiceItemEntry({
    required this.action,
    this.componentTypeId,
    required this.componentName,
    required this.partsCost,
    required this.laborCost,
  });
}
