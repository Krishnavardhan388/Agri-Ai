import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/api_client.dart';
import '../domain/system_settings_model.dart';

class SystemSettingsState {
  final SystemSettings settings;
  final bool isSaving;
  final String? confirmationMessage;

  const SystemSettingsState({
    required this.settings,
    this.isSaving = false,
    this.confirmationMessage,
  });

  SystemSettingsState copyWith({
    SystemSettings? settings,
    bool? isSaving,
    String? confirmationMessage,
  }) {
    return SystemSettingsState(
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
      confirmationMessage: confirmationMessage ?? this.confirmationMessage,
    );
  }
}

class SystemSettingsNotifier extends StateNotifier<SystemSettingsState> {
  final ApiClient? apiClient;

  SystemSettingsNotifier({this.apiClient})
      : super(
          SystemSettingsState(
            settings: SystemSettings(lastConfiguredAt: DateTime.now()),
          ),
        ) {
    _loadRemoteSettings();
  }

  Future<void> _loadRemoteSettings() async {
    if (apiClient == null) return;
    try {
      final resp = await apiClient!.get('/api/v1/admin/settings');
      if (resp is Map<String, dynamic> && resp.isNotEmpty) {
        state = state.copyWith(
          settings: state.settings.copyWith(
            geminiModel: resp['gemini_model']?.toString() ?? state.settings.geminiModel,
            razorpayMode: resp['razorpay_mode']?.toString() ?? state.settings.razorpayMode,
            platformCommissionPercent: (resp['platform_commission_percent'] as num?)?.toDouble() ?? state.settings.platformCommissionPercent,
            defaultVoiceSpeechRate: (resp['default_voice_speech_rate'] as num?)?.toDouble() ?? state.settings.defaultVoiceSpeechRate,
            isAutoDispatchEnabled: resp['is_auto_dispatch_enabled'] ?? state.settings.isAutoDispatchEnabled,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _syncRemoteSettings(Map<String, dynamic> fields) async {
    if (apiClient == null) return;
    try {
      await apiClient!.put('/api/v1/admin/settings', body: fields);
    } catch (_) {}
  }

  void updateGeminiModel(String model) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        geminiModel: model,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Gemini model switched to $model.',
    );
    _syncRemoteSettings({'gemini_model': model});
  }

  void setRazorpayMode(String mode) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        razorpayMode: mode,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Razorpay payment mode set to $mode.',
    );
    _syncRemoteSettings({'razorpay_mode': mode});
  }

  void updateCommission(double percent) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        platformCommissionPercent: percent,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Platform commission adjusted to $percent%.',
    );
    _syncRemoteSettings({'platform_commission_percent': percent});
  }

  void updateSpeechRate(double rate) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        defaultVoiceSpeechRate: rate,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Voice speech rate adjusted to $rate.',
    );
    _syncRemoteSettings({'default_voice_speech_rate': rate});
  }

  void toggleAutoDispatch() {
    final nextVal = !state.settings.isAutoDispatchEnabled;
    state = state.copyWith(
      settings: state.settings.copyWith(
        isAutoDispatchEnabled: nextVal,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Auto-dispatch algorithm toggled.',
    );
    _syncRemoteSettings({'is_auto_dispatch_enabled': nextVal});
  }
}

final systemSettingsProvider = StateNotifierProvider<SystemSettingsNotifier, SystemSettingsState>((ref) {
  return SystemSettingsNotifier(apiClient: ref.watch(apiClientProvider));
});
