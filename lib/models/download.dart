import 'dart:convert';

import 'package:bunny/models/record.dart';
import 'package:bunny/services/task/task.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sharebox/models/ensure_isar.dart';
import 'package:sharebox/utils/extensions/ext.dart';
import 'package:sharebox/utils/util.dart';

part 'download.g.dart';

class DownloadSelection {
  final int? video;
  final bool? audio;
  final List<int>? images;
  final String error;
  final bool isLoading;

  const DownloadSelection({
    this.video,
    this.audio,
    this.images,
    this.error = "",
    this.isLoading = false,
  });

  DownloadSelection copyWith({
    int? video,
    bool? audio,
    List<int>? images,
    String? error,
    bool? isLoading,
  }) {
    if (audio != null && audio == this.audio) {
      audio = false;
    }
    return DownloadSelection(
      video: video ?? this.video,
      audio: audio ?? this.audio,
      images: images ?? this.images,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool selected() {
    return (video != null ||
        video != null ||
        (images != null && images!.isNotEmpty));
  }

  bool enabledBtn() {
    return (selected() && isLoading == false);
  }
}

extension DownloadSelectionExtensions on DownloadSelection {
  List<DownloadItem>? copyForDownloadItem(
    Media media, {
    Source? videoSource,
    Source? audioSource,
    List<Source>? imageSource,
  }) {
    List<DownloadItem> items = [];

    if (video != null) {
      items.add(DownloadItem(
          id: Utils.id,
          title: media.title,
          cover: media.cover,
          platform: media.platform,
          source: videoSource ?? media.videos!.elementAt(video!),
          filename: "${media.title.safeFileName}.mp4"));
    }
    if (audio != null && media.audio != null) {
      items.add(DownloadItem(
          id: Utils.id,
          title: media.title,
          cover: media.cover,
          platform: media.platform,
          source: media.audio!,
          filename: "${media.title.safeFileName}.mp3"));
    }
    if (images != null &&
        images!.isNotEmpty &&
        media.images != null &&
        media.images!.isNotEmpty) {
      items.addAll(images!
          .map((index) => DownloadItem(
              id: Utils.id,
              title: media.title,
              cover: media.cover,
              platform: media.platform,
              source: media.images![index],
              filename: "${media.title.safeFileName}-$index.png"))
          .toList());
    }
    return items;
  }
}

@JsonSerializable()
class DownloadItem {
  final String id;
  final MediaPlatform platform;
  final String title;
  final Source source;
  final String filename;

  final String? cover;
  final Duration? totalTime; //总时间
  final Duration? time; // 剩余时间。或者 录制时间
  final double? speed; //下载速动
  final int? received; //下载的大小
  final int? total; //总大小
  final TaskStatus? status; // 下载完成
  final double? progress; //下载进度
  final String? savedPath;

  final int? localId;

  DownloadItem({
    required this.id,
    required this.source,
    required this.title,
    required this.cover,
    required this.platform,
    required this.filename,
    this.totalTime,
    this.progress,
    this.time,
    this.status,
    this.received,
    this.total,
    this.speed,
    this.savedPath,
    this.localId,
  });

  DownloadItem copyWith({
    double? progress,
    Duration? time,
    TaskStatus? status,
    int? received,
    int? total,
    double? speed,
    String? savedPath,
    int? localId,
    String? resolution,
  }) {
    return DownloadItem(
      id: id,
      source: (resolution != null && resolution != "")
          ? source.copyWith(
              quality: source.quality.copyWith(resolution: resolution))
          : source,
      title: title,
      cover: cover,
      platform: platform,
      filename: filename,
      progress: progress ?? this.progress,
      time: time ?? this.time,
      status: status ?? this.status,
      received: received ?? this.received,
      total: total ?? this.total,
      speed: speed ?? this.speed,
      savedPath: savedPath ?? this.savedPath,
      localId: localId ?? this.localId,
    );
  }

  factory DownloadItem.fromJson(Map<String, dynamic> json) =>
      _$DownloadItemFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadItemToJson(this);
}

@collection
class DownloadModel extends EnsureIsar {
  Id id = Isar.autoIncrement;
  final String title;
  final String cover;
  final String filename;
  final int status; // 下载完成
  final String savedPath;
  final String originData;

  DownloadModel({
    required this.filename,
    required this.title,
    required this.cover,
    required this.status,
    required this.savedPath,
    required this.originData,
  });

  factory DownloadModel.fromDownloadItem(DownloadItem item) {
    var jsonItem = item.toJson();
    jsonItem.remove("speed");
    jsonItem.remove("progress");
    jsonItem.remove("received");

    return DownloadModel(
      filename: item.filename,
      title: item.title,
      cover: item.cover ?? "",
      status: 1,
      savedPath: item.savedPath!,
      originData: jsonEncode(jsonItem),
    );
  }
}
