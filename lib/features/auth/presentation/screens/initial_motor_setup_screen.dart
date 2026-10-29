import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/engines/self_inspection_engine.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
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
  final Map<String, String> _inspectionAnswers = {
    'rem_respons': 'normal',
    'rem_bunyi': 'hening',
    'kebocoran_cairan': 'bersih',
    'ban_kondisi': 'bagus',
    'kemudi_stang': 'lurus_stabil',
    'kelistrikan_lampu': 'menyala_terang',
    'mesin_suara': 'halus',
    'cvt_transmisi': 'mulus',
  };

  final _years = List.generate(16, (i) => DateTime.now().year - i);

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
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _odometerController.dispose();
    super.dispose();
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

    final eval = SelfInspectionEngine.evaluate(_inspectionAnswers);
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

    return (baseAvg - penalty).round().clamp(10, 98);
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

    final odoVal =
        double.tryParse(_odometerController.text.trim().replaceAll(',', '.')) ??
        0.0;

    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);
      final motorId = await db.createMotorcycleWithInitialHealth(
        motorcycle: MotorcyclesCompanion.insert(
          modelId: Value(model.id),
          nickname: _nicknameController.text.trim(),
          manufactureYear: _selectedYear,
          plateNumber: Value(
            _plateController.text.trim().isEmpty
                ? null
                : _plateController.text.trim().toUpperCase(),
          ),
          emoji: const Value('🏍️'),
          usageProfile: Value(_selectedUsage),
        ),
        initialOdometerKm: odoVal,
        oilHistory: _oilHistory,
        transmissionHistory: _transmissionHistory,
        brakeHistory: _brakeHistory,
        generalHistory: _generalHistory,
        initialInspectionAnswers: _inspectionAnswers,
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
            final brands = modelsByBrand.keys.toList()..sort();
            if (brands.isNotEmpty && _selectedBrand == null) {
              _selectedBrand = brands.contains('Honda')
                  ? 'Honda'
                  : brands.first;
            }
            final brandModels = modelsByBrand[_selectedBrand] ?? [];
            if (_selectedModel == null && brandModels.isNotEmpty) {
              _selectedModel = brandModels.first;
              _selectedYear = _selectedModel!.yearStart;
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
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: BuildHausTheme.ok,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Halo, $userName 👋',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.muted,
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
    final validYears = model != null
        ? _years
              .where(
                (y) =>
                    y >= model.yearStart &&
                    (model.yearEnd == null || y <= model.yearEnd!),
              )
              .toList()
        : _years;
    final yearsToUse = validYears.isNotEmpty ? validYears : _years;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Merek Motor *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBrand,
                      items: brands
                          .map(
                            (b) => DropdownMenuItem(value: b, child: Text(b)),
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
                          if (_selectedModel != null) {
                            _selectedYear = _selectedModel!.yearStart;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Tahun *'),
                    DropdownButtonFormField<int>(
                      key: ValueKey('year_${_selectedModel?.id}_$_selectedYear'),
                      initialValue: _selectedYear,
                      items: yearsToUse
                          .map(
                            (y) =>
                                DropdownMenuItem(value: y, child: Text('$y')),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedYear = v);
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
            key: ValueKey('model_$_selectedBrand'),
            initialValue: _selectedModel,
            isExpanded: true,
            items: brandModels.map((m) {
              final label = m.variant != null
                  ? '${m.model} (${m.variant})'
                  : m.model;
              return DropdownMenuItem(
                value: m,
                child: Text(label, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _selectedModel = v;
                _selectedYear = v.yearStart;
              });
            },
            validator: (v) => v == null ? 'Pilih model motor' : null,
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Odometer Saat Ini (km) *'),
                    TextFormField(
                      key: const ValueKey('setup_odometer_field'),
                      controller: _odometerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 12500',
                        prefixIcon: Icon(Icons.speed_rounded, size: 20),
                        suffixText: 'km',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Odometer wajib diisi';
                        }
                        final parsed = double.tryParse(
                          v.trim().replaceAll(',', '.'),
                        );
                        if (parsed == null || parsed < 0) {
                          return 'Masukkan angka km valid';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Plat Nomor'),
                    TextFormField(
                      key: const ValueKey('setup_plate_field'),
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'B 1234 XYZ',
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    return Column(
      key: const ValueKey('setup_step_2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionBanner(
          icon: Icons.history_edu_rounded,
          title: 'Riwayat Servis & Penggantian Terakhir',
          subtitle:
              'Pilih perkiraan waktu terakhir Anda mengganti/menyervis komponen berikut untuk menentukan persentase kesehatan awal.',
        ),
        const SizedBox(height: 18),

        _HistoryQuestionCard(
          title: '1. Oli Mesin & Filter Oli',
          subtitle: 'Kapan terakhir Anda mengganti oli mesin motor ini?',
          icon: Icons.water_drop_outlined,
          selectedValue: _oilHistory,
          onChanged: (v) => setState(() => _oilHistory = v),
        ),
        const SizedBox(height: 14),

        _HistoryQuestionCard(
          title: '2. CVT / Transmisi, Oli Gardan & Rantai',
          subtitle: 'Kapan terakhir servis CVT, oli gardan, atau rantai/gir?',
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
          title: '4. Busi, Filter Udara, Aki, Coolant & Kaki-kaki',
          subtitle: 'Kapan terakhir melakukan servis berkala / tune-up lengkap?',
          icon: Icons.build_circle_outlined,
          selectedValue: _generalHistory,
          onChanged: (v) => setState(() => _generalHistory = v),
        ),
      ],
    );
  }

  Widget _buildStep3PhysicalAndPreview(BuildContext context) {
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
                      'Dihitung otomatis untuk 14 komponen dari riwayat servis & kondisi fisik di bawah.',
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
              'Sesuaikan jika ada gejala yang sedang dirasakan pada motor Anda saat ini.',
        ),
        const SizedBox(height: 14),

        ...SelfInspectionEngine.questions.map((q) {
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.line)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: _saving ? null : _prevStep,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Kembali'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 4,
            child: ElevatedButton.icon(
              key: const ValueKey('setup_next_or_save_button'),
              onPressed: _saving
                  ? null
                  : (_currentStep < 2 ? _nextStep : _submitAll),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _currentStep < 2
                          ? Icons.arrow_forward_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
              label: Text(
                _currentStep == 0
                    ? 'Lanjut ke Riwayat Servis'
                    : _currentStep == 1
                    ? 'Lanjut ke Cek Fisik'
                    : 'Simpan & Lihat Kesehatan Motor',
              ),
            ),
          ),
        ],
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
