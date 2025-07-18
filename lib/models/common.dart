import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

enum Categroy {
  video("video"),
  audio("audio"),
  image("image"),
  living("living");

  const Categroy(this.value);
  final String value;

  factory Categroy.byValue(String value) =>
      Categroy.values.firstWhere((element) => element.value == value);
}

class Respones {
  int? code;
  String message;

  Respones(this.code, this.message);
}

@JsonSerializable()
class Quality {
  final String name;
  final String key;
  final String? codec;
  final String? resolution;
  final String? fps;
  final int order;

  Quality({
    required this.name,
    required this.key,
    this.codec,
    this.resolution,
    this.fps,
    this.order = 0,
  });

  factory Quality.fromJson(Map<String, dynamic> json) =>
      _$QualityFromJson(json);
  Map<String, dynamic> toJson() => _$QualityToJson(this);

  Quality copyWith(
      {String? name,
      String? key,
      String? codec,
      String? fps,
      String? resolution,
      int? order}) {
    return Quality(
      name: name ?? this.name,
      key: key ?? this.key,
      codec: codec ?? this.codec,
      fps: fps ?? this.fps,
      resolution: resolution ?? this.resolution,
      order: order ?? this.order,
    );
  }
}
