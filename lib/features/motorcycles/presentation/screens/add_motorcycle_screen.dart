import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/engines/motorcycle_specs.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

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
  String _oilHistory = 'sedang';
  String _transmissionHistory = 'sedang';
  String _brakeHistory = 'sedang';
  String _generalHistory = 'sedang';
  bool _saving = false;

  static const _preferredBrandOrder = ['Honda', 'Yamaha', 'Kawasaki'];

  final List<int> _years = List.generate(
    DateTime.now().year - 1990 + 1,
    (i) => DateTime.now().year - i,
  );
  final _usageProfiles = ['harian_dalam_kota', 'jarak_jauh', 'campuran'];
  final _usageLabels = {
    'harian_dalam_kota': 'Harian dalam kota',
    'jarak_jauh': 'Jarak jauh',
    'campuran': 'Campuran',
  };
  static const _historyLevels = [
    ('baru', 'Baru Servis / Ganti (< 1 bln)'),
    ('sedang', 'Cukup Rutin / Normal (1-3 bln)'),
    ('lama', 'Sudah Lama Belum Servis (> 4 bln)'),
    ('belum_tahu', 'Lupa / Belum Pernah Cek'),
  ];
  static const _presetOptions = [
    ('baru', 'Baru Servis'),
    ('sedang', 'Normal'),
    ('lama', 'Sudah Lama'),
    ('belum_tahu', 'Belum Tahu'),
  ];

  List<String> _sortedAllowedBrands(
    Map<String, List<MotorcycleModel>> modelsByBrand,
  ) {
    final brands = modelsByBrand.keys
        .where(MotorcycleSpecs.isAllowedBrand)
        .where((b) => (modelsByBrand[b] ?? const []).isNotEmpty)
        .toList();
    brands.sort((a, b) {
      final ia = _preferredBrandOrder.indexWhere(
        (p) => p.toLowerCase() == a.trim().toLowerCase(),
      );
      final ib = _preferredBrandOrder.indexWhere(
        (p) => p.toLowerCase() == b.trim().toLowerCase(),
      );
      if (ia != -1 && ib != -1) return ia.compareTo(ib);
      if (ia != -1) return -1;
      if (ib != -1) return 1;
      return a.compareTo(b);
    });
    return brands;
  }

  List<int> _validYearsForModel(MotorcycleModel? model) {
    if (model == null) return _years;
    final minYear = model.yearStart < 1990 ? 1990 : model.yearStart;
    final maxYear = model.yearEnd;
    final filtered = _years
        .where((y) => y >= minYear && (maxYear == null || y <= maxYear))
        .toList();
    return filtered.isNotEmpty ? filtered : _years;
  }

  void _applyConditionPreset(String level) {
    setState(() {
      _oilHistory = level;
      _transmissionHistory = level;
      _brakeHistory = level;
      _generalHistory = level;
    });
  }

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
        title: const Text(
          'Tambah Motor',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: modelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading models: $e')),
        data: (modelsByBrand) {
          final brands = _sortedAllowedBrands(modelsByBrand);
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

          // Inisialisasi nilai awal merek & model default jika belum dipilih
          if (_selectedBrand == null || !brands.contains(_selectedBrand)) {
            _selectedBrand = brands.contains('Honda') ? 'Honda' : brands.first;
          }
          final brandModels = modelsByBrand[_selectedBrand] ?? [];
          if (brandModels.isNotEmpty &&
              (_selectedModel == null ||
                  !brandModels.any((m) => m.id == _selectedModel!.id))) {
            _selectedModel = brandModels.first;
          }
          final yearsToUse = _validYearsForModel(_selectedModel);
          if (!yearsToUse.contains(_selectedYear)) {
            _selectedYear = yearsToUse.first;
          }

          final model = _selectedModel;
          final matic = MotorcycleSpecs.isMaticOrNull(model);
          final is2T = MotorcycleSpecs.is2Stroke(model);
          final isCarb = MotorcycleSpecs.isCarburetor(
            model,
            manufactureYear: _selectedYear,
          );
          final isLiquid = MotorcycleSpecs.isLiquidCooledOrNull(model);
          final oilAreaLabel = is2T
              ? '1. Oli Samping (2T) & Oli Gearbox'
              : '1. Oli Mesin & Filter Oli';
          final transAreaLabel = matic == true
              ? '2. Transmisi CVT, V-Belt & Oli Gardan'
              : matic == false
              ? '2. Rantai, Gir & Kopling'
              : '2. Transmisi (CVT / Rantai)';
          final generalAreaLabel = is2T
              ? '4. Kondisi Umum (Busi, Karbu 2-Tak, Aki & Kaki-kaki)'
              : isCarb
              ? '4. Kondisi Umum (Busi, Karbu, Filter Udara & Aki)'
              : isLiquid == true
              ? '4. Kondisi Umum (Busi, Injeksi, Coolant & Kaki-kaki)'
              : '4. Kondisi Umum (Busi, Injeksi, Filter Udara & Aki)';

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
                    key: ValueKey('add_brand_$_selectedBrand'),
                    initialValue: _selectedBrand,
                    isExpanded: true,
                    decoration: const InputDecoration(),
                    items: brands
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Text(
                              b,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _selectedBrand = v;
                        final newModels = modelsByBrand[v] ?? [];
                        _selectedModel =
                            newModels.isNotEmpty ? newModels.first : null;
                        final valid = _validYearsForModel(_selectedModel);
                        if (!valid.contains(_selectedYear)) {
                          _selectedYear = valid.first;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Model
                  _buildLabel('Model'),
                  DropdownButtonFormField<MotorcycleModel>(
                    key: ValueKey('add_model_${_selectedBrand}_${_selectedModel?.id}'),
                    initialValue:
                        brandModels.any((m) => m.id == _selectedModel?.id)
                            ? _selectedModel
                            : null,
                    isExpanded: true,
                    decoration: const InputDecoration(),
                    items: brandModels.map((m) {
                      final label = m.variant != null
                          ? '${m.model} (${m.variant})'
                          : m.model;
                      return DropdownMenuItem(
                        value: m,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() {
                      _selectedModel = v;
                      final valid = _validYearsForModel(v);
                      if (!valid.contains(_selectedYear)) {
                        _selectedYear = valid.first;
                      }
                    }),
                    validator: (v) => v == null ? 'Pilih model' : null,
                  ),
                  const SizedBox(height: 8),

                  // Year
                  _buildLabel('Tahun'),
                  DropdownButtonFormField<int>(
                    key: ValueKey('add_year_${_selectedModel?.id}_$_selectedYear'),
                    initialValue: _selectedYear,
                    isExpanded: true,
                    decoration: const InputDecoration(),
                    items: yearsToUse
                        .map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text(
                              '$y',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedYear = v);
                    },
                    validator: (v) {
                      final m = _selectedModel;
                      if (m == null || v == null) {
                        return 'Pilih model dan tahun';
                      }
                      final minY = m.yearStart < 1990 ? 1990 : m.yearStart;
                      if (v < minY || (m.yearEnd != null && v > m.yearEnd!)) {
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
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: const [IndonesiaPlateTextInputFormatter()],
                    decoration: const InputDecoration(
                      hintText: 'Contoh: B 2841 RDM (otomatis spasi)',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Odometer
                  _buildLabel('Odometer saat ini (km)'),
                  TextFormField(
                    controller: _odometerController,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [OdometerTextInputFormatter()],
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 14.500',
                      suffixText: 'km',
                    ),
                    validator: (v) {
                      if (v != null && v.trim().isNotEmpty) {
                        final n = Formatters.parseOdometerDouble(v);
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
                    isExpanded: true,
                    decoration: const InputDecoration(),
                    items: _usageProfiles
                        .map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(
                              _usageLabels[u]!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedUsage = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Initial condition per area (matching InitialMotorSetupScreen)
                  _buildLabel('Kondisi riwayat servis awal per area'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetOptions.map((preset) {
                      final (code, label) = preset;
                      final selected =
                          _oilHistory == code &&
                          _transmissionHistory == code &&
                          _brakeHistory == code &&
                          _generalHistory == code;
                      return ChoiceChip(
                        label: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                        selected: selected,
                        onSelected: (_) => _applyConditionPreset(code),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  _buildHistoryDropdown(
                    areaKey: 'oil',
                    label: oilAreaLabel,
                    value: _oilHistory,
                    onChanged: (v) => setState(() => _oilHistory = v),
                  ),
                  const SizedBox(height: 8),

                  _buildHistoryDropdown(
                    areaKey: 'trans',
                    label: transAreaLabel,
                    value: _transmissionHistory,
                    onChanged: (v) => setState(() => _transmissionHistory = v),
                  ),
                  const SizedBox(height: 8),

                  _buildHistoryDropdown(
                    areaKey: 'brake',
                    label: '3. Pengereman (Kampas & Minyak Rem)',
                    value: _brakeHistory,
                    onChanged: (v) => setState(() => _brakeHistory = v),
                  ),
                  const SizedBox(height: 8),

                  _buildHistoryDropdown(
                    areaKey: 'general',
                    label: generalAreaLabel,
                    value: _generalHistory,
                    onChanged: (v) => setState(() => _generalHistory = v),
                  ),

                  const SizedBox(height: 20),

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
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    onPressed: _saving ? null : () => _save(modelsByBrand),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Simpan Motor',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryDropdown({
    required String areaKey,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        DropdownButtonFormField<String>(
          key: ValueKey('${areaKey}_$value'),
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: _historyLevels
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.$1,
                  child: Text(
                    entry.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
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
      final odoText = _odometerController.text.trim();
      final odo =
          (odoText.isEmpty ? null : Formatters.parseOdometerDouble(odoText)) ??
          1000.0;
      final formattedPlate = Formatters.formatPlateNumber(_plateController.text);

      final motorId = await db.createMotorcycleWithInitialHealth(
        motorcycle: MotorcyclesCompanion.insert(
          modelId: Value(selected.id),
          nickname: _nicknameController.text.trim(),
          manufactureYear: _selectedYear,
          plateNumber: Value(formattedPlate.isEmpty ? null : formattedPlate),
          emoji: const Value('🏍️'),
          usageProfile: Value(_selectedUsage),
        ),
        initialOdometerKm: odo,
        oilHistory: _oilHistory,
        transmissionHistory: _transmissionHistory,
        brakeHistory: _brakeHistory,
        generalHistory: _generalHistory,
      );

      // Sync reminders for this new motor
      try {
        final reminderEngine = ref.read(reminderEngineProvider);
        await reminderEngine.syncRemindersForMotorcycle(motorId);
      } catch (_) {}

      // Refresh providers
      ref.invalidate(motorcyclesProvider);
      ref.invalidate(activeMotorcycleProvider);
      ref.invalidate(motorcycleModelsGroupedProvider);
      ref.invalidate(componentStatusesProvider(motorId));
      ref.invalidate(componentStatusesWithNamesProvider(motorId));
      ref.invalidate(latestOdometerProvider(motorId));

      final newMotor = await db.getMotorcycle(motorId);
      if (newMotor != null) {
        await ref
            .read(activeMotorcycleProvider.notifier)
            .setActiveMotorcycle(newMotor);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Motor berhasil ditambahkan! Silakan lengkapi pemeriksaan fisik awal.',
            ),
          ),
        );
        // Langsung arahkan pengguna ke fitur pemeriksaan fisik mandiri untuk motor yang baru ditambahkan
        context.pushReplacement('/motor/$motorId/inspection');
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
