// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quality _$QualityFromJson(Map<String, dynamic> json) => Quality(
      name: json['name'] as String,
      key: json['key'] as String,
      codec: json['codec'] as String?,
      resolution: json['resolution'] as String?,
      fps: json['fps'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$QualityToJson(Quality instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'key': instance.key,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('codec', instance.codec);
  writeNotNull('resolution', instance.resolution);
  writeNotNull('fps', instance.fps);
  val['order'] = instance.order;
  return val;
}
