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

class EditMotorcycleScreen extends ConsumerStatefulWidget {
  final int id;
  const EditMotorcycleScreen({super.key, required this.id});

  @override
  ConsumerState<EditMotorcycleScreen> createState() =>
      _EditMotorcycleScreenState();
}

class _EditMotorcycleScreenState extends ConsumerState<EditMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _plateController = TextEditingController();
  final _odometerController = TextEditingController();

  String _selectedUsage = 'campuran';
  bool _saving = false;
  bool _loading = false;
  bool _loaded = false;
  Motorcycle? _motor;
  List<MotorcycleModel> _availableModels = [];
  String? _selectedBrand;
  int? _selectedModelId;
  int _selectedYear = DateTime.now().year;
  double? _initialLatestOdometerKm;
  String _initialOdometerText = '';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  List<String> _allowedBrands(String? currentMotorBrand) {
    final brands = _availableModels
        .map((m) => m.brand)
        .where(
          (b) =>
              MotorcycleSpecs.isAllowedBrand(b) ||
              (currentMotorBrand != null && b == currentMotorBrand),
        )
        .toSet()
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

  Future<void> _load() async {
    if (_loaded || _loading) return;
    _loading = true;
    try {
      final db = ref.read(databaseProvider);
      final m = await db.getMotorcycle(widget.id);
      final models = await db.getAllMotorcycleModels();
      final latestOdo = m != null ? await db.getLatestOdometer(widget.id) : null;
      final matches = models.where((model) => model.id == m?.modelId);
      if (!mounted) return;
      if (m == null) {
        setState(() {
          _loaded = true;
        });
        return;
      }
      final odoText = latestOdo != null
          ? Formatters.formatOdometer(latestOdo.odometerKm)
          : '';
      setState(() {
        _motor = m;
        _availableModels = models;
        _selectedModelId = m.modelId;
        _selectedBrand = matches.isNotEmpty ? matches.first.brand : null;
        _selectedYear = m.manufactureYear;
        _nicknameController.text = m.nickname;
        _plateController.text = m.plateNumber != null
            ? Formatters.formatPlateNumber(m.plateNumber!)
            : '';
        _initialLatestOdometerKm = latestOdo?.odometerKm;
        _initialOdometerText = odoText;
        _odometerController.text = odoText;
        _selectedUsage = m.usageProfile;
        _loaded = true;
      });
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Motor',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_motor == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Edit Motor',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Data motor tidak ditemukan.',
              style: TextStyle(color: context.muted),
            ),
          ),
        ),
      );
    }

    final currentMotorBrand = _availableModels
        .where((m) => m.id == _motor?.modelId)
        .map((m) => m.brand)
        .firstOrNull;
    final brands = _allowedBrands(currentMotorBrand);
    final brandValue = brands.contains(_selectedBrand) ? _selectedBrand : null;
    final brandModels = _availableModels
        .where((m) => m.brand == brandValue)
        .toList();
    final modelValue = brandModels.any((m) => m.id == _selectedModelId)
        ? _selectedModelId
        : null;
    final selectedModel = brandModels
        .where((m) => m.id == modelValue)
        .firstOrNull;
    final yearsToUse = _validYearsForModel(selectedModel);
    final yearValue = yearsToUse.contains(_selectedYear)
        ? _selectedYear
        : yearsToUse.first;
    if (_selectedYear != yearValue) {
      _selectedYear = yearValue;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Motor',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: BuildHausTheme.danger),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profil Motor',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Data ini menentukan rekomendasi sparepart.',
                style: TextStyle(color: context.muted, fontSize: 12),
              ),
              const SizedBox(height: 24),

              _buildLabel('Nama / Nickname'),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  hintText: 'Nama panggilan motor',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),

              _buildLabel('Plat nomor (opsional)'),
              TextFormField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: const [IndonesiaPlateTextInputFormatter()],
                decoration: const InputDecoration(
                  hintText: 'Contoh: B 2841 RDM (otomatis spasi)',
                ),
              ),

              _buildLabel('Merek'),
              DropdownButtonFormField<String>(
                key: ValueKey('edit_brand_$brandValue'),
                initialValue: brandValue,
                isExpanded: true,
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
                onChanged: (value) => setState(() {
                  _selectedBrand = value;
                  final newModels = _availableModels
                      .where((m) => m.brand == value)
                      .toList();
                  final firstModel =
                      newModels.isNotEmpty ? newModels.first : null;
                  _selectedModelId = firstModel?.id;
                  final valid = _validYearsForModel(firstModel);
                  if (!valid.contains(_selectedYear)) {
                    _selectedYear = valid.first;
                  }
                }),
                validator: (v) => v == null ? 'Pilih merek' : null,
              ),
              _buildLabel('Model / Varian'),
              DropdownButtonFormField<int>(
                key: ValueKey('edit_model_${brandValue}_$modelValue'),
                initialValue: modelValue,
                isExpanded: true,
                items: brandModels
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(
                          '${m.model}${m.variant == null ? '' : ' (${m.variant})'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedModelId = v;
                  final matched = _availableModels.where((m) => m.id == v);
                  if (matched.isNotEmpty) {
                    final valid = _validYearsForModel(matched.first);
                    if (!valid.contains(_selectedYear)) {
                      _selectedYear = valid.first;
                    }
                  }
                }),
                validator: (v) => v == null ? 'Pilih model motor' : null,
              ),
              _buildLabel('Tahun motor'),
              DropdownButtonFormField<int>(
                key: ValueKey('edit_year_${modelValue}_$yearValue'),
                initialValue: yearValue,
                isExpanded: true,
                items: yearsToUse
                    .map(
                      (year) => DropdownMenuItem(
                        value: year,
                        child: Text(
                          '$year',
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
                  final matches = _availableModels.where(
                    (m) => m.id == _selectedModelId,
                  );
                  if (matches.isEmpty || v == null) {
                    return 'Pilih model dan tahun';
                  }
                  final model = matches.first;
                  final minY = model.yearStart < 1990 ? 1990 : model.yearStart;
                  return v < minY || (model.yearEnd != null && v > model.yearEnd!)
                      ? 'Tahun tidak cocok dengan model'
                      : null;
                },
              ),

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

              // Odometer quick update
              _buildLabel('Update Odometer (km)'),
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
                    if (n == null || n < 0) return 'Masukkan angka valid';
                  }
                  return null;
                },
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
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Simpan Perubahan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);
      final formattedPlate = Formatters.formatPlateNumber(_plateController.text);
      final trimmedOdo = _odometerController.text.trim();
      final double? odoToSave =
          (trimmedOdo.isEmpty ||
                  (trimmedOdo == _initialOdometerText &&
                      _initialLatestOdometerKm != null))
              ? null
              : Formatters.parseOdometerDouble(trimmedOdo);

      await db.updateMotorcycleWithOdometer(
        motorcycleId: widget.id,
        changes: MotorcyclesCompanion(
          modelId: Value(_selectedModelId),
          manufactureYear: Value(_selectedYear),
          nickname: Value(_nicknameController.text.trim()),
          plateNumber: Value(formattedPlate.isEmpty ? null : formattedPlate),
          emoji: Value(_motor?.emoji ?? '🏍️'),
          usageProfile: Value(_selectedUsage),
          updatedAt: Value(DateTime.now()),
        ),
        odometerKm: odoToSave,
      );

      ref.invalidate(motorcyclesProvider);
      ref.invalidate(motorcyclesByIdProvider(widget.id));
      ref.invalidate(latestOdometerProvider(widget.id));
      ref.invalidate(odometerLogsProvider(widget.id));
      ref.invalidate(mileagePredictorProvider(widget.id));
      ref.invalidate(componentStatusesProvider(widget.id));
      ref.invalidate(componentStatusesWithNamesProvider(widget.id));
      ref.invalidate(budgetPlanSummaryProvider);
      await ref.read(activeMotorcycleProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Perubahan disimpan!')));
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Motor?',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: const Text(
          'Semua data motor ini akan dihapus permanen. Pastikan kamu sudah backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Batal',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Hapus',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: BuildHausTheme.danger),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final db = ref.read(databaseProvider);
      await db.deleteMotorcycle(widget.id);
      ref.invalidate(motorcyclesProvider);
      ref.invalidate(activeMotorcycleProvider);
      await ref.read(activeMotorcycleProvider.notifier).refresh();
      if (context.mounted) {
        context.go('/home');
      }
    }
  }
}
