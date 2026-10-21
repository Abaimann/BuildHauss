import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class ComplaintDetailScreen extends ConsumerStatefulWidget {
  final int complaintId;
  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  ConsumerState<ComplaintDetailScreen> createState() =>
      _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends ConsumerState<ComplaintDetailScreen> {
  Complaint? _complaint;
  List<ComplaintMessage> _messages = [];
  final _chatController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final complaint = await db.getComplaint(widget.complaintId);
    final messages = await db.getComplaintMessages(widget.complaintId);
    if (mounted) {
      setState(() {
        _complaint = complaint;
        _messages = messages;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Keluhan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Keluhan')),
        body: const Center(child: Text('Keluhan tidak ditemukan')),
      );
    }

    final c = _complaint!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(c.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => _handleAction(v),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'close', child: Text('Tutup Keluhan')),
              const PopupMenuItem(value: 'reopen', child: Text('Buka Kembali')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Complaint info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                c.status,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              _getStatusLabel(c.status),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(c.status),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            Formatters.date(c.openedAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: context.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        c.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.ink,
                          height: 1.5,
                        ),
                      ),
                      if (c.odometerKm != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Odometer saat itu: ${c.odometerKm!.toStringAsFixed(0)} km',
                          style: TextStyle(fontSize: 11, color: context.muted),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Messages / Chat
                Text(
                  'Percakapan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),

                if (_messages.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.soft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '💬',
                          style: TextStyle(fontSize: 28, color: context.muted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada analisis. Tanyakan keluhan kamu di bawah.',
                          style: TextStyle(color: context.muted, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...(_messages.map((m) => _buildMessageBubble(m))),

                const SizedBox(height: 16),

                // AI analysis if available
                _buildAnalysisSection(context),
              ],
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surface,
              border: Border(top: BorderSide(color: context.line)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        hintText: 'Tanyakan keluhan ini...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _sendMessage(),
                    icon: Icon(Icons.send, color: context.ink),
                    style: IconButton.styleFrom(
                      backgroundColor: context.ink,
                      foregroundColor: context.bg,
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

  Widget _buildMessageBubble(ComplaintMessage m) {
    final isUser = m.role == 'user';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? context.surface2 : context.soft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUser ? context.line : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isUser ? 'Anda' : 'BuildHaus',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: context.muted,
                ),
              ),
              const Spacer(),
              Text(
                Formatters.dateTime(m.createdAt),
                style: TextStyle(fontSize: 9, color: context.muted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            m.content,
            style: TextStyle(fontSize: 12, color: context.ink, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(BuildContext context) {
    final db = ref.read(databaseProvider);
    return FutureBuilder(
      future: db.getLatestAnalysis(widget.complaintId),
      builder: (context, snap) {
        final analysis = snap.data;
        if (analysis == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analisis', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRiskColor(
                            analysis.riskLevel,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'RISIKO: ${analysis.riskLevel.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _getRiskColor(analysis.riskLevel),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Mode: ${analysis.analysisMode}',
                        style: TextStyle(fontSize: 9, color: context.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    analysis.summary,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.ink,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.dateTime(analysis.analyzedAt),
                    style: TextStyle(fontSize: 10, color: context.muted),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'high':
        return BuildHausTheme.danger;
      case 'medium':
        return BuildHausTheme.warn;
      default:
        return BuildHausTheme.ok;
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _complaint == null) return;

    _chatController.clear();
    final chatService = ref.read(aiChatServiceProvider);

    try {
      final tokenStream = chatService.sendMessage(
        motorcycleId: _complaint!.motorcycleId,
        complaintId: widget.complaintId,
        userText: text,
        onAnalysisComplete: (_) async {
          await _load();
        },
      );
      await tokenStream.drain();
      await _load();
    } catch (_) {
      await _load();
    }
  }

  Future<void> _handleAction(String action) async {
    final db = ref.read(databaseProvider);
    if (action == 'close') {
      await db.updateComplaint(
        ComplaintsCompanion(
          status: const Value('selesai'),
          closedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
        widget.complaintId,
      );
    } else if (action == 'reopen') {
      await db.updateComplaint(
        ComplaintsCompanion(
          status: const Value('dibuka_kembali'),
          closedAt: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
        widget.complaintId,
      );
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Keluhan?'),
          content: const Text('Keluhan ini akan dihapus permanen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Hapus',
                style: TextStyle(color: BuildHausTheme.danger),
              ),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await db.deleteComplaint(widget.complaintId);
        if (mounted) context.pop();
      }
      return;
    }
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status keluhan diperbarui')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.trim()) {
      case 'selesai':
        return BuildHausTheme.ok;
      case 'ditangani':
        return BuildHausTheme.ok;
      case 'perlu_pemeriksaan':
        return BuildHausTheme.warn;
      case 'dianalisis':
        return BuildHausTheme.warn;
      case 'dibuka_kembali':
        return BuildHausTheme.danger;
      default:
        return context.muted;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.trim()) {
      case ' baru':
        return 'BARU';
      case 'dianalisis':
        return 'DIANALISIS';
      case 'perlu_pemeriksaan':
        return 'PERLU CEK';
      case 'ditangani':
        return 'DITANGANI';
      case 'selesai':
        return 'SELESAI';
      case 'dibuka_kembali':
        return 'DIBUKA LG';
      default:
        return status.toUpperCase();
    }
  }
}
