import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sharebox/models/ensure_isar.dart';

part 'setting.g.dart';

@JsonSerializable()
@collection
class Setting extends EnsureIsar {
  Id id = Isar.autoIncrement;
  final String? themeMode;
  final bool? alwaysOnTop;
  final String? lang;
  final String downloadPath;
  final String receivedPath;

  Setting({
    this.themeMode,
    this.alwaysOnTop = false,
    this.lang,
    required this.downloadPath,
    required this.receivedPath,
  });

  Setting copyWith(
      {String? themeMode,
      bool? alwaysOnTop,
      String? lang,
      String? downloadPath,
      String? receivedPath}) {
    return Setting(
      themeMode: themeMode ?? this.themeMode,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      lang: lang ?? this.lang,
      downloadPath: downloadPath ?? this.downloadPath,
      receivedPath: receivedPath ?? this.receivedPath,
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json) =>
      _$SettingFromJson(json);
  Map<String, dynamic> toJson() => _$SettingToJson(this);
}
