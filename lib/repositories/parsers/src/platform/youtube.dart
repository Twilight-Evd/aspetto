import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:html/parser.dart' as htmlParser;

class YoutubeParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: 'Youtube',
        link: 'https://www.youtube.com/',
        icon: 'youtube.png',
        domains: <String>[
          "www.youtube.com",
        ],
      );

  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36 Edg/88.0.705.68',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    "Origin": "https://youtube.com",
    "accept-language": "zh-CN,zh;q=0.9,en;q=0.8"
    // "Sec-Fetch-Mode": "navigate",
  };
  late Dio dio;
  late String k;
  YoutubeParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
    dio.options.responseType = ResponseType.bytes;
  }
  @override
  Future<Media?> streaming(String shareUrl) async {
    // try {
    final uri = Uri.parse(shareUrl);
    final roomId = uri.queryParameters['v'] ?? '';
    if (roomId.isEmpty) {
      return null;
    }

    k = "${platform.name}-${Utils.strToMd5(roomId)}";

// &bpctr=9999999999&has_verified=1
    var response = await dio.get('https://www.youtube.com/watch?v=$roomId');
    if (response.statusCode != 200) {
      return null;
    }
    final htmlContent = response.data;

    var document = htmlParser.parseFragment(htmlContent);
    FileHelper.writeToFile("./$k-youtbe.html", document.outerHtml);
    final scriptReg = RegExp(r'<script\b[^>]*>([\s\S]*?)<\/script>',
        multiLine: true, caseSensitive: false);

    final avatarRegExp = RegExp(
      r'"channelAvatar"\s*:\s*{\s*"thumbnails"\s*:\s*\[\s*{"url"\s*:\s*"([^"]+)"}',
    );

    // final basejsPattern =
    //     RegExp(r'(/s/player/\w+/player_ias.vflset/\w+/base.js)');

    // final links = basejsPattern.firstMatch(document.outerHtml);
    // if (links != null) {
    //   final link = links.group(1);
    //   logger.d(link);

    //   final jsFileRespones = await dio.get("https://www.youtube.com$link");
    //   FileHelper.writeToFile("$k.js", utf8.decode(jsFileRespones.data));
    // }

    // 查找包含直播数据的脚本
    final scriptTags = document.querySelectorAll('script');

    String avatar = "";
    for (var script in scriptTags) {
      final scriptContent = script.text;
      if (scriptContent.contains('var ytInitialData')) {
        final avatarMatch = avatarRegExp.firstMatch(scriptContent);
        if (avatarMatch != null) {
          avatar = avatarMatch.group(1)!;
        }
        continue;
      }
      if (scriptContent.contains('var ytInitialPlayerResponse')) {
        var s = scriptContent.replaceAll(scriptReg, "\$1");
        final JavascriptRuntime javascriptRuntime =
            getJavascriptRuntime(forceJavascriptCoreOnAndroid: false);
        JsEvalResult jsResult = await javascriptRuntime.evaluateAsync(
          '''
              const document = {
                createElement: () => ({}),
                getElementsByTagName: () => ({}),
                getElementsByTagName: () => ([{ appendChild: () => ({}) }]),
              }
              $s
              (function(){
                return JSON.stringify(ytInitialPlayerResponse);
              })();
              ''',
        );

        if (jsResult.stringResult != "") {
          final jsonData = jsonDecode(jsResult.stringResult);
          FileHelper.writeToFile("./$k-youtbe.json", jsResult.stringResult);
          final videoDetails = jsonData["videoDetails"];
          final thumbnails = videoDetails["thumbnail"]["thumbnails"] as List;
          final streamInfo = Media(
            categroy: Categroy.living,
            id: videoDetails['videoId'],
            platform: platform.simple(),
            title: videoDetails['title'],
            videos: [
              Source(
                  key: "0",
                  url: jsonData["streamingData"]["hlsManifestUrl"],
                  type: SourceType.m3u8,
                  quality: Quality(name: "自动", key: "1", resolution: ""),
                  categroy: Categroy.living)
            ],
            // flv: {},
            // m3u8: {"1": jsonData["streamingData"]["hlsManifestUrl"]},
            cover: thumbnails.last["url"],
            // streamingStatus: 2,
            author: Author(
              name: videoDetails['author'],
              avatar: avatar,
              id: videoDetails["channelId"],
              link: '',
            ),
            status: true,
            // audio: audio != null && audio.containsKey("flv") ? audio["flv"] : null,
          );
          return streamInfo;
        }
      }
    }
    return null;
  }
}
