// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaPlatform _$MediaPlatformFromJson(Map<String, dynamic> json) =>
    MediaPlatform(
      name: json['name'] as String,
      icon: json['icon'] as String,
      link: json['link'] as String?,
      domains:
          (json['domains'] as List<dynamic>?)?.map((e) => e as String).toList(),
      display: json['display'] as bool?,
      enabled: json['enabled'] as bool?,
      order: (json['order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MediaPlatformToJson(MediaPlatform instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('link', instance.link);
  val['icon'] = instance.icon;
  writeNotNull('domains', instance.domains);
  writeNotNull('display', instance.display);
  writeNotNull('enabled', instance.enabled);
  writeNotNull('order', instance.order);
  return val;
}

Format _$FormatFromJson(Map<String, dynamic> json) => Format(
      parameter: json['parameter'] as String,
      name: json['name'] as String,
      categroy: $enumDecode(_$CategroyEnumMap, json['categroy']),
    );

Map<String, dynamic> _$FormatToJson(Format instance) => <String, dynamic>{
      'parameter': instance.parameter,
      'name': instance.name,
      'categroy': _$CategroyEnumMap[instance.categroy]!,
    };

const _$CategroyEnumMap = {
  Categroy.video: 'video',
  Categroy.audio: 'audio',
  Categroy.image: 'image',
  Categroy.living: 'living',
};

RecordForm _$RecordFormFromJson(Map<String, dynamic> json) => RecordForm(
      addr: json['addr'] as String,
      remark: json['remark'] as String,
      format: json['format'] as String?,
      quality: (json['quality'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecordFormToJson(RecordForm instance) {
  final val = <String, dynamic>{
    'addr': instance.addr,
    'remark': instance.remark,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('format', instance.format);
  writeNotNull('quality', instance.quality);
  return val;
}

Source _$SourceFromJson(Map<String, dynamic> json) => Source(
      key: json['key'] as String,
      url: json['url'] as String?,
      type: $enumDecodeNullable(_$SourceTypeEnumMap, json['type']),
      quality: Quality.fromJson(json['quality'] as Map<String, dynamic>),
      categroy: $enumDecode(_$CategroyEnumMap, json['categroy']),
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SourceToJson(Source instance) {
  final val = <String, dynamic>{
    'key': instance.key,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('url', instance.url);
  writeNotNull('type', _$SourceTypeEnumMap[instance.type]);
  val['quality'] = instance.quality;
  val['categroy'] = _$CategroyEnumMap[instance.categroy]!;
  val['order'] = instance.order;
  return val;
}

const _$SourceTypeEnumMap = {
  SourceType.flv: 'flv',
  SourceType.m3u8: 'm3u8',
  SourceType.zip: 'zip',
};

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
      id: json['id'] as String,
      categroy: $enumDecode(_$CategroyEnumMap, json['categroy']),
      platform:
          MediaPlatform.fromJson(json['platform'] as Map<String, dynamic>),
      title: json['title'] as String,
      status: json['status'] as bool,
      author: json['author'] == null
          ? null
          : Author.fromJson(json['author'] as Map<String, dynamic>),
      videos: (json['videos'] as List<dynamic>?)
          ?.map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
      cover: json['cover'] as String?,
      audio: json['audio'] == null
          ? null
          : Source.fromJson(json['audio'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MediaToJson(Media instance) {
  final val = <String, dynamic>{
    'categroy': _$CategroyEnumMap[instance.categroy]!,
    'id': instance.id,
    'platform': instance.platform,
    'title': instance.title,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('author', instance.author);
  writeNotNull('videos', instance.videos);
  writeNotNull('audio', instance.audio);
  writeNotNull('images', instance.images);
  writeNotNull('cover', instance.cover);
  val['status'] = instance.status;
  return val;
}

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      link: json['link'] as String,
    );

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar': instance.avatar,
      'link': instance.link,
    };
