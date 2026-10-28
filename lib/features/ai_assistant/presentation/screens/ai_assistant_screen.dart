import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ai/ai_safety_guard.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  final int? complaintId;

  const AiAssistantScreen({super.key, this.complaintId});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;
  int? _activeComplaintId;
  SafetyEvaluationResult? _lastSafetyAlert;

  @override
  void initState() {
    super.initState();
    _activeComplaintId = widget.complaintId;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final db = ref.read(databaseProvider);

    if (_activeComplaintId != null && _activeComplaintId! > 0) {
      // Load existing messages from SQLite
      final existing = await db.getComplaintMessages(_activeComplaintId!);
      if (existing.isNotEmpty) {
        setState(() {
          _messages.clear();
          for (final m in existing) {
            _messages.add(
              _ChatMessage(
                role: m.role,
                content: m.content,
                timestamp: m.createdAt,
                analysisMode: m.analysisMode,
              ),
            );
          }
        });
        _scrollToBottom();
        return;
      }
    }

    _addSystemMessage();
  }

  void _addSystemMessage() {
    _messages.add(
      _ChatMessage(
        role: 'system',
        content:
            'Halo bro! Ada yang kerasa aneh sama motor kamu? 🏍️\n\n'
            'Ceritain aja gejalanya (misal bunyi kasar, tarikan loyo, gredek CVT, dll). Gue bantu tebak kemungkinan masalahnya secara cepat & simpel!',
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMotor = ref.watch(activeMotorcycleProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Health Assistant', style: TextStyle(fontSize: 16)),
            if (activeMotor != null)
              Text(
                activeMotor.nickname,
                style: TextStyle(fontSize: 11, color: context.muted),
              ),
          ],
        ),
        actions: [
          Chip(
            label: Text(
              '✨ Gemini 2.5 Flash',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: BuildHausTheme.ok,
              ),
            ),
            backgroundColor: BuildHausTheme.okBg,
            side: BorderSide.none,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () => _showAiInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Safety alert banner if critical red flag detected
          if (_lastSafetyAlert != null && _lastSafetyAlert!.hasRedFlag)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BuildHausTheme.dangerBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BuildHausTheme.danger.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lastSafetyAlert!.warningTitle ??
                              'Peringatan Keselamatan',
                          style: TextStyle(
                            color: BuildHausTheme.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _lastSafetyAlert!.warningMessage ?? '',
                          style: TextStyle(
                            color: BuildHausTheme.danger,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildMessage(_messages[i]),
            ),
          ),

          // Input area with Quick Prompt Chips
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: context.surface,
              border: Border(top: BorderSide(color: context.line)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        _buildQuickPromptChip(
                          label: '🛵 Tarikan awal gredek',
                          prompt: 'Bro, tarikan awal motor gue terasa gredek nih',
                        ),
                        const SizedBox(width: 6),
                        _buildQuickPromptChip(
                          label: '🛢️ Cek jadwal oli',
                          prompt: 'Kapan jadwal ganti oli mesin motor gue bro?',
                        ),
                        const SizedBox(width: 6),
                        _buildQuickPromptChip(
                          label: '🛑 Rem bunyi berdecit',
                          prompt: 'Rem motor gue bunyi berdecit pas direm bro',
                        ),
                        const SizedBox(width: 6),
                        _buildQuickPromptChip(
                          label: '🔋 Starter agak berat',
                          prompt: 'Starter elektrik motor gue agak berat nyalanya',
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Tanyakan keluhan motor...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sending ? null : _send,
                        icon: _sending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.bg,
                                ),
                              )
                            : Icon(Icons.send, color: context.bg),
                        style: IconButton.styleFrom(
                          backgroundColor: context.ink,
                          foregroundColor: context.bg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Powered by Gemini 2.5 Flash • Online Cloud AI • Hemat Memori (0 MB)',
                      style: TextStyle(color: context.muted, fontSize: 9),
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

  Widget _buildQuickPromptChip({
    required String label,
    required String prompt,
  }) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: context.ink,
        ),
      ),
      backgroundColor: context.surface2,
      side: BorderSide(color: context.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      visualDensity: VisualDensity.compact,
      onPressed: _sending
          ? null
          : () {
              _messageController.text = prompt;
              _send();
            },
    );
  }

  Widget _buildFormattedText(String rawText) {
    final cleaned = rawText.replaceAll(RegExp(r'^#{1,3}\s+', multiLine: true), '');
    final spans = <TextSpan>[];
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in boldRegex.allMatches(cleaned)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: cleaned.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < cleaned.length) {
      spans.add(TextSpan(text: cleaned.substring(lastEnd)));
    }

    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 13, color: context.ink, height: 1.5),
        children: spans.isEmpty ? [TextSpan(text: cleaned)] : spans,
      ),
    );
  }

  Widget _buildMessage(_ChatMessage m) {
    final isUser = m.role == 'user';
    final isSystem = m.role == 'system';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUser
            ? context.surface2
            : isSystem
            ? context.soft.withValues(alpha: 0.5)
            : context.soft,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isUser
              ? const Radius.circular(16)
              : const Radius.circular(4),
          bottomRight: isUser
              ? const Radius.circular(4)
              : const Radius.circular(16),
        ),
        border: Border.all(
          color: isUser
              ? context.line
              : isSystem
              ? context.line.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isUser
                    ? 'Anda'
                    : isSystem
                    ? 'Sistem BuildHaus'
                    : 'BuildHaus AI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isUser ? context.ink : BuildHausTheme.ok,
                ),
              ),
              if (m.analysisMode != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: m.analysisMode == 'llm'
                        ? BuildHausTheme.okBg
                        : context.surface2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    m.analysisMode == 'llm' ? 'Gemini 2.5 Flash' : 'Aturan Dasar',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: m.analysisMode == 'llm'
                          ? BuildHausTheme.ok
                          : context.muted,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                Formatters.shortDate(m.timestamp),
                style: TextStyle(fontSize: 9, color: context.muted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildFormattedText(m.content),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    final activeMotor = ref.read(activeMotorcycleProvider);
    if (activeMotor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih atau tambahkan sepeda motor terlebih dahulu.'),
        ),
      );
      return;
    }

    _messageController.clear();

    // Check safety immediately for UI alert
    final immediateSafety = AiSafetyGuard.evaluate(text);
    if (immediateSafety.hasRedFlag) {
      setState(() => _lastSafetyAlert = immediateSafety);
    }

    // Add user message
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _sending = true;
    });
    _scrollToBottom();

    // Placeholder for streaming assistant response
    final assistantMsg = _ChatMessage(
      role: 'assistant',
      content: '',
      analysisMode: '...',
    );
    setState(() {
      _messages.add(assistantMsg);
    });

    final chatService = ref.read(aiChatServiceProvider);

    try {
      final tokenStream = chatService.sendMessage(
        motorcycleId: activeMotor.id,
        complaintId: _activeComplaintId,
        userText: text,
        onAnalysisComplete: (analysis) {
          if (mounted) {
            setState(() {
              assistantMsg.analysisMode = analysis.mode;
            });
          }
        },
      );

      final fullBuffer = StringBuffer();
      await for (final token in tokenStream) {
        fullBuffer.write(token);
        if (mounted) {
          setState(() {
            assistantMsg.content = fullBuffer.toString();
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          assistantMsg.content =
              'Maaf, terjadi kesalahan saat memproses respons: $e';
        });
      }
    } finally {
      ref.invalidate(complaintsProvider(activeMotor.id));
      ref.invalidate(componentStatusesProvider(activeMotor.id));
      ref.invalidate(componentStatusesWithNamesProvider(activeMotor.id));
      ref.invalidate(budgetPlanSummaryProvider);
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAiInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang AI Assistant'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BuildHaus AI Assistant menggunakan Google Gemini 2.5 Flash (Cloud API) secara online sehingga tidak perlu mengunduh file model besar (0 MB penyimpanan) dan hemat RAM.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              '🔒 Data Tersimpan Lokal: Riwayat motor, servis, dan percakapan tetap tersimpan aman di database SQLite perangkat Anda.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              '📋 Analisis Dasar: Tersedia otomatis sebagai fallback ketika perangkat tidak terhubung ke internet atau API Key belum diatur.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              '✨ Google Gemini 2.5 Flash: Sudah tertanam dan aktif otomatis sejak awal untuk analisis cepat dan kontekstual.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  String content;
  final DateTime timestamp;
  String? analysisMode;

  _ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.analysisMode,
  }) : timestamp = timestamp ?? DateTime.now();
}
