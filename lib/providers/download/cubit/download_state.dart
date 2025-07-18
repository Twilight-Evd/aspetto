import 'package:bunny/models/download.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/providers/download/cubit/download_cubit.dart';

class DownloadListState {
  final bool isLoading;
  final List<DownloadItemCubit> items;
  final List<DownloadItemCubit> completedItems;

  DownloadListState({
    required this.isLoading,
    this.items = const [],
    this.completedItems = const [],
  });

  DownloadListState copyWith({
    bool? isLoading,
    List<DownloadItemCubit>? items,
    List<DownloadItemCubit>? completedItems,
  }) {
    return DownloadListState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      completedItems: completedItems ?? this.completedItems,
    );
  }
}

class DownloadState {
  final bool isLoading;
  final Media? media;
  final String? url;
  final String? error;
  final DownloadSelection? selection;

  DownloadState({
    required this.isLoading,
    this.url,
    this.media,
    this.error,
    this.selection,
  });

  // 用于方便地创建新的状态实例时更新某个属性
  DownloadState copyWith({
    bool? isLoading,
    Media? media,
    String? error,
    DownloadSelection? selection,
    String? url,
  }) {
    return DownloadState(
      isLoading: isLoading ?? this.isLoading,
      media: media ?? this.media,
      error: error ?? this.error,
      url: url ?? this.url,
      selection: selection ?? this.selection,
    );
  }

  DownloadState empty() {
    return DownloadState(
      isLoading: false,
      media: null,
      error: null,
      url: null,
      selection: null,
    );
  }
}

class DownloadItemState {
  final DownloadItem item;

  DownloadItemState({
    required this.item,
  });

  DownloadItemState copyWith({DownloadItem? item}) {
    return DownloadItemState(item: item ?? this.item);
  }
}
