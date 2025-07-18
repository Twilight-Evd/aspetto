import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;

class KuaishouParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: '快手',
        link: 'https://www.kuaishou.com/',
        icon: 'kuaishou.webp',
        domains: <String>[
          "live.kuaishou.com",
          "kuaishou.com",
        ],
      );

  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0',
    'Accept-Language':
        'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
  };
  late Dio dio;
  late String k;
  KuaishouParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }
  @override
  Future<Media?> streaming(String shareUrl) async {
    try {
      k = Utils.strToMd5(shareUrl);
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
    final RegExp scriptPattern = RegExp(
        r'<script>window.__INITIAL_STATE__=(.*?);\(function\(\)\{var s;');
    final Match? scriptMatch = scriptPattern.firstMatch(htmlStr);
    if (scriptMatch == null) {
      throw Exception('无法找到脚本中的初始状态');
    }
    final String? jsonStr = scriptMatch.group(1);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final RegExp playListPattern = RegExp(r'(\{"liveStream".*?),"gameInfo');
      final Match? playListMatch = playListPattern.firstMatch(jsonStr);
      if (playListMatch == null) {
        throw Exception('无法找到播放列表');
      }
      if (playListMatch.group(1) != null) {
        Map<String, dynamic> playObject =
            jsonDecode("${playListMatch.group(1)!}}");
        if (playObject.containsKey("errorType")) {
          if (playObject["errorType"] != null) {
            var errorMsg = playObject["errorType"]["title"] +
                playObject["errorType"]["content"];
            throw Exception("失败, 错误信息: $errorMsg");
          }
          throw Exception('无法找到播放列表');
        }
        if (playObject["liveStream"] == null) {
          throw Exception("IP banned. Please change device or network.");
        }
        final author = playObject["author"],
            liveStream = playObject["liveStream"];
        List<Source> videos = [];
        if (liveStream["playUrls"] != null) {
          final playUrls = liveStream["playUrls"] as List;
          final playUrlsFirst = playUrls.first;
          List urls = playUrlsFirst['adaptationSet']['representation'] as List;
          videos = urls
              .map((obj) => Source(
                    url: obj["url"],
                    type: SourceType.flv,
                    key: obj["qualityType"],
                    quality: Quality(
                        name: obj["name"],
                        key: obj["qualityType"],
                        resolution: ""),
                    categroy: Categroy.living,
                  ))
              .toList();
        }
        var streamInfo = Media(
          categroy: Categroy.living,
          id: liveStream['id'],
          platform: platform.simple(),
          title: author['name'],
          videos: videos,
          cover: liveStream['poster'],
          author: Author(
            name: author['name'],
            avatar: author['avatar'],
            id: author['id'],
            link: '',
          ),
          status: true,
        );
        return streamInfo;
      }
    }
    return null;
  }
}
