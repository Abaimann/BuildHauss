import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class AddMotorcycleScreen extends ConsumerStatefulWidget {
  const AddMotorcycleScreen({super.key});

  @override
  ConsumerState<AddMotorcycleScreen> createState() => _AddMotorcycleScreenState();
}

class _AddMotorcycleScreenState extends ConsumerState<AddMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _plateController = TextEditingController();
  final _emojiController = TextEditingController(text: '🏍️');
  final _odometerController = TextEditingController();

  String _selectedBrand = 'Honda';
  String _selectedModel = 'Vario 160';
  int _selectedYear = DateTime.now().year;
  String _selectedUsage = 'campuran';
  bool _saving = false;

  final _brands = ['Honda', 'Yamaha', 'Suzuki', 'Kawasaki'];
  final _years = List.generate(15, (i) => DateTime.now().year - i);
  final _usageProfiles = ['harian_dalam_kota', 'jarak_jauh', 'campuran'];
  final _usageLabels = {'harian_dalam_kota': 'Harian dalam kota', 'jarak_jauh': 'Jarak jauh', 'campuran': 'Campuran'};

  final _modelByBrand = {
    'Honda': ['Vario 160', 'Vario 125', 'Beat Street', 'Supra X 125 FI', 'PCX 160', 'ADV 160', 'CBR150R'],
    'Yamaha': ['NMAX', 'Aerox', 'Mio M3', 'FreeGo', 'X-Ride'],
    'Suzuki': ['Address 110', 'Nex II', 'Smash FI'],
    'Kawasaki': ['Ninja 250SL', 'W175', 'Z125'],
  };

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _emojiController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Tambah Motor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Motor baru', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Catat motor lain yang kamu punya.', style: TextStyle(color: context.muted, fontSize: 12)),
              const SizedBox(height: 24),

              // Emoji
              _buildLabel('Emoji'),
              TextFormField(
                controller: _emojiController,
                decoration: const InputDecoration(hintText: 'Contoh: 🏍️'),
                maxLength: 2,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),

              // Nickname
              _buildLabel('Nama / Plat nomor'),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(hintText: 'Contoh: Honda Beat B 1234 XYZ'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 8),

              // Brand
              _buildLabel('Merek'),
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                decoration: const InputDecoration(),
                items: _brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() { _selectedBrand = v!; _selectedModel = _modelByBrand[v]!.first; }),
              ),
              const SizedBox(height: 8),

              // Model
              _buildLabel('Model'),
              DropdownButtonFormField<String>(
                value: _selectedModel,
                decoration: const InputDecoration(),
                items: _modelByBrand[_selectedBrand]!.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _selectedModel = v!),
              ),
              const SizedBox(height: 8),

              // Year
              _buildLabel('Tahun'),
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(),
                items: _years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                onChanged: (v) => setState(() => _selectedYear = v!),
              ),
              const SizedBox(height: 8),

              // Plate
              _buildLabel('Plat nomor (opsional)'),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(hintText: 'Contoh: B 1234 XYZ'),
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
                    if (n == null || n < 0) return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Usage
              _buildLabel('Jenis pemakaian'),
              DropdownButtonFormField<String>(
                value: _selectedUsage,
                decoration: const InputDecoration(),
                items: _usageProfiles.map((u) => DropdownMenuItem(
                  value: u,
                  child: Text(_usageLabels[u]!),
                )).toList(),
                onChanged: (v) => setState(() => _selectedUsage = v!),
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
                        'Motor pertama yang ditambahkan otomatis menjadi motor utama.',
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
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Simpan Motor'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.ink)),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);

      // Check if this is the first motor
      final existing = await db.getAllMotorcycles();
      final isFirst = existing.isEmpty;

      // Insert motorcycle
      final motorId = await db.insertMotorcycle(MotorcyclesCompanion(
        nickname: Value(_nicknameController.text.trim().isEmpty
          ? '$_selectedBrand $_selectedModel'
          : _nicknameController.text.trim()),
        manufactureYear: Value(_selectedYear),
        plateNumber: Value(_plateController.text.trim().isEmpty ? null : _plateController.text.trim()),
        emoji: Value(_emojiController.text.isEmpty ? '🏍️' : _emojiController.text),
        usageProfile: Value(_selectedUsage),
        isPrimary: Value(isFirst),
      ));

      // Insert initial odometer if provided
      final odoText = _odometerController.text.trim();
      if (odoText.isNotEmpty) {
        final odoVal = double.tryParse(odoText);
        if (odoVal != null && odoVal >= 0) {
          await db.insertOdometerLog(OdometerLogsCompanion(
            motorcycleId: Value(motorId),
            odometerKm: Value(odoVal),
            recordedAt: Value(DateTime.now()),
            source: const Value('manual'),
          ));
        }
      }

      // Set as primary if first
      if (isFirst) {
        await db.setPrimaryMotorcycle(motorId);
      }

      // Refresh providers
      ref.invalidate(motorcyclesProvider);
      ref.invalidate(activeMotorcycleProvider);
      final newMotor = await db.getMotorcycle(motorId);
      if (newMotor != null) {
        await ref.read(activeMotorcycleProvider.notifier).setActiveMotorcycle(newMotor);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isFirst ? 'Motor berhasil ditambahkan!' : 'Motor berhasil ditambahkan!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
