import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/engines/motorcycle_specs.dart';
import '../../../../core/engines/self_inspection_engine.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../motorcycles/presentation/screens/add_motorcycle_screen.dart';

class InitialMotorSetupScreen extends ConsumerStatefulWidget {
  const InitialMotorSetupScreen({super.key});

  @override
  ConsumerState<InitialMotorSetupScreen> createState() =>
      _InitialMotorSetupScreenState();
}

class _InitialMotorSetupScreenState
    extends ConsumerState<InitialMotorSetupScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _plateController = TextEditingController();
  final _odometerController = TextEditingController();

  int _currentStep = 0; // 0 = Identitas, 1 = Riwayat Servis, 2 = Kondisi Fisik
  bool _saving = false;

  // Step 1 fields
  String? _selectedBrand;
  MotorcycleModel? _selectedModel;
  int _selectedYear = DateTime.now().year;
  String _selectedUsage = 'harian_dalam_kota';

  // Step 2 fields (Maintenance history baseline)
  String _oilHistory = 'baru';
  String _transmissionHistory = 'baru';
  String _brakeHistory = 'baru';
  String _generalHistory = 'sedang';

  // Step 3 fields (Physical inspection baseline)
  final Map<String, String> _inspectionAnswers = {};

  static const _preferredBrandOrder = ['Honda', 'Yamaha', 'Kawasaki'];

  final List<int> _years = List.generate(
    DateTime.now().year - 1990 + 1,
    (i) => DateTime.now().year - i,
  );

  static const _usageOptions = [
    (
      'harian_dalam_kota',
      'Harian Dalam Kota',
      'Komuter kerja/kuliah, sering macet (stop & go)',
      Icons.location_city_rounded,
    ),
    (
      'jarak_jauh',
      'Jarak Jauh / Touring',
      'Rute antar kota atau kilometer harian tinggi',
      Icons.route_rounded,
    ),
    (
      'campuran',
      'Campuran',
      'Kombinasi pemakaian harian dan perjalanan jauh',
      Icons.sync_alt_rounded,
    ),
  ];

  static const _historyLevels = [
    (
      'baru',
      'Baru Servis / Ganti',
      '< 1 bulan / < 500 km lalu',
      BuildHausTheme.ok,
    ),
    (
      'sedang',
      'Cukup Rutin (Normal)',
      '1 - 3 bulan lalu (Kondisi wajar)',
      Color(0xFF3B82F6),
    ),
    (
      'lama',
      'Sudah Lama Belum Servis',
      '> 4 bulan / sudah mendekati batas pakai',
      BuildHausTheme.warn,
    ),
    (
      'belum_tahu',
      'Lupa / Belum Pernah Cek',
      'Perlu dijadwalkan pengecekan awal',
      BuildHausTheme.danger,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _syncInspectionAnswers();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  List<InspectionQuestion> get _currentInspectionQuestions =>
      SelfInspectionEngine.questionsForMotorcycle(
        _selectedModel,
        manufactureYear: _selectedYear,
      );

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

  void _syncInspectionAnswers() {
    final questions = _currentInspectionQuestions;
    final validCodes = {for (final q in questions) q.code};
    _inspectionAnswers.removeWhere((code, _) => !validCodes.contains(code));
    for (final q in questions) {
      final currentCode = _inspectionAnswers[q.code];
      final valid =
          currentCode != null && q.options.any((o) => o.code == currentCode);
      if (!valid && q.options.isNotEmpty) {
        _inspectionAnswers[q.code] = q.options.first.code;
      }
    }
  }

  int _computePreviewScore() {
    int scoreForHistory(String level) {
      switch (level) {
        case 'baru':
          return 85;
        case 'sedang':
          return 58;
        case 'lama':
          return 25;
        case 'belum_tahu':
          return 12;
        default:
          return 65;
      }
    }

    final baseAvg =
        (scoreForHistory(_oilHistory) * 3 +
            scoreForHistory(_transmissionHistory) * 3 +
            scoreForHistory(_brakeHistory) * 3 +
            scoreForHistory(_generalHistory) * 5) /
        14.0;

    final ageMultiplier = MotorcycleSpecs.ageIntervalMultiplier(
      _selectedYear,
      model: _selectedModel,
    );
    final ageAdjustedBase = baseAvg * (0.7 + 0.3 * ageMultiplier);

    final eval = SelfInspectionEngine.evaluateForMotorcycle(
      _inspectionAnswers,
      model: _selectedModel,
      manufactureYear: _selectedYear,
    );
    double penalty = 0;
    for (final f in eval.allFindings) {
      if (f.isSafetyCritical || f.riskLevel == 'high') {
        penalty += 14;
      } else if (f.riskLevel == 'medium') {
        penalty += 7;
      } else {
        penalty += 3;
      }
    }

    return (ageAdjustedBase - penalty).round().clamp(10, 98);
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_step1FormKey.currentState!.validate()) return;
      if (_selectedModel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih model motor Anda terlebih dahulu.'),
          ),
        );
        return;
      }
    }
    setState(() {
      _currentStep = (_currentStep + 1).clamp(0, 2);
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitAll() async {
    final model = _selectedModel;
    if (model == null) return;

    _syncInspectionAnswers();
    final odoVal =
        Formatters.parseOdometerDouble(_odometerController.text) ?? 0.0;
    final formattedPlate = Formatters.formatPlateNumber(_plateController.text);

    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);
      final motorId = await db.createMotorcycleWithInitialHealth(
        motorcycle: MotorcyclesCompanion.insert(
          modelId: Value(model.id),
          nickname: _nicknameController.text.trim(),
          manufactureYear: _selectedYear,
          plateNumber: Value(formattedPlate.isEmpty ? null : formattedPlate),
          emoji: const Value('🏍️'),
          usageProfile: Value(_selectedUsage),
        ),
        initialOdometerKm: odoVal,
        oilHistory: _oilHistory,
        transmissionHistory: _transmissionHistory,
        brakeHistory: _brakeHistory,
        generalHistory: _generalHistory,
        initialInspectionAnswers: Map<String, String>.from(_inspectionAnswers),
      );

      // Sync reminders for this new motor
      try {
        final reminderEngine = ref.read(reminderEngineProvider);
        await reminderEngine.syncRemindersForMotorcycle(motorId);
      } catch (_) {}

      final createdMotor = await db.getMotorcycle(motorId);
      if (createdMotor != null) {
        await ref
            .read(activeMotorcycleProvider.notifier)
            .setActiveMotorcycle(createdMotor);
      }

      ref.invalidate(motorcyclesProvider);
      ref.invalidate(activeMotorcycleProvider);
      ref.invalidate(componentStatusesProvider(motorId));
      ref.invalidate(componentStatusesWithNamesProvider(motorId));
      ref.invalidate(latestOdometerProvider(motorId));
      ref.invalidate(latestSelfInspectionProvider(motorId));

      await ref.read(authProvider.notifier).completeOnboarding();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final modelsAsync = ref.watch(motorcycleModelsGroupedProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: modelsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error memuat katalog: $e')),
          data: (modelsByBrand) {
            final brands = _sortedAllowedBrands(modelsByBrand);
            if (brands.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Data model motor belum tersedia. Pastikan database sudah diinisialisasi.',
                    style: TextStyle(color: context.muted),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (_selectedBrand == null || !brands.contains(_selectedBrand)) {
              _selectedBrand = brands.contains('Honda')
                  ? 'Honda'
                  : brands.first;
            }
            final brandModels = modelsByBrand[_selectedBrand] ?? [];
            if (brandModels.isNotEmpty &&
                (_selectedModel == null ||
                    !brandModels.any((m) => m.id == _selectedModel!.id))) {
              _selectedModel = brandModels.first;
              final validYears = _validYearsForModel(_selectedModel);
              if (!validYears.contains(_selectedYear)) {
                _selectedYear = validYears.first;
              }
              _syncInspectionAnswers();
            }

            return Column(
              children: [
                // Top Header & Progress Indicator
                _buildTopHeader(context, auth.userName),
                const Divider(height: 1),

                // Step Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _currentStep == 0
                            ? _buildStep1Identity(
                                context,
                                brands,
                                brandModels,
                              )
                            : _currentStep == 1
                            ? _buildStep2History(context)
                            : _buildStep3PhysicalAndPreview(context),
                      ),
                    ),
                  ),
                ),

                // Bottom Action Bar
                _buildBottomActionBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, String userName) {
    final steps = [
      '1. Identitas Motor',
      '2. Riwayat Servis',
      '3. Cek Fisik & Skor',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: context.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: BuildHausTheme.ok.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'WAJIB • SETUP AWAL',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: BuildHausTheme.ok,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Halo, $userName 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Data Kesehatan Motor Pertama',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Masukkan data motor dan kondisi terakhirnya agar BuildHaus dapat menghitung status kesehatan awal secara akurat.',
            style: TextStyle(fontSize: 12, color: context.muted),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(steps.length, (i) {
              final active = i == _currentStep;
              final done = i < _currentStep;
              final color = done || active ? BuildHausTheme.ok : context.line;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active || done
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: active || done ? context.ink : context.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Identity(
    BuildContext context,
    List<String> brands,
    List<MotorcycleModel> brandModels,
  ) {
    final model = _selectedModel;
    final yearsToUse = _validYearsForModel(model);
    if (!yearsToUse.contains(_selectedYear)) {
      _selectedYear = yearsToUse.first;
    }

    return Form(
      key: _step1FormKey,
      child: Column(
        key: const ValueKey('setup_step_1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionBanner(
            icon: Icons.two_wheeler_rounded,
            title: 'Identitas & Kilometer Motor',
            subtitle:
                'Data merek, model, dan kilometer saat ini digunakan untuk mencocokkan standar interval pabrikan.',
          ),
          const SizedBox(height: 18),

          _Label('Nama Panggilan Motor *'),
          TextFormField(
            key: const ValueKey('setup_nickname_field'),
            controller: _nicknameController,
            decoration: const InputDecoration(
              hintText: 'Contoh: Vario 160 Hitam / Motor Harian',
              prefixIcon: Icon(Icons.badge_outlined, size: 20),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Nama motor wajib diisi'
                : null,
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Merek Motor *'),
                    DropdownButtonFormField<String>(
                      key: ValueKey('brand_$_selectedBrand'),
                      initialValue: brands.contains(_selectedBrand)
                          ? _selectedBrand
                          : null,
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
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _selectedBrand = v;
                          final newModels =
                              ref
                                  .read(motorcycleModelsGroupedProvider)
                                  .valueOrNull?[v] ??
                              [];
                          _selectedModel = newModels.isNotEmpty
                              ? newModels.first
                              : null;
                          final valid = _validYearsForModel(_selectedModel);
                          if (!valid.contains(_selectedYear)) {
                            _selectedYear = valid.first;
                          }
                          _syncInspectionAnswers();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Tahun *'),
                    DropdownButtonFormField<int>(
                      key: ValueKey('year_${_selectedModel?.id}_$_selectedYear'),
                      initialValue: _selectedYear,
                      isExpanded: true,
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
                        if (v == null) return;
                        setState(() {
                          _selectedYear = v;
                          _syncInspectionAnswers();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _Label('Model / Tipe Motor *'),
          DropdownButtonFormField<MotorcycleModel>(
            key: ValueKey('model_${_selectedBrand}_${_selectedModel?.id}'),
            initialValue:
                brandModels.any((m) => m.id == _selectedModel?.id)
                    ? _selectedModel
                    : null,
            isExpanded: true,
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
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _selectedModel = v;
                final valid = _validYearsForModel(v);
                if (!valid.contains(_selectedYear)) {
                  _selectedYear = valid.first;
                }
                _syncInspectionAnswers();
              });
            },
            validator: (v) => v == null ? 'Pilih model motor' : null,
          ),
          const SizedBox(height: 14),

          _Label('Odometer Saat Ini (km) *'),
          TextFormField(
            key: const ValueKey('setup_odometer_field'),
            controller: _odometerController,
            keyboardType: TextInputType.number,
            inputFormatters: const [OdometerTextInputFormatter()],
            decoration: const InputDecoration(
              hintText: 'Contoh: 14.500',
              prefixIcon: Icon(Icons.speed_rounded, size: 20),
              suffixText: 'km',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Odometer wajib diisi';
              }
              final parsed = Formatters.parseOdometerDouble(v);
              if (parsed == null || parsed < 0) {
                return 'Masukkan angka km valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          _Label('Plat Nomor'),
          TextFormField(
            key: const ValueKey('setup_plate_field'),
            controller: _plateController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: const [IndonesiaPlateTextInputFormatter()],
            decoration: const InputDecoration(
              hintText: 'Contoh: B 2841 RDM (otomatis spasi)',
              prefixIcon: Icon(Icons.pin_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 18),

          _Label('Pola Pemakaian Motor *'),
          ..._usageOptions.map((item) {
            final (code, title, subtitle, icon) = item;
            final selected = _selectedUsage == code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedUsage = code),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? BuildHausTheme.ok.withValues(alpha: 0.12)
                        : context.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? BuildHausTheme.ok : context.line,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: selected ? BuildHausTheme.ok : context.muted,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.ink,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected ? BuildHausTheme.ok : context.muted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep2History(BuildContext context) {
    final model = _selectedModel;
    final matic = MotorcycleSpecs.isMaticOrNull(model);
    final is2T = MotorcycleSpecs.is2Stroke(model);
    final isCarb = MotorcycleSpecs.isCarburetor(
      model,
      manufactureYear: _selectedYear,
    );
    final isLiquid = MotorcycleSpecs.isLiquidCooledOrNull(model);
    final fuelLabel = MotorcycleSpecs.fuelSystemLabel(
      model,
      manufactureYear: _selectedYear,
    );
    final transmissionLabel = MotorcycleSpecs.transmissionLabel(model);
    final ageLabel = MotorcycleSpecs.ageCategoryLabel(_selectedYear);

    final oilTitle = is2T
        ? '1. Oli Samping (2T) & Oli Gearbox'
        : '1. Oli Mesin & Filter Oli';
    final oilSubtitle = is2T
        ? 'Kapan terakhir Anda mengecek/mengisi oli samping 2-tak dan oli mesin/gearbox?'
        : 'Kapan terakhir Anda mengganti oli mesin motor ini?';

    final transTitle = matic == true
        ? '2. Transmisi CVT, V-Belt & Oli Gardan'
        : matic == false
        ? '2. Rantai, Gir & Kopling'
        : '2. Transmisi (CVT / Rantai & Gir)';
    final transSubtitle = matic == true
        ? 'Kapan terakhir servis pembersihan CVT, roller, atau ganti oli gardan?'
        : matic == false
        ? 'Kapan terakhir menyetel/melumasi rantai & gir atau memeriksa kopling?'
        : 'Kapan terakhir menyervis area transmisi motor ini?';

    final generalParts = [
      'Busi',
      'Filter Udara',
      if (is2T)
        'Karburator 2-Tak'
      else if (isCarb)
        'Karburator'
      else
        'Sistem Injeksi',
      if (isLiquid == true) 'Coolant',
      'Aki & Kaki-kaki',
    ].join(', ');

    final generalSubtitle = is2T || isCarb
        ? 'Kapan terakhir servis karburator & tune-up berkala ($fuelLabel, $_selectedYear)?'
        : 'Kapan terakhir melakukan servis berkala / tune-up lengkap ($fuelLabel, $_selectedYear)?';

    return Column(
      key: const ValueKey('setup_step_2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionBanner(
          icon: Icons.history_edu_rounded,
          title: 'Riwayat Servis & Penggantian Terakhir',
          subtitle:
              'Pertanyaan disesuaikan dengan profil ${model != null ? '${model.brand} ${model.model}' : 'motor'} ($_selectedYear • $ageLabel).',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _SpecPill(label: transmissionLabel),
            _SpecPill(label: fuelLabel),
            _SpecPill(label: MotorcycleSpecs.coolingLabel(model)),
          ],
        ),
        const SizedBox(height: 16),

        _HistoryQuestionCard(
          title: oilTitle,
          subtitle: oilSubtitle,
          icon: Icons.water_drop_outlined,
          selectedValue: _oilHistory,
          onChanged: (v) => setState(() => _oilHistory = v),
        ),
        const SizedBox(height: 14),

        _HistoryQuestionCard(
          title: transTitle,
          subtitle: transSubtitle,
          icon: Icons.settings_suggest_outlined,
          selectedValue: _transmissionHistory,
          onChanged: (v) => setState(() => _transmissionHistory = v),
        ),
        const SizedBox(height: 14),

        _HistoryQuestionCard(
          title: '3. Kampas Rem & Minyak Rem',
          subtitle: 'Bagaimana riwayat pengecekan atau penggantian rem?',
          icon: Icons.album_outlined,
          selectedValue: _brakeHistory,
          onChanged: (v) => setState(() => _brakeHistory = v),
        ),
        const SizedBox(height: 14),

        _HistoryQuestionCard(
          title: '4. $generalParts',
          subtitle: generalSubtitle,
          icon: Icons.build_circle_outlined,
          selectedValue: _generalHistory,
          onChanged: (v) => setState(() => _generalHistory = v),
        ),
      ],
    );
  }

  Widget _buildStep3PhysicalAndPreview(BuildContext context) {
    final questions = _currentInspectionQuestions;
    final fuelLabel = MotorcycleSpecs.fuelSystemLabel(
      _selectedModel,
      manufactureYear: _selectedYear,
    );
    final ageLabel = MotorcycleSpecs.ageCategoryLabel(_selectedYear);
    final previewScore = _computePreviewScore();
    final Color scoreColor = previewScore >= 75
        ? BuildHausTheme.ok
        : previewScore >= 50
        ? BuildHausTheme.warn
        : BuildHausTheme.danger;
    final String scoreLabel = previewScore >= 75
        ? 'Kondisi Baik & Terawat'
        : previewScore >= 50
        ? 'Perlu Perhatian Beberapa Part'
        : 'Perlu Pemeriksaan & Servis Segera';

    return Column(
      key: const ValueKey('setup_step_3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Health Score Preview Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scoreColor.withValues(alpha: 0.18),
                context.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scoreColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    '$previewScore%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: scoreColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMASI SKOR KESEHATAN AWAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scoreLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dihitung dari riwayat servis, profil $_selectedYear ($ageLabel • $fuelLabel), & cek fisik.',
                      style: TextStyle(fontSize: 11, color: context.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        _SectionBanner(
          icon: Icons.fact_check_outlined,
          title: 'Kondisi Fisik Motor Saat Ini',
          subtitle:
              'Pertanyaan disesuaikan untuk ${_selectedModel?.model ?? 'motor Anda'} ($_selectedYear • $fuelLabel).',
        ),
        const SizedBox(height: 14),

        ...questions.map((q) {
          final currentVal =
              _inspectionAnswers[q.code] ?? q.options.first.code;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    q.question,
                    style: TextStyle(fontSize: 11, color: context.muted),
                  ),
                  const SizedBox(height: 10),
                  ...q.options.map((opt) {
                    final isSelected = currentVal == opt.code;
                    final optColor = !opt.isIssue
                        ? BuildHausTheme.ok
                        : (opt.isSafetyCritical || opt.riskLevel == 'high')
                        ? BuildHausTheme.danger
                        : BuildHausTheme.warn;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            _inspectionAnswers[q.code] = opt.code;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? optColor.withValues(alpha: 0.12)
                                : context.surface2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? optColor : context.line,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                opt.icon,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  opt.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: context.ink,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: optColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final nextLabel = _currentStep == 0
        ? 'Lanjut ke Riwayat Servis'
        : _currentStep == 1
        ? 'Lanjut ke Cek Fisik'
        : 'Simpan & Cek Kesehatan';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.line)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                ),
                onPressed: _saving ? null : _prevStep,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 17),
                    SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Kembali',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 3,
            child: ElevatedButton(
              key: const ValueKey('setup_next_or_save_button'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
              onPressed: _saving
                  ? null
                  : (_currentStep < 2 ? _nextStep : _submitAll),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_saving)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _currentStep < 2
                          ? Icons.arrow_forward_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        nextLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecPill extends StatelessWidget {
  final String label;
  const _SpecPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: BuildHausTheme.ok.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: BuildHausTheme.ok.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: BuildHausTheme.ok,
        ),
      ),
    );
  }
}

class _SectionBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BuildHausTheme.ok.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: BuildHausTheme.ok, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryQuestionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const _HistoryQuestionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = _InitialMotorSetupScreenState._historyLevels;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: BuildHausTheme.ok),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: context.muted),
          ),
          const SizedBox(height: 10),
          ...options.map((opt) {
            final (code, label, desc, color) = opt;
            final selected = selectedValue == code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onChanged(code),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.12)
                        : context.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? color : context.line,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: context.ink,
                              ),
                            ),
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_circle_rounded, size: 18, color: color),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.ink,
        ),
      ),
    );
  }
}
