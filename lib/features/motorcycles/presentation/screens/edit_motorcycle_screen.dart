import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class EditMotorcycleScreen extends ConsumerStatefulWidget {
  final int id;
  const EditMotorcycleScreen({super.key, required this.id});

  @override
  ConsumerState<EditMotorcycleScreen> createState() => _EditMotorcycleScreenState();
}

class _EditMotorcycleScreenState extends ConsumerState<EditMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _plateController = TextEditingController();
  final _emojiController = TextEditingController(text: '🏍️');
  final _odometerController = TextEditingController();

  String _selectedUsage = 'campuran';
  bool _saving = false;
  bool _loaded = false;
  Motorcycle? _motor;

  final _usageProfiles = ['harian_dalam_kota', 'jarak_jauh', 'campuran'];
  final _usageLabels = {'harian_dalam_kota': 'Harian dalam kota', 'jarak_jauh': 'Jarak jauh', 'campuran': 'Campuran'};

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    _emojiController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loaded) return;
    final db = ref.read(databaseProvider);
    final m = await db.getMotorcycle(widget.id);
    if (m != null && mounted) {
      setState(() {
        _motor = m;
        _nicknameController.text = m.nickname;
        _plateController.text = m.plateNumber ?? '';
        _emojiController.text = m.emoji;
        _selectedUsage = m.usageProfile;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();

    if (!_loaded || _motor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Motor')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Edit Motor'),
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
              Text('Edit Profil Motor', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Data ini menentukan rekomendasi sparepart.', style: TextStyle(color: context.muted, fontSize: 12)),
              const SizedBox(height: 24),

              _buildLabel('Emoji'),
              TextFormField(
                controller: _emojiController,
                decoration: const InputDecoration(hintText: 'Contoh: 🏍️'),
                maxLength: 2,
                style: const TextStyle(fontSize: 20),
              ),

              _buildLabel('Nama / Nickname'),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(hintText: 'Nama panggilan motor'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),

              _buildLabel('Plat nomor (opsional)'),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(hintText: 'Contoh: B 1234 XYZ'),
              ),

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

              const SizedBox(height: 16),

              // Odometer quick update
              _buildLabel('Update Odometer (km)'),
              TextFormField(
                controller: _odometerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Masukkan kilometer saat ini'),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final n = double.tryParse(v);
                    if (n == null || n < 0) return 'Masukkan angka valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Simpan Perubahan'),
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
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.ink)),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);

      await db.updateMotorcycle(MotorcyclesCompanion(
        nickname: Value(_nicknameController.text.trim()),
        plateNumber: Value(_plateController.text.trim().isEmpty ? null : _plateController.text.trim()),
        emoji: Value(_emojiController.text.isEmpty ? '🏍️' : _emojiController.text),
        usageProfile: Value(_selectedUsage),
        updatedAt: Value(DateTime.now()),
      ), widget.id);

      // Insert new odometer if provided
      final odoText = _odometerController.text.trim();
      if (odoText.isNotEmpty) {
        final odoVal = double.tryParse(odoText);
        if (odoVal != null && odoVal >= 0) {
          final latest = await db.getLatestOdometer(widget.id);
          if (latest == null || odoVal > latest.odometerKm) {
            await db.insertOdometerLog(OdometerLogsCompanion(
              motorcycleId: Value(widget.id),
              odometerKm: Value(odoVal),
              recordedAt: Value(DateTime.now()),
              source: const Value('manual'),
            ));
          }
        }
      }

      ref.invalidate(motorcyclesProvider);
      await ref.read(activeMotorcycleProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan disimpan!')),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Motor?'),
        content: const Text('Semua data motor ini akan dihapus permanen. Pastikan kamu sudah backup.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: BuildHausTheme.danger)),
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
      if (mounted) {
        context.go('/home');
      }
    }
  }
}
