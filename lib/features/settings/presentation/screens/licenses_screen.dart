import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lisensi & Sumber')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // BuildHaus Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: Colors.teal,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'BuildHaus v1.0.0',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Aplikasi offline-first pendamping perawatan sepeda motor pribadi. Seluruh data pengguna disimpan di database lokal SQLite perangkat.',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Sumber Katalog & Data Referensi',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          _LicenseCard(
            title: 'Katalog Suku Cadang Resmi Astra Honda Motor (AHM)',
            license: 'Data Referensi Kompatibilitas Publik',
            description:
                'Data suku cadang resmi, nomor part, dan harga eceran tertinggi acuan Astra Honda Motor untuk model Honda Vario, Beat, PCX, dll.',
          ),
          const SizedBox(height: 8),
          _LicenseCard(
            title: 'Katalog Suku Cadang Yamaha Genuine Parts (YGP)',
            license: 'Data Referensi Kompatibilitas Publik',
            description:
                'Data suku cadang resmi Yamaha Indonesia Motor Manufacturing untuk model Yamaha NMAX, Aerox, Mio, dll.',
          ),
          const SizedBox(height: 20),

          Text(
            'Model Bahasa & Komputasi On-Device',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          _LicenseCard(
            title: 'Qwen3 0.6B GGUF (Unsloth / Alibaba Qwen)',
            license: 'Apache License 2.0',
            description:
                'Model AI bahasa ringan on-device yang dikuantisasi ke format GGUF untuk konsultasi keluhan sepeda motor secara offline.',
          ),
          const SizedBox(height: 8),
          _LicenseCard(
            title: 'llama.cpp (Georgi Gerganov & Contributors)',
            license: 'MIT License',
            description:
                'Engine komputasi inferensi C++ native dengan akselerasi hardware ARM NEON dan Vulkan di Android.',
          ),
          const SizedBox(height: 20),

          Text(
            'Pustaka Utama (Open Source)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          _LicenseCard(
            title: 'Drift & SQLite (Simon Binder)',
            license: 'MIT License',
            description:
                'Database engine relasional lokal offline-first berkemampuan migrasi skema dan reaktif.',
          ),
          const SizedBox(height: 8),
          _LicenseCard(
            title: 'Flutter & Dart (Google LLC)',
            license: 'BSD 3-Clause License',
            description:
                'Framework UI multiplatform performa tinggi dengan Impeller rendering engine.',
          ),
          const SizedBox(height: 8),
          _LicenseCard(
            title: 'Flutter Riverpod (Remi Rousselet)',
            license: 'MIT License',
            description:
                'Manajemen state reaktif deklaratif dengan pemisahan dependensi bersih.',
          ),
          const SizedBox(height: 8),
          _LicenseCard(
            title: 'GoRouter (Flutter Team)',
            license: 'BSD 3-Clause License',
            description: 'Sistem perutean dan navigasi deklaratif.',
          ),
          const SizedBox(height: 8),
          _LicenseCard(
            title: 'flutter_local_notifications (Michael Bui)',
            license: 'BSD 3-Clause License',
            description:
                'Pustaka penjadwalan dan penampilan notifikasi lokal Android.',
          ),
          const SizedBox(height: 20),

          Center(
            child: TextButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'BuildHaus',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    '© 2026 BuildHaus Team. Hak Cipta Dilindungi.',
              ),
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Lihat Seluruh Lisensi Detail Package'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _LicenseCard extends StatelessWidget {
  final String title;
  final String license;
  final String description;

  const _LicenseCard({
    required this.title,
    required this.license,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  license,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 11, color: context.muted, height: 1.35),
          ),
        ],
      ),
    );
  }
}
