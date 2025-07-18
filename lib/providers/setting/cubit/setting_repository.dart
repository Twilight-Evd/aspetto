import 'package:bunny/models/setting.dart';
import 'package:sharebox/services/db.dart';

class SettingRepository {
  Setting? _model;

  final DBService db = DBService();

  static final SettingRepository _instance = SettingRepository._internal();

  SettingRepository._internal();

  factory SettingRepository() {
    return _instance;
  }

  Future<bool> mustInit(Function() onInit) async {
    _model = await db.isar.settings.get(1);
    if (_model == null) {
      _model = await onInit();
      if (_model == null) {
        assert(_model != null, 'Failed to init setting');
        throw Exception("must init setting");
      }
      await save(_model!);
    }
    return _model == null;
  }

  Future<bool> save(Setting setting) async {
    db.isar.writeTxnSync(() {
      setting.id = 1;
      db.isar.settings.putSync(setting);
    });
    _model = setting;
    return true;
  }

  String getDownloadPath() {
    return _model!.downloadPath;
  }

  String getReceviedPath() {
    return _model!.receivedPath;
  }

  Setting get setting {
    if (_model != null) {
      return _model!;
    }
    _model = db.isar.settings.getSync(1);
    return _model!;
  }
}
