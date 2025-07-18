import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/download.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/providers/download/cubit/download_repository.dart';
import 'package:bunny/services/task/task.dart';
import 'package:bunny/utils/ffmpeg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:sharebox/utils/log.dart';

import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  final DownloadRepository repository;

  DownloadCubit(this.repository)
      : super(DownloadState(
          isLoading: false,
        ));

  void loadData(String url) async {
    emit(state.copyWith(isLoading: true, url: url));
    try {
      var media = await repository.parseUrl(url);
      if (media != null) {
        emit(state.copyWith(isLoading: false, media: media));
      } else {
        emit(state.copyWith(isLoading: false, error: "no data"));
      }
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void selectMedia({int? video, bool? audio, List<int>? images}) {
    emit(
      state.copyWith(
        selection: state.selection == null
            ? DownloadSelection()
                .copyWith(video: video, audio: audio, images: images)
            : state.selection!
                .copyWith(video: video, audio: audio, images: images),
      ),
    );
  }

  Future<bool> toDownload() async {
    Source? nsource;
    if (state.selection != null && state.media != null) {
      emit(
        state.copyWith(
          selection: state.selection!.copyWith(
            isLoading: true,
          ),
        ),
      );

      if (state.selection?.video != null) {
        //check need to fetch video
        Source? source = state.media?.videos?[state.selection!.video!];
        if (source != null && (source.url == null || source.url!.isEmpty)) {
          nsource = await repository.getSource(state.media!, source.quality);
          if (nsource == null) {
            emit(
              state.copyWith(
                selection: state.selection!.copyWith(
                  error: "no source",
                ),
              ),
            );
            await Future.delayed(Duration(seconds: 2));
            emit(
              state.copyWith(
                selection: state.selection!.copyWith(
                  error: "",
                  isLoading: false,
                ),
              ),
            );
            return false;
          }
        }
      }
      final items = state.selection!
          .copyForDownloadItem(state.media!, videoSource: nsource);
      if (items != null) {
        repository.addItem(items);
        return true;
      }
    }
    emit(
      state.copyWith(
        selection: state.selection!.copyWith(
          error: "",
          isLoading: false,
        ),
      ),
    );
    return false;
  }

  void clearData() {
    emit(state.empty());
  }
}

class DownloadListCubit extends Cubit<DownloadListState> {
  final DownloadRepository repository;

  DownloadListCubit(this.repository)
      : super(DownloadListState(
          isLoading: false,
        ));

  void loadData(int tab) async {
    emit(state.copyWith(isLoading: true));

    List<DownloadItemCubit> items = [];
    List<DownloadItemCubit> completedItems = [];

    try {
      if (tab == 1) {
        List<DownloadModel?> models = await repository.loadDownloads();
        completedItems = models.map((model) {
          var jsonData = jsonDecode(model!.originData);
          jsonData["source"]["url"] = p.join(model.savedPath, model.filename);
          return DownloadItemCubit(
            item: DownloadItem.fromJson(jsonData)
                .copyWith(localId: model.id), //  ..localId = model.id,
            repository: repository,
          );
        }).toList();
      } else {
        items = repository.loadItem();
      }
    } catch (e) {
      logger.e(e);
    }
    emit(DownloadListState(
      isLoading: false,
      items: items,
      completedItems: completedItems,
    ));
  }
}

class DownloadItemCubit extends Cubit<DownloadItemState> {
  DownloadItem item;

  final DownloadRepository repository;
  late final TaskChannel? _channel;

  DownloadItemCubit({
    required this.item,
    required this.repository,
  }) : super(DownloadItemState(item: item));

  void setChannel(
    TaskChannel? channel,
  ) {
    _channel = channel;
  }

  Future<void> push(TaskMessage tm) async {
    if (isClosed) return;

    double? progress;
    if ((tm.total != null || item.total != null) && tm.received != null) {
      progress = (tm.received! / tm.total!);
    }
    item = item.copyWith(
      time: tm.time,
      speed: tm.speed,
      total: tm.total,
      received: tm.received,
      progress: progress,
      status: tm.status,
    );
    logger.d("cubit :>>>>  ${item.toJson()}");
    if (tm.status == TaskStatus.completed) {
      if (item.source.categroy == Categroy.living) {
        final videoInfo = await FfmpegHelper.fetchVideoInfo(
            p.join(item.savedPath!, item.filename));
        Duration? duration;
        String? resolution;
        int? total;
        if (videoInfo.containsKey("duration")) {
          duration = videoInfo["duration"];
        }
        if (videoInfo.containsKey("resolution")) {
          resolution = videoInfo["resolution"];
        }
        if (videoInfo.containsKey("total")) {
          total = videoInfo["total"];
        }
        item = item.copyWith(
          time: duration,
          total: total,
          resolution: resolution,
        );
        logger.d(item.toJson().toString());
      }
      repository.saveDownload(item);
      repository.deleteItem(item: item);
    } else if (tm.status == TaskStatus.stopped) {
      repository.deleteItem(item: item);
    }
    emit(DownloadItemState(item: item));
  }

  void exit() {
    if (_channel != null) {
      _channel.emit(TaskCmd.exit);
    }
  }

  void pasue() {
    if (_channel != null) {
      _channel.emit(TaskCmd.pause);
    }
  }

  void resume() {
    if (_channel != null) {
      _channel.emit(TaskCmd.resume);
    }
  }

  //
  void delete() {
    int? localId = item.localId;
    String? itemId = item.id;
    if (localId != null && localId > 0) {
      repository.deleteDownload(localId);
    } else if (itemId.isNotEmpty) {
      repository.deleteItem(itemId: itemId);
    }
  }
}
