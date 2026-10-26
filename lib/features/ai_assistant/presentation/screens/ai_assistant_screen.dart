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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(aiModelStatusProvider);
      ref.invalidate(aiModelInfoProvider);
    });
  }

  Future<void> _openModelManager() async {
    await context.push('/ai-model');
    if (mounted) {
      ref.invalidate(aiModelStatusProvider);
      ref.invalidate(aiModelInfoProvider);
    }
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
            'Halo! Saya asisten konsultasi AI BuildHaus.\n\n'
            'Ceritakan keluhan, bunyi aneh, atau gejala yang Anda rasakan pada motor. '
            'Saya akan menganalisis data riwayat motor Anda untuk memperkirakan kemungkinan penyebabnya.\n\n'
            '⚠️ PENTING: Analisis ini bersifat bantuan awal dan BUKAN diagnosis pasti mekanik. '
            'Untuk indikasi bahaya pada rem, bahan bakar, dan ban, utamakan keselamatan jiwa.',
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
    final aiStatus = ref.watch(aiModelStatusProvider);
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
          aiStatus.when(
            data: (status) => status == 'ready'
                ? GestureDetector(
                    onTap: _openModelManager,
                    child: Chip(
                      label: Text(
                        '🤖 LLM Offline',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: BuildHausTheme.ok,
                        ),
                      ),
                      backgroundColor: BuildHausTheme.okBg,
                      side: BorderSide.none,
                    ),
                  )
                : GestureDetector(
                    onTap: _openModelManager,
                    child: Chip(
                      avatar: const Icon(Icons.download, size: 12),
                      label: Text(
                        'Unduh AI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.ink,
                        ),
                      ),
                      backgroundColor: context.soft,
                      side: BorderSide(color: context.line),
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
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
          // Informative banner when AI model is not yet downloaded
          if (aiStatus.valueOrNull != 'ready')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.line),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 18,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI offline belum diunduh (Mode Analisis Dasar aktif).',
                      style: TextStyle(fontSize: 11, color: context.muted),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _openModelManager,
                    icon: const Icon(Icons.download, size: 14),
                    label: const Text(
                      'Unduh (378 MB)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
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

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surface,
              border: Border(top: BorderSide(color: context.line)),
            ),
            child: SafeArea(
              child: Column(
                children: [
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
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.send, color: context.ink),
                        style: IconButton.styleFrom(
                          backgroundColor: context.ink,
                          foregroundColor: context.bg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '100% Offline • Privasi Terjaga • Data Tersimpan di HP Anda',
                    style: TextStyle(color: context.muted, fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                    m.analysisMode == 'llm' ? 'LLM' : 'Aturan Dasar',
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
          Text(
            m.content,
            style: TextStyle(fontSize: 13, color: context.ink, height: 1.5),
          ),
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
              'BuildHaus AI Assistant bekerja secara 100% offline di smartphone Anda.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              '🔒 Privasi Mutlak: Semua percakapan dan analisis keluhan disimpan lokal di database SQLite HP Anda, tidak ada yang dikirim ke cloud.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              '📋 Analisis Dasar: Tersedia otomatis tanpa unduh model sebagai panduan awal.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              '🤖 Model Offline Qwen3: Dapat diunduh di Akun > AI Model untuk pemahaman bahasa alami yang lebih mendalam.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/ai-model');
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Kelola Model AI'),
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
