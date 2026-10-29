import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

// Provider for motorcycle models grouped by brand
final motorcycleModelsGroupedProvider =
    FutureProvider<Map<String, List<MotorcycleModel>>>((ref) async {
      final db = ref.watch(databaseProvider);
      return db.getMotorcycleModelsGrouped();
    });

class AddMotorcycleScreen extends ConsumerStatefulWidget {
  const AddMotorcycleScreen({super.key});

  @override
  ConsumerState<AddMotorcycleScreen> createState() =>
      _AddMotorcycleScreenState();
}

class _AddMotorcycleScreenState extends ConsumerState<AddMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _plateController = TextEditingController();
  final _odometerController = TextEditingController();

  String? _selectedBrand;
  MotorcycleModel? _selectedModel;
  int _selectedYear = DateTime.now().year;
  String _selectedUsage = 'campuran';
  String _initialCondition = 'baru';
  bool _saving = false;

  final _years = List.generate(15, (i) => DateTime.now().year - i);
  final _usageProfiles = ['harian_dalam_kota', 'jarak_jauh', 'campuran'];
  final _usageLabels = {
    'harian_dalam_kota': 'Harian dalam kota',
    'jarak_jauh': 'Jarak jauh',
    'campuran': 'Campuran',
  };
  final _conditionLabels = {
    'baru': 'Baru diservis / Kondisi Prima (~85%)',
    'sedang': 'Pemakaian Normal / Rutin (~60%)',
    'lama': 'Sudah lama belum servis (~25%)',
  };

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelsAsync = ref.watch(motorcycleModelsGroupedProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Tambah Motor'),
      ),
      body: modelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading models: $e')),
        data: (modelsByBrand) {
          final brands = modelsByBrand.keys.toList()..sort();
          if (brands.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Data model motor belum tersedia. Pastikan database sudah diinisialisasi.',
                  style: TextStyle(color: context.muted),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Initialize defaults if not set
          _selectedBrand ??= brands.first;
          final brandModels = modelsByBrand[_selectedBrand] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Motor baru',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Catat motor lain yang kamu punya.',
                    style: TextStyle(color: context.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 24),

                  // Nickname
                  _buildLabel('Nama / Plat nomor'),
                  TextFormField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Honda Beat B 1234 XYZ',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),

                  // Brand
                  _buildLabel('Merek'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBrand,
                    decoration: const InputDecoration(),
                    items: brands
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _selectedBrand = v;
                        _selectedModel = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Model
                  _buildLabel('Model'),
                  DropdownButtonFormField<MotorcycleModel>(
                    key: ValueKey(_selectedBrand),
                    initialValue: _selectedModel,
                    decoration: const InputDecoration(),
                    items: brandModels.map((m) {
                      final label = m.variant != null
                          ? '${m.model} (${m.variant})'
                          : m.model;
                      return DropdownMenuItem(value: m, child: Text(label));
                    }).toList(),
                    onChanged: (v) => setState(() {
                      _selectedModel = v;
                      if (v != null &&
                          (_selectedYear < v.yearStart ||
                              (v.yearEnd != null &&
                                  _selectedYear > v.yearEnd!))) {
                        _selectedYear = v.yearStart;
                      }
                    }),
                    validator: (v) => v == null ? 'Pilih model' : null,
                  ),
                  const SizedBox(height: 8),

                  // Year
                  _buildLabel('Tahun'),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedYear,
                    decoration: const InputDecoration(),
                    items: _years
                        .map(
                          (y) => DropdownMenuItem(value: y, child: Text('$y')),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedYear = v!),
                    validator: (v) {
                      final model = _selectedModel;
                      if (model == null || v == null) {
                        return 'Pilih model dan tahun';
                      }
                      if (v < model.yearStart ||
                          (model.yearEnd != null && v > model.yearEnd!)) {
                        return 'Tahun tidak sesuai model';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Plate
                  _buildLabel('Plat nomor (opsional)'),
                  TextFormField(
                    controller: _plateController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: B 1234 XYZ',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Odometer
                  _buildLabel('Odometer saat ini (km)'),
                  TextFormField(
                    controller: _odometerController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Contoh: 8500'),
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final n = double.tryParse(v);
                        if (n == null || n < 0) {
                          return 'Masukkan angka yang valid';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Usage
                  _buildLabel('Jenis pemakaian'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedUsage,
                    decoration: const InputDecoration(),
                    items: _usageProfiles
                        .map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(_usageLabels[u]!),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedUsage = v!),
                  ),
                  const SizedBox(height: 8),

                  // Initial condition
                  _buildLabel('Kondisi kesehatan awal motor'),
                  DropdownButtonFormField<String>(
                    initialValue: _initialCondition,
                    decoration: const InputDecoration(),
                    items: _conditionLabels.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _initialCondition = v!),
                  ),

                  const SizedBox(height: 24),

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
                        const Text('ℹ️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Motor pertama yang ditambahkan otomatis menjadi motor utama.',
                            style: TextStyle(
                              color: context.muted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _saving ? null : () => _save(modelsByBrand),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan Motor'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: context.ink,
        ),
      ),
    );
  }

  Future<void> _save(Map<String, List<MotorcycleModel>> modelsByBrand) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);

      final selected = _selectedModel;
      if (selected == null || selected.brand != _selectedBrand) {
        throw StateError('Pilih model motor yang tersedia.');
      }
      final isFirst = (await db.getAllMotorcycles()).isEmpty;
      final odoText = _odometerController.text.trim();
      final odo = (odoText.isEmpty ? null : double.tryParse(odoText)) ?? 1000.0;
      final motorId = await db.createMotorcycleWithInitialHealth(
        motorcycle: MotorcyclesCompanion.insert(
          modelId: Value(selected.id),
          nickname: _nicknameController.text.trim(),
          manufactureYear: _selectedYear,
          plateNumber: Value(
            _plateController.text.trim().isEmpty
                ? null
                : _plateController.text.trim(),
          ),
          emoji: const Value('🏍️'),
          usageProfile: Value(_selectedUsage),
        ),
        initialOdometerKm: odo,
        oilHistory: _initialCondition,
        transmissionHistory: _initialCondition,
        brakeHistory: _initialCondition,
        generalHistory: _initialCondition,
      );

      // Refresh providers
      ref.invalidate(motorcyclesProvider);
      ref.invalidate(activeMotorcycleProvider);
      ref.invalidate(motorcycleModelsGroupedProvider);
      final newMotor = await db.getMotorcycle(motorId);
      if (newMotor != null) {
        await ref
            .read(activeMotorcycleProvider.notifier)
            .setActiveMotorcycle(newMotor);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFirst
                  ? 'Motor berhasil ditambahkan!'
                  : 'Motor berhasil ditambahkan!',
            ),
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
