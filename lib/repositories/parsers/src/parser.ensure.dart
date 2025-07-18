// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// SubclassGenerator
// **************************************************************************

// Generated code - do not modify by hand
import 'package:isar/isar.dart';
import 'package:bunny/models/download.dart';
import 'package:bunny/models/setting.dart';
import 'package:bunny/repositories/parsers/src/platform/kuaishou.dart';
import 'package:bunny/repositories/parsers/src/platform/douyin.dart';
import 'package:bunny/repositories/parsers/src/platform/yy.dart';
import 'package:bunny/repositories/parsers/src/platform/huya.dart';
import 'package:bunny/repositories/parsers/src/platform/huajiao.dart';
import 'package:bunny/repositories/parsers/src/platform/youtube2.dart';
import 'package:bunny/repositories/parsers/src/platform/inke.dart';
import 'package:bunny/repositories/parsers/src/platform/youtube.dart';
import 'package:bunny/repositories/parsers/src/platform/wycc.dart';
import 'package:bunny/repositories/parsers/src/platform/xhs.dart';
import 'package:bunny/repositories/parsers/src/platform/tiktok.dart';
import 'package:bunny/repositories/parsers/src/platform/blbl.dart';
import 'package:bunny/repositories/parsers/src/platform/douyu.dart';
import 'package:bunny/repositories/parsers/src/platform/dw.dart';

void ensureParserInitialized() {
  KuaishouParser();
  DouyinParser();
  YyParser();
  HuyaParser();
  HuajiaoParser();
  Youtube2Parser();
  InkeParser();
  YoutubeParser();
  WyCCParser();
  XhsParser();
  TiktokParser();
  BlblParser();
  DouyuParser();
  DwParser();
}

List<CollectionSchema<dynamic>> ensureIsarInitialized() {
  return [DownloadModelSchema, SettingSchema];
}
