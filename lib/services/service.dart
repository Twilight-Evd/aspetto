// 读取剪切板内容

import 'dart:core'; // 添加此行以使用 Stopwatch
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:bunny/models/setting.dart';
import 'package:bunny/providers/setting/cubit/setting_repository.dart';
import 'package:bunny/repositories/parsers/export.dart';
import 'package:bunny/utils/util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sharebox/models/ensure_isar.isar.dart';
import 'package:sharebox/models/file.dart';
import 'package:sharebox/providers/courier/bloc/courier_bloc.dart';
import 'package:sharebox/providers/observer.dart';
import 'package:sharebox/services/db.dart';
import 'package:sharebox/services/service_manager.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/path.dart';

class Services {
  static WebViewEnvironment? webViewEnvironment;

  static Stream<double> ensureInitialized() async* {
    yield 0.1;
    await prepareFfmpeg();
    yield 0.3;
    ensureParserInitialized();
    yield 0.5;

    yield 0.6;

    fvp.registerWith(options: {
      'platforms': ['windows', 'macos']
    });
    yield 0.7;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      assert(availableVersion != null,
          'Failed to find an installed WebView2 runtime or non-stable Microsoft Edge installation.');
      webViewEnvironment = await WebViewEnvironment.create();
      // settings: WebViewEnvironmentSettings());
    }
    yield 1;
  }

  static Future<void> initialize([CourierBloc? state]) async {
    Bloc.observer = SimpleBlocObserver();

    await EasyLocalization.ensureInitialized();

    final schemas = ensureIsarInitialized();
    schemas.addAll(ensureIsarImported());
    if (schemas.isNotEmpty) {
      await DBService().init(schemas);
    }

    try {
      final destination = await PathHelper.getBaseDestinationDirectory();
      await SettingRepository().mustInit(() async {
        final downloadPath = await toAppPath(
          destination,
          append: "download",
        );
        final receivedPath = await toAppPath(
          destination,
          append: "received",
        );
        return Setting(
          downloadPath: downloadPath.path,
          receivedPath: receivedPath.path,
        );
      });
    } catch (e) {
      logger.e(e);
    }

    if (state != null) {
      state.setSavePath(
        SaveWay(
            gallery: false, savePath: SettingRepository().setting.receivedPath),
      );
      try {
        await ServiceManager.setupService(state, 15411); //setupService(state);
      } catch (e) {
        logger.d(">>>>>>>>>>>>>>>>>>>>. $e");
      }
    }
  }

  static Future<String> readClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      return data.text ?? "";
    }
    return "";
  }

  static Future<void> copyData(String data) async {
    if (data.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: data));
    }
  }

  static Future<Directory> toAppPath(
    String filepath, {
    bool? toSync = true,
    String? append,
  }) async {
    String appName = await getAppName();
    Directory dir = Directory(PathHelper.join(filepath, appName, append));
    try {
      if (toSync != null && toSync == true) {
        if (!(dir.existsSync())) {
          dir.createSync(recursive: true);
        }
      }
    } catch (e) {
      logger.d(
          "${PathHelper.join(filepath, appName, "Downloaded")}---- $toSync --- $e");
    }
    return dir;
  }

  static Future<String> getAppName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.appName;
  }

  static Future<void> prepareFfmpeg() async {
    try {
      final shellPath = UtilHelper.getShellPath();
      final ffmpegZip = PathHelper.join(shellPath, "ffmpeg.zip");
      final ffmpegFile = PathHelper.join(
          shellPath, Platform.isWindows ? "ffmpeg.exe" : "ffmpeg");
      if (!await FileHelper.fileExist(ffmpegFile)) {
        extractFileToDisk(ffmpegZip, shellPath);
      }
    } catch (e) {
      logger.d(e);
    }
  }
}
