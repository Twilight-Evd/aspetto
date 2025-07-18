import 'package:bunny/models/setting.dart';

class SettingState {
  final Setting model;

  SettingState({
    required this.model,
  });

  SettingState copyWith({
    Setting? model,
  }) {
    return SettingState(
      model: model ?? this.model,
    );
  }
}
