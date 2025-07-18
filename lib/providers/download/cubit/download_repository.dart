import 'package:bunny/models/common.dart';
import 'package:bunny/models/download.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/providers/download/cubit/download_cubit.dart';
import 'package:bunny/providers/setting/cubit/setting_repository.dart';
import 'package:bunny/repositories/parsers/export.dart';
import 'package:bunny/services/task/export.dart';
import 'package:isar/isar.dart';
import 'package:sharebox/services/db.dart';

class DownloadRepository {
  final DBService db = DBService();
  final TaskManager tm = TaskManager();
  final List<DownloadItemCubit> items = [];

  static final DownloadRepository _instance = DownloadRepository._internal();

  DownloadRepository._internal();

  // 获取单例实例
  factory DownloadRepository() {
    return _instance;
  }

  Future<Media?> parseUrl(String url) async {
    Parser? parser = ParserHelper().getParser(url);
    if (parser != null) {
      return await parser.streaming(url);
    }
    throw Respones(404, "Unsupported platform");
    // UnsupportedError('不支持的平台');
  }

  Future<Source?> getSource(Media m, Quality quality) async {
    Parser? parser = ParserHelper().getParserByPlatform(m.platform);
    if (parser != null) {
      return await parser.chooseQuality(m, quality);
    }
    throw Respones(404, "Unsupported platform");
  }

  Future<void> addItem(List<DownloadItem> downloadItems) async {
    // 临时先用这个路径
    String savePath = SettingRepository().getDownloadPath();

    for (var item in downloadItems) {
      DownloadItemCubit cubit = DownloadItemCubit(
          item: item.copyWith(savedPath: savePath), repository: this);

      TaskChannel channel;

      if (item.source.categroy == Categroy.living) {
        channel = await tm.addTask(
            StreamRecorderTask(
                item.id, item.source.url!, savePath, item.filename),
            callback: (TaskMessage tmsg) {
          cubit.push(tmsg);
        });
      } else {
        channel = await tm.addTask(
            DownloadTask(item.id, item.source.url!, savePath, item.filename),
            callback: (TaskMessage tmsg) {
          cubit.push(tmsg);
        });
      }
      cubit.setChannel(channel);
      items.add(cubit);
    }
  }

  List<DownloadItemCubit> loadItem() => items;

  void deleteItem({DownloadItem? item, String? itemId}) {
    if (item != null || itemId != null) {
      var index = -1;
      if (itemId != null && itemId != "") {
        index = items.indexWhere((i) => i.item.id == itemId);
      } else {
        index = items.indexWhere((i) => i.item.id == item?.id);
      }
      if (index != -1) {
        items.removeAt(index);
      }
    }
  }

  Future<List<DownloadModel?>> loadDownloads() async {
    return await db.isar.downloadModels
        .where(
          sort: Sort.desc,
        )
        .anyId()
        .findAll();
  }

  void saveDownload(DownloadItem item) async {
    db.isar.writeTxnSync(() {
      db.isar.downloadModels.putSync(DownloadModel.fromDownloadItem(item));
    });
  }

  void deleteDownload(int id) async {
    db.isar.writeTxnSync(() {
      db.isar.downloadModels.deleteSync(id);
    });
  }

  void dispose() {
    items.clear();
    tm.dispose();
    db.close();
  }
}
