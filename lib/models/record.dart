import 'package:bunny/models/common.dart';
import 'package:json_annotation/json_annotation.dart';

part 'record.g.dart';

@JsonSerializable()
class MediaPlatform {
  final String name;
  final String? link;
  final String icon;
  final List<String>? domains;

  final bool? display;
  final bool? enabled;
  final int? order; //desc

  const MediaPlatform({
    required this.name,
    required this.icon,
    this.link,
    this.domains,
    this.display,
    this.enabled,
    this.order,
  });

  factory MediaPlatform.fromJson(Map<String, dynamic> json) =>
      _$MediaPlatformFromJson(json);
  Map<String, dynamic> toJson() => _$MediaPlatformToJson(this);

  MediaPlatform simple() {
    return MediaPlatform(
      name: name,
      icon: icon,
    );
  }
}

@JsonSerializable()
class Format {
  final String parameter;
  final String name;
  final Categroy categroy;

  const Format({
    required this.parameter,
    required this.name,
    required this.categroy,
  });

  factory Format.fromJson(Map<String, dynamic> json) => _$FormatFromJson(json);
  Map<String, dynamic> toJson() => _$FormatToJson(this);
}

@JsonSerializable()
class RecordForm {
  String addr;
  String remark;
  String? format;
  int? quality;

  RecordForm({
    required this.addr,
    required this.remark,
    this.format,
    this.quality,
  });

  factory RecordForm.fromJson(Map<String, dynamic> json) =>
      _$RecordFormFromJson(json);
  Map<String, dynamic> toJson() => _$RecordFormToJson(this);
}

enum SourceType {
  flv("flv"),
  m3u8("m3u8"),
  zip("zip");

  const SourceType(this.value);
  final String value;

  factory SourceType.byValue(String value) =>
      SourceType.values.firstWhere((element) => element.value == value);
}

@JsonSerializable()
class Source {
  final String key;
  final String? url;
  final SourceType? type;
  final Quality quality;
  final Categroy categroy;

  final int order;

  const Source({
    required this.key,
    this.url, //if categroy is live, this is null, should fetch by quality
    this.type,
    required this.quality,
    required this.categroy,
    this.order = 0,
  });

  factory Source.fromJson(Map<String, dynamic> json) => _$SourceFromJson(json);
  Map<String, dynamic> toJson() => _$SourceToJson(this);

  Source copyWith({Quality? quality}) {
    return Source(
      key: key,
      url: url,
      type: type,
      quality: quality ?? this.quality,
      categroy: categroy,
      order: order,
    );
  }
}

@JsonSerializable()
class Media {
  final Categroy categroy;
  final String id;
  final MediaPlatform platform;
  final String title;
  final Author? author;
  final List<Source>? videos;
  final Source? audio;
  final List<Source>? images;
  final String? cover;
  final bool status;

  Media({
    required this.id,
    required this.categroy,
    required this.platform,
    required this.title,
    required this.status,
    this.author,
    this.videos,
    this.cover,
    this.audio,
    this.images,
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
  Map<String, dynamic> toJson() => _$MediaToJson(this);
}

@JsonSerializable()
class Author {
  final String id;
  final String name;
  final String avatar;
  final String link;

  Author({
    required this.id,
    required this.name,
    required this.avatar,
    required this.link,
  });

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}
