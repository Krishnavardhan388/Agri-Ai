import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  SystemSettingsNotifier()
      : super(
          SystemSettingsState(
            settings: SystemSettings(lastConfiguredAt: DateTime.now()),
          ),
        );

  void updateGeminiModel(String model) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        geminiModel: model,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Gemini model switched to $model.',
    );
  }

  void setRazorpayMode(String mode) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        razorpayMode: mode,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Razorpay payment mode set to $mode.',
    );
  }

  void updateCommission(double percent) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        platformCommissionPercent: percent,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Platform commission adjusted to $percent%.',
    );
  }

  void updateSpeechRate(double rate) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        defaultVoiceSpeechRate: rate,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Voice speech rate adjusted to $rate.',
    );
  }

  void toggleAutoDispatch() {
    state = state.copyWith(
      settings: state.settings.copyWith(
        isAutoDispatchEnabled: !state.settings.isAutoDispatchEnabled,
        lastConfiguredAt: DateTime.now(),
      ),
      confirmationMessage: 'Auto-dispatch algorithm toggled.',
    );
  }
}

final systemSettingsProvider = StateNotifierProvider<SystemSettingsNotifier, SystemSettingsState>((ref) {
  return SystemSettingsNotifier();
});
