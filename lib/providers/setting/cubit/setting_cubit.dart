import 'dart:io';

import 'package:bunny/models/setting.dart';
import 'package:bunny/providers/setting/cubit/setting_repository.dart';
import 'package:bunny/providers/setting/cubit/setting_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingCubit extends Cubit<SettingState> {
  final SettingRepository repository;

  SettingCubit(this.repository)
      : super(SettingState(
          model: repository.setting,
        ));

  void changeTheme(ThemeMode themeMode) {
    Setting model = state.model.copyWith(themeMode: themeMode.toString());
    emit(state.copyWith(model: model));
  }

  void setAlwaysOnTop() {
    Setting model = state.model.copyWith(
        alwaysOnTop:
            state.model.alwaysOnTop == null ? true : !state.model.alwaysOnTop!);
    emit(state.copyWith(model: model));
  }

  void changeLang(String lang) {
    Setting model = state.model.copyWith(lang: lang);
    emit(state.copyWith(model: model));
  }

  void setDownloadPath(Directory dir) {
    Setting model = state.model.copyWith(downloadPath: dir.path);
    emit(state.copyWith(model: model));
  }

  void setReceviedPath(Directory dir) {
    Setting model = state.model.copyWith(receivedPath: dir.path);
    emit(state.copyWith(model: model));
  }

  @override
  void onChange(Change<SettingState> change) {
    repository.save(change.nextState.model);
    super.onChange(change);
  }
}
