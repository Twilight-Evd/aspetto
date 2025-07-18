import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;

class WyCCParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: '网易CC',
        link: 'https://cc.163.com/',
        icon: 'wycc.jpg',
        domains: <String>[
          "cc.163.com",
        ],
      );

  var headers = {
    'accept': 'application/json, text/plain, */*',
    'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'referer': 'https://cc.163.com/',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.58',
  };
  late Dio dio;
  late String k;
  WyCCParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }
  @override
  Future<Media?> streaming(String shareUrl) async {
    try {
      shareUrl = shareUrl.endsWith('/') ? shareUrl : '$shareUrl/';
      k = "${platform.name}-${Utils.strToMd5(shareUrl)}";

      if (await FileHelper.fileExist("$k.html", true)) {
        var data = await FileHelper.readFromFile("$k.html");
        var document = htmlParser.parseFragment(data);
        return extractData(document.outerHtml);
      }
      var response = await dio.get(shareUrl);
      if (response.statusCode == 200) {
        var document = htmlParser.parseFragment(response.data);
        FileHelper.writeToFile("$k.html", document.outerHtml, true);
        return extractData(document.outerHtml);
      } else {
        throw Exception('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('流媒体请求出错: $e');
    }
  }

  Future<Media?> extractData(String htmlStr) async {
    // 使用正则表达式提取 JSON 数据
    final jsonRegExp = RegExp(
        r'<script id="__NEXT_DATA__".*crossorigin="anonymous">(.*?)</script>',
        dotAll: true);
    final match = jsonRegExp.firstMatch(htmlStr);
    if (match != null) {
      final jsonStr = match.group(1)!;
      final jsonData = jsonDecode(jsonStr);
      // 提取 roomInfoInitData 和 live 数据
      final roomData = jsonData['props']['pageProps']['roomInfoInitData'];
      final liveData = roomData['live'];

      if (liveData["quickplay"] != null) {
        Map resolutions = liveData["quickplay"]["resolution"];
        List<Source> videos = [];
        resolutions.forEach((k, v) {
          videos.add(
            Source(
              key: k,
              url: v["cdn"]["ali"] ?? v["cdn"]["hs"],
              type: SourceType.flv,
              quality: getQualityByKey(k) ?? supportQualities().first,
              categroy: Categroy.living,
              order: v["vbr"],
            ),
          );
        });
        videos.sort((a, b) => b.order.compareTo(a.order));

        var streamInfo = Media(
          categroy: Categroy.living,
          id: liveData['cuteid'].toString(),
          platform: platform.simple(),
          title: liveData['title'],
          cover: liveData['poster'],
          videos: videos,
          author: Author(
            name: liveData['nickname'],
            avatar: liveData['purl'],
            id: liveData['uid'].toString(),
            link: '',
          ),
          status: true,
        );
        logger.d(streamInfo.toJson());
        return streamInfo;
      }
      print('未找到所需的 JSON 数据');
    }
    // 解析 JSON 字符串
    return null;
  }

  @override
  List<Quality> supportQualities() => [
        Quality(name: "蓝光", key: "blueray", resolution: ""),
        Quality(name: "超清", key: "ultra", resolution: ""),
        Quality(name: "高清", key: "high", resolution: ""),
        Quality(name: "标准", key: "standard", resolution: ""),
      ];
}
