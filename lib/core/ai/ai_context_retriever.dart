import '../database/app_database.dart';
import '../engines/health_engine.dart';

/// Structured context retrieved from SQLite for the active motorcycle.
class AiMotorcycleContext {
  final Motorcycle motorcycle;
  final MotorcycleModel? motorcycleModel;
  final double latestOdometerKm;
  final double averageDailyKm;
  final Map<String, ComponentHealthResult> componentHealths;
  final List<ServiceRecord> recentServices;
  final List<SelfInspection> recentInspections;
  final List<Complaint> previousComplaints;

  const AiMotorcycleContext({
    required this.motorcycle,
    this.motorcycleModel,
    required this.latestOdometerKm,
    required this.averageDailyKm,
    required this.componentHealths,
    required this.recentServices,
    required this.recentInspections,
    required this.previousComplaints,
  });

  /// Formats the context into a concise prompt string suitable for the LLM system prompt.
  String toPromptContext({String? currentComplaintText}) {
    final buffer = StringBuffer();

    buffer.writeln('INFORMASI SEPEDA MOTOR PENGGUNA:');
    buffer.writeln('- Nama/Panggilan: ${motorcycle.nickname}');
    if (motorcycleModel != null) {
      buffer.writeln(
        '- Merek & Model: ${motorcycleModel!.brand} ${motorcycleModel!.model}',
      );
      if (motorcycleModel!.variant != null &&
          motorcycleModel!.variant!.isNotEmpty) {
        buffer.writeln(
          '- Varian: ${motorcycleModel!.variant} (${motorcycleModel!.generation ?? '-'})',
        );
      }
    }
    buffer.writeln('- Tahun Pembuatan: ${motorcycle.manufactureYear}');
    if (motorcycle.plateNumber != null &&
        motorcycle.plateNumber!.trim().isNotEmpty) {
      buffer.writeln('- Plat Nomor: ${motorcycle.plateNumber}');
    }
    buffer.writeln(
      '- Odometer Saat Ini: ${latestOdometerKm.toStringAsFixed(0)} km',
    );
    if (averageDailyKm > 0) {
      buffer.writeln(
        '- Estimasi Pemakaian: ${averageDailyKm.toStringAsFixed(1)} km/hari (${motorcycle.usageProfile})',
      );
    }

    // Component health highlights (only show warning/critical/needs attention)
    final criticalComponents = componentHealths.entries.where((e) {
      final status = e.value.status;
      return status == 'inspect' || status == 'replace';
    }).toList();

    if (criticalComponents.isNotEmpty) {
      buffer.writeln('\nSTATUS KOMPONEN YANG PERLU PERHATIAN:');
      for (final entry in criticalComponents.take(5)) {
        final score = entry.value.score != null
            ? '${entry.value.score}/100'
            : 'belum ada data';
        buffer.writeln(
          '• ${entry.key}: status ${entry.value.status.toUpperCase()} ($score) - ${entry.value.explanation}',
        );
      }
    }

    // Recent service history
    if (recentServices.isNotEmpty) {
      buffer.writeln('\nRIWAYAT SERVIS TERAKHIR:');
      for (final s in recentServices.take(3)) {
        final date = s.servicedAt.toString().substring(0, 10);
        buffer.writeln(
          '• $date (${s.odometerKm?.toStringAsFixed(0) ?? '-'} km): ${s.notes ?? 'Servis rutin'} (Biaya: Rp ${s.totalCost})',
        );
      }
    }

    // Recent inspection findings
    final problemInspections = recentInspections
        .where(
          (i) =>
              i.status == 'perlu_perhatian' ||
              i.status == 'kritis' ||
              (i.notes != null && i.notes!.isNotEmpty),
        )
        .toList();

    if (problemInspections.isNotEmpty) {
      buffer.writeln('\nTEMUAN PEMERIKSAAN MANDIRI TERAKHIR:');
      for (final insp in problemInspections.take(3)) {
        buffer.writeln(
          '• ${insp.notes ?? insp.status} (${insp.inspectedAt.toString().substring(0, 10)})',
        );
      }
    }

    // Previous complaints (check for recurring patterns)
    if (previousComplaints.isNotEmpty) {
      buffer.writeln('\nRIWAYAT KELUHAN SEBELUMNYA:');
      for (final comp in previousComplaints.take(3)) {
        buffer.writeln('• [${comp.status}] ${comp.title}: ${comp.description}');
      }

      if (currentComplaintText != null && currentComplaintText.isNotEmpty) {
        final lower = currentComplaintText.toLowerCase();
        final potentialMatches = previousComplaints.where((c) {
          final words = c.title
              .toLowerCase()
              .split(' ')
              .where((w) => w.length > 3);
          return words.any((w) => lower.contains(w));
        }).toList();

        if (potentialMatches.isNotEmpty) {
          buffer.writeln('\nCATATAN KELUHAN SERUPA:');
          for (final m in potentialMatches.take(2)) {
            buffer.writeln(
              '⚠️ Gejala memiliki kemiripan dengan keluhan lama: "${m.title}". '
              'Pertimbangkan apakah ini masalah berulang.',
            );
          }
        }
      }
    }

    return buffer.toString().trim();
  }
}

/// Retrieves motorcycle context deterministically from SQLite while enforcing multi-motor isolation.
class AiContextRetriever {
  final AppDatabase _db;

  AiContextRetriever({required AppDatabase db}) : _db = db;

  /// Fetches structured context for the given [motorcycleId].
  ///
  /// Guarantees that only data belonging to [motorcycleId] is loaded.
  Future<AiMotorcycleContext?> retrieveContext(int motorcycleId) async {
    final motor = await _db.getMotorcycle(motorcycleId);
    if (motor == null) return null;

    MotorcycleModel? model;
    if (motor.modelId != null) {
      model = await _db.getMotorcycleModelById(motor.modelId!);
    }

    // Latest odometer
    final latestOdoLog = await _db.getLatestOdometer(motorcycleId);
    final latestOdo = latestOdoLog?.odometerKm ?? 0.0;

    // Average daily km
    final odoLogs = await _db.getOdometerLogs(motorcycleId);
    double avgDaily = 20.0;
    if (odoLogs.length >= 2) {
      final sorted = List.of(odoLogs)
        ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      final days = sorted.last.recordedAt
          .difference(sorted.first.recordedAt)
          .inDays;
      final kmDiff = sorted.last.odometerKm - sorted.first.odometerKm;
      if (days > 0 && kmDiff > 0) {
        avgDaily = kmDiff / days;
      }
    }

    // Component health calculation
    final componentHealths = <String, ComponentHealthResult>{};
    try {
      final componentTypes = await _db.getAllComponentTypes();
      final services = await _db.getServiceRecords(motorcycleId);
      final rules = await _db.getAllMaintenanceRules();

      final engine = HealthEngine(
        statuses: [],
        serviceRecords: services,
        odometerLogs: odoLogs,
        rules: rules,
        componentTypes: componentTypes,
        currentOdometer: latestOdo,
        motorcycleModelId: motor.modelId,
      );

      for (final ct in componentTypes) {
        componentHealths[ct.name] = engine.calculateHealth(ct.id);
      }
    } catch (_) {
      // Graceful fallback if health cannot be computed
    }

    // Recent services (isolated by motorcycleId)
    final services = await _db.getServiceRecords(motorcycleId);
    final sortedServices = List.of(services)
      ..sort((a, b) => b.servicedAt.compareTo(a.servicedAt));

    // Recent inspections (isolated by motorcycleId)
    final inspections = await _db.getSelfInspections(motorcycleId);
    final sortedInspections = List.of(inspections)
      ..sort((a, b) => b.inspectedAt.compareTo(a.inspectedAt));

    // Previous complaints (isolated by motorcycleId)
    final complaints = await _db.getComplaints(motorcycleId);
    final sortedComplaints = List.of(complaints)
      ..sort((a, b) => b.openedAt.compareTo(a.openedAt));

    return AiMotorcycleContext(
      motorcycle: motor,
      motorcycleModel: model,
      latestOdometerKm: latestOdo,
      averageDailyKm: avgDaily,
      componentHealths: componentHealths,
      recentServices: sortedServices,
      recentInspections: sortedInspections,
      previousComplaints: sortedComplaints,
    );
  }
}
