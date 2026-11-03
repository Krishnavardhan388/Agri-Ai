import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/voice_language.dart';
import '../state/voice_assistant_provider.dart';

class AgriMitraVoiceScreen extends ConsumerStatefulWidget {
  const AgriMitraVoiceScreen({super.key});

  @override
  ConsumerState<AgriMitraVoiceScreen> createState() => _AgriMitraVoiceScreenState();
}

class _AgriMitraVoiceScreenState extends ConsumerState<AgriMitraVoiceScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceAssistantProvider);
    final notifier = ref.read(voiceAssistantProvider.notifier);

    ref.listen(voiceAssistantProvider, (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.greenSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.record_voice_over_rounded,
                  color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AGRI MITRA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  state.currentLanguage.nativeName,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (state.isSpeaking)
            IconButton(
              icon: const Icon(Icons.volume_off_rounded, color: AppColors.alertRed),
              tooltip: 'Stop Audio',
              onPressed: () => notifier.stopSpeaking(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Language Selection Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Language: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: VoiceLanguage.values.map((lang) {
                        final isSelected = lang == state.currentLanguage;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              '${lang.nativeName} (${lang.displayName})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryGreen,
                            backgroundColor: AppColors.surfaceVariant,
                            onSelected: (selected) {
                              if (selected) {
                                notifier.setLanguage(lang);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message Transcript List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (ctx, index) {
                final msg = state.messages[index];
                final isPlayingThis = state.isSpeaking && state.activePlayingMessageId == msg.id;
                return _buildMessageBubble(msg, isPlayingThis, notifier);
              },
            ),
          ),

          // Quick Suggested Query Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _getSuggestedQueries(state.currentLanguage).map((query) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.primaryGreen, width: 0.8),
                      avatar: const Icon(Icons.help_outline_rounded,
                          size: 14, color: AppColors.primaryGreen),
                      label: Text(
                        query,
                        style: const TextStyle(fontSize: 11, color: AppColors.primaryDark),
                      ),
                      onPressed: () => notifier.sendQuery(query),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Live Listening Status Banner
          if (state.isListening || state.isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.greenSurface,
              child: Row(
                children: [
                  FadeTransition(
                    opacity: _pulseController,
                    child: const Icon(Icons.mic_rounded, color: AppColors.alertRed, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.isListening
                          ? (state.recognizedWords.isEmpty
                              ? 'Listening... Speak in ${state.currentLanguage.nativeName}'
                              : state.recognizedWords)
                          : 'AGRI MITRA is thinking...',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  if (state.isListening)
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primaryGreen),
                      onPressed: () => notifier.toggleListening(),
                    ),
                ],
              ),
            ),

          // Bottom Voice & Text Input Control Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text Field for typing
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask AGRI MITRA or tap mic...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        notifier.sendQuery(text);
                        _textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // Pulsing Center Microphone Button
                GestureDetector(
                  onTap: () => notifier.toggleListening(),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (ctx, child) {
                      final scale = state.isListening ? 1.0 + (_pulseController.value * 0.15) : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.isListening ? AppColors.alertRed : AppColors.primaryGreen,
                            boxShadow: [
                              BoxShadow(
                                color: (state.isListening
                                        ? AppColors.alertRed
                                        : AppColors.primaryGreen)
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: state.isListening ? 4 : 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            state.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    VoiceMessage msg,
    bool isPlayingThis,
    VoiceAssistantNotifier notifier,
  ) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 36),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: isPlayingThis ? AppColors.primaryGreen : AppColors.border,
            width: isPlayingThis ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.spa_rounded, color: AppColors.primaryGreen, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'AGRI MITRA (${msg.language.nativeName})',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isPlayingThis ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                    color: isPlayingThis ? AppColors.alertRed : AppColors.primaryGreen,
                    size: 20,
                  ),
                  tooltip: isPlayingThis ? 'Stop' : 'Read Aloud',
                  onPressed: () => notifier.speakMessage(msg.text, messageId: msg.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg.text,
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getSuggestedQueries(VoiceLanguage lang) {
    switch (lang) {
      case VoiceLanguage.telugu:
        return [
          'టొమాటో ఆకు ముడుత తెగులు నివారణ?',
          'పత్తిలో గులాబీ రంగు పురుగు మందు?',
          'వరిలో అగ్గి తెగులు మందు?',
          'నేటి పత్తి మార్కెట్ ధర ఎంత?',
          'యూరియా ఎరువును ఎప్పుడు వేయాలి?',
        ];
      case VoiceLanguage.hindi:
        return [
          'टमाटर में पत्ती मरोड़ रोग का उपचार?',
          'कपास में गुलाबी सुंडी नियंत्रण?',
          'धान में ब्लास्ट रोग की दवा?',
          'आज का कपास मंडी भाव क्या है?',
          'यूरिया खाद देने का सही समय?',
        ];
      case VoiceLanguage.english:
        return [
          'How to treat tomato leaf curl virus?',
          'Cotton pink bollworm pest control?',
          'Medicine for paddy blast disease?',
          'What is today\'s cotton mandi rate?',
          'Optimal timing for Urea fertilizer?',
        ];
    }
  }
}

