import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _addSystemMessage();
  }

  void _addSystemMessage() {
    _messages.add(
      _ChatMessage(
        role: 'system',
        content:
            'Halo! Saya asisten AI BuildHaus. '
            'Ceritakan keluhan atau pertanyaan tentang motor kamu. '
            'Saya akan membantu menganalisis berdasarkan data yang ada.\n\n'
            '⚠️ Ingat: analisis ini bersifat bantuan, bukan diagnosis pasti. '
            'Untuk masalah keselamatan, segera periksakan ke mekanik profesional.',
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI Health Assistant'),
        actions: [
          aiStatus.when(
            data: (status) => status == 'ready'
                ? Chip(
                    label: Text(
                      '🤖 LLM',
                      style: TextStyle(fontSize: 10, color: BuildHausTheme.ok),
                    ),
                    backgroundColor: BuildHausTheme.okBg,
                    side: BorderSide.none,
                  )
                : Chip(
                    label: Text(
                      '📋 Rule-based',
                      style: TextStyle(fontSize: 10, color: context.muted),
                    ),
                    backgroundColor: context.soft,
                    side: BorderSide.none,
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
                            hintText: 'Tanyakan tentang keluhan motor...',
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
                    'Analisis tanpa AI online. Model lokal diperlukan untuk analisis lanjutan.',
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUser ? context.surface2 : context.soft,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
          bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
        ),
        border: Border.all(color: isUser ? context.line : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isUser ? 'Anda' : 'BuildHaus AI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: context.muted,
                ),
              ),
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

    _messageController.clear();
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _sending = true;
    });

    _scrollToBottom();

    // Simulate AI response (rule-based analysis)
    await Future.delayed(const Duration(milliseconds: 800));

    final response = _generateRuleBasedResponse(text);

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', content: response));
        _sending = false;
      });
      _scrollToBottom();
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

  String _generateRuleBasedResponse(String input) {
    final lower = input.toLowerCase();

    // Safety keywords
    if (lower.contains('rem tidak') ||
        lower.contains('rem blong') ||
        lower.contains('ban pecah') ||
        lower.contains('bahan bakar bocor')) {
      return '⚠️ PERHATIAN: Keluhan yang Anda sebutkan menyangkut keselamatan.\n\n'
          '🚨 JANGAN menggunakan motor dalam kondisi rem tidak berfungsi, ban bermasalah, '
          'atau ada kebocoran bahan bakar.\n\n'
          '✅ Segera bawa ke mekanik profesional untuk diperiksa. '
          'Ini bukan sesuatu yang bisa ditunda.';
    }

    // Oil related
    if (lower.contains('oli') ||
        lower.contains('mesin') && lower.contains('panas')) {
      return '🛢️ Mengenai oli mesin:\n\n'
          '• Periksa level oli dengan dipstick saat mesin dingin dan datar\n'
          '• Oli yang tepat untuk motor kamu bisa dilihat di menu Sparepart\n'
          '• Ganti oli sesuai interval yang direkomendasikan buku manual\n'
          '• Jika oli terasa sangat gelap/hitam早点, sebaiknya segera diganti\n\n'
          '💡 Tips: Catat penggantian oli di menu Riwayat Servis.';
    }

    // Starter issues
    if (lower.contains('starter') ||
        lower.contains('suara klik') ||
        lower.contains('tidak mau')) {
      return '🔋 Kemungkinan masalah starter:\n\n'
          '1. **Aki lemah** - Coba nyalakan lampu, jika redup kemungkinan aki lemah\n'
          '2. **Kontak kotor** - Periksa terminal aki, bersihkan jika berkarat\n'
          '3. **Starter motor** - Jika berbunyi klik tapi mesin tidak jalan,可能是starter bermasalah\n\n'
          '📏 Untuk diagnosis lebih akurat, coba catat:\n'
          '- Kapan masalah terjadi? (pagi/siang/malam)\n'
          '- Sudah berapa lama?\n'
          '- Apakah terjadi tiba-tiba atau gradually?';
    }

    // Brake related
    if (lower.contains('rem') || lower.contains('pengereman')) {
      return '🛑 Mengenai rem:\n\n'
          '• Rem adalah komponen KESELAMATAN paling utama\n'
          '• Jika rem terasa lembut/lemah, segera periksakan\n'
          '• Suara gesekan/berisik bisa menandakan kampas aus\n'
          '• Rem depan biasanya aus lebih cepat dari rem belakang\n\n'
          '⚠️ Jangan tunda perbaikan rem jika Anda merasakan:\n'
          '- Rem butuh tekanan lebih dalam\n'
          '- Rem berbunyi lebih keras dari biasanya\n'
          '- Motor menarik ke satu sisi saat direm';
    }

    // CVT related
    if (lower.contains('cvt') ||
        lower.contains('mati') && lower.contains('jalan')) {
      return '⚙️ Mengenai CVT (transmisi otomatis):\n\n'
          '• Gejala CVT bermasalah: motor mati saat jalan, tarikan tidak smooth\n'
          '• Periksa belt CVT apakah pecah atau aus\n'
          '• Roller CVT perlu diganti secara berkala\n'
          '• Jangan menggunakan oli mesin biasa untuk CVT\n\n'
          '📋 Servis CVT sebaiknya dilakukan oleh mekanik yang berpengalaman.';
    }

    // General response
    return 'Terima kasih sudah bertanya. 📝\n\n'
        'Berdasarkan keluhan Anda, saya sudah mencatat informasi ini.\n\n'
        '💡 **Saran umum:**\n'
        '- Selalu catat kapan masalah mulai terjadi\n'
        '- Perhatikan apakah masalahnya konsisten atau hilang-timbul\n'
        '- Bawa ke mekanik jika ragu\n\n'
        '🤖 *Untuk analisis lebih detail dengan AI lokal, pastikan model AI sudah diunduh '
        'di menu Akun > AI Model.*\n\n'
        'Apakah ada detail lain tentang keluhan motor Anda?';
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
              'BuildHaus AI Assistant bekerja secara offline di HP Anda.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              '🔒 Privasi: Semua data keluhan dan analisis TIDAK dikirim ke server manapun.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              '📋 Analisis dasar (rule-based) tersedia tanpa model AI.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              '🤖 Untuk analisis LLM yang lebih canggih, unduh model AI di menu Akun > AI Model.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  _ChatMessage({required this.role, required this.content})
    : timestamp = DateTime.now();
}
