import 'dart:convert';

import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:dio/dio.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';

class Youtube2Parser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: 'youtube 2',
        link: 'https://www.youtube.com/',
        icon: 'youtube.png',
        domains: <String>[
          "www.youtube.com",
        ],
        enabled: false,
      );

  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0',
    'Accept-Language':
        'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
    "Origin": "https://youtube.com",
    "Sec-Fetch-Mode": "navigate",
  };
  late Dio dio;
  late String k;
  Youtube2Parser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }

  /*
  AndroidClient = clientInfo{
		name:           "ANDROID",
		version:        "18.11.34",
		key:            "AIzaSyA8eiZmM1FaDVjRy-df2KTyQ_vz_yYM39w",
		userAgent:      "com.google.android.youtube/18.11.34 (Linux; U; Android 11) gzip",
		androidVersion: 30,
	}*/

  @override
  Future<Media?> streaming(String shareUrl) async {
    final videoID = extractVideoID(shareUrl);

    final playerParams = "CgIQBg==";

    var clientInfo = {
      "name": "ANDROID",
      "version": "18.11.34",
      "key": "AIzaSyA8eiZmM1FaDVjRy-df2KTyQ_vz_yYM39w",
      "userAgent":
          "com.google.android.youtube/18.11.34 (Linux; U; Android 11) gzip",
      "androidVersion": 30,
    };

    var data = {
      "videoId": videoID,
      // "browseId": "",
      // "continuation": "",
      "context": {
        "client": {
          "hl": "en",
          "gl": "US",
          "clientName": clientInfo["name"],
          "clientVersion": clientInfo["version"],
          "androidSDKVersion": clientInfo["androidVersion"],
          "userAgent": clientInfo["userAgent"],
          "timeZone": "UTC",
          // "utcOffsetMinutes": "",
        },
      },
      "playbackContext": {
        "contentPlaybackContext": {
          "html5Preference": "HTML5_PREF_WANTS",
        }
      },
      "contentCheckOk": true,
      "racyCheckOk": true,
      "params": playerParams,
    };

    final res = await dio.post(
      "https://www.youtube.com/youtubei/v1/player?key=${clientInfo['key']}",
      data: data,
      options: Options(
        headers: {
          "X-Youtube-Client-Name": "3",
          "X-Youtube-Client-Version": clientInfo["version"],
          "Content-Type": "application/json",
          "Accept":
              "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          'User-Agent': clientInfo["userAgent"],
        },
        responseType: ResponseType.bytes,
      ),
    );

    logger.d(utf8.decode(res.data));

    FileHelper.writeToFile("youtube2.json", utf8.decode(res.data));
    return null;

    // final htmlRes = await dio.get(
    //     "https://www.youtube.com/watch?v=$videoID&bpctr=9999999999&has_verified=1");
  }
}

class YouTubeVideoIDError implements Exception {
  final String message;
  YouTubeVideoIDError(this.message);
  @override
  String toString() => message;
}

// 定义正则表达式列表
final List<RegExp> videoRegexpList = [
  RegExp(r'(?:v|embed|shorts|watch\?v)(?:=|/)([^"&?/=%]{11})'),
  RegExp(r'(?:=|/)([^"&?/=%]{11})'),
  RegExp(r'([^"&?/=%]{11})'),
];

// 提取视频ID的函数
String extractVideoID(String videoID) {
  if (videoID.contains("youtu") || videoID.contains(RegExp(r'[\"?&/<%=]'))) {
    for (final re in videoRegexpList) {
      if (re.hasMatch(videoID)) {
        final match = re.firstMatch(videoID);
        if (match != null && match.groupCount >= 1) {
          videoID = match.group(1)!;
        }
      }
    }
  }

  if (videoID.contains(RegExp(r'[?&/<%=]'))) {
    throw YouTubeVideoIDError("Invalid characters found in video ID.");
  }

  if (videoID.length < 10) {
    throw YouTubeVideoIDError("Video ID is too short.");
  }

  return videoID;
}
