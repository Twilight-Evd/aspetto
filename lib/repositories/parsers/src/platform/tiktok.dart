import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;

class TiktokParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: 'Tiktok',
        link: 'https://www.tiktok.com',
        icon: 'tiktok.png',
        domains: <String>[
          "www.tiktok.com",
          "tiktok.com",
        ],
        enabled: false,
      );
  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    'Cookie':
        'ttwid=1%7CM-rF193sJugKuNz2RGNt-rh6pAAR9IMceUSzlDnPCNI%7C1683274418%7Cf726d4947f2fc37fecc7aeb0cdaee52892244d04efde6f8a8edd2bb168263269; tiktok_webapp_theme=light; tt_chain_token=VWkygAWDlm1cFg/k8whmOg==; passport_csrf_token=6e422c5a7991f8cec7033a8082921510; passport_csrf_token_default=6e422c5a7991f8cec7033a8082921510; d_ticket=f8c267d4af4523c97be1ccb355e9991e2ae06; odin_tt=320b5f386cdc23f347be018e588873db7f7aea4ea5d1813681c3fbc018ea025dde957b94f74146dbc0e3612426b865ccb95ec8abe4ee36cca65f15dbffec0deff7b0e69e8ea536d46e0f82a4fc37d211; cmpl_token=AgQQAPNSF-RO0rT04baWtZ0T_jUjl4fVP4PZYM2QPw; uid_tt=319b558dbba684bb1557206c92089cd113a875526a89aee30595925d804b81c7; uid_tt_ss=319b558dbba684bb1557206c92089cd113a875526a89aee30595925d804b81c7; sid_tt=ad5e736f4bedb2f6d42ccd849e706b1d; sessionid=ad5e736f4bedb2f6d42ccd849e706b1d; sessionid_ss=ad5e736f4bedb2f6d42ccd849e706b1d; store-idc=useast5; store-country-code=us; store-country-code-src=uid; tt-target-idc=useast5; tt-target-idc-sign=qXNk0bb1pDQ0FbCNF120Pl9WWMLZg9Edv5PkfyCbS4lIk5ieW5tfLP7XWROnN0mEaSlc5hg6Oji1pF-yz_3ZXnUiNMrA9wNMPvI6D9IFKKVmq555aQzwPIGHv0aQC5dNRgKo5Z5LBkgxUMWEojTKclq2_L8lBciw0IGdhFm_XyVJtbqbBKKgybGDLzK8ZyxF4Jl_cYRXaDlshZjc38JdS6wruDueRSHe7YvNbjxCnApEFUv-OwJANSPU_4rvcqpVhq3JI2VCCfw-cs_4MFIPCDOKisk5EhAo2JlHh3VF7_CLuv80FXg_7ZqQ2pJeMOog294rqxwbbQhl3ATvjQV_JsWyUsMd9zwqecpylrPvtySI2u1qfoggx1owLrrUynee1R48QlanLQnTNW_z1WpmZBgVJqgEGLwFoVOmRzJuFFNj8vIqdjM2nDSdWqX8_wX3wplohkzkPSFPfZgjzGnQX28krhgTytLt7BXYty5dpfGtsdb11WOFHM6MZ9R9uLVB; sid_guard=ad5e736f4bedb2f6d42ccd849e706b1d%7C1690990657%7C15525213%7CMon%2C+29-Jan-2024+08%3A11%3A10+GMT; sid_ucp_v1=1.0.0-KGM3YzgwYjZhODgyYWI1NjIwNTA0NjBmOWUxMGRhMjIzYTI2YjMxNDUKGAiqiJ30keKD5WQQwfCppgYYsws4AkDsBxAEGgd1c2Vhc3Q1IiBhZDVlNzM2ZjRiZWRiMmY2ZDQyY2NkODQ5ZTcwNmIxZA; ssid_ucp_v1=1.0.0-KGM3YzgwYjZhODgyYWI1NjIwNTA0NjBmOWUxMGRhMjIzYTI2YjMxNDUKGAiqiJ30keKD5WQQwfCppgYYsws4AkDsBxAEGgd1c2Vhc3Q1IiBhZDVlNzM2ZjRiZWRiMmY2ZDQyY2NkODQ5ZTcwNmIxZA; tt_csrf_token=dD0EIH8q-pe3qDQsCyyD1jLN6KizJDRjOEyk; __tea_cache_tokens_1988={%22_type_%22:%22default%22%2C%22user_unique_id%22:%227229608516049831425%22%2C%22timestamp%22:1683274422659}; ttwid=1%7CM-rF193sJugKuNz2RGNt-rh6pAAR9IMceUSzlDnPCNI%7C1694002151%7Cd89b77afc809b1a610661a9d1c2784d80ebef9efdd166f06de0d28e27f7e4efe; msToken=KfJAVZ7r9D_QVeQlYAUZzDFbc1Yx-nZz6GF33eOxgd8KlqvTg1lF9bMXW7gFV-qW4MCgUwnBIhbiwU9kdaSpgHJCk-PABsHCtTO5J3qC4oCTsrXQ1_E0XtbqiE4OVLZ_jdF1EYWgKNPT2SnwGkQ=; msToken=KfJAVZ7r9D_QVeQlYAUZzDFbc1Yx-nZz6GF33eOxgd8KlqvTg1lF9bMXW7gFV-qW4MCgUwnBIhbiwU9kdaSpgHJCk-PABsHCtTO5J3qC4oCTsrXQ1_E0XtbqiE4OVLZ_jdF1EYWgKNPT2SnwGkQ=',
  };

  late Dio dio;

  late String k;

  TiktokParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }

  @override
  Future<Media?> streaming(String shareUrl) async {
    // try {
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
  }

  Media? processLiveRoom(Map<String, dynamic> jsonData) {
    var liveRoom = jsonData['LiveRoom']['liveRoomUserInfo'];
    // logger.d("liveRoom::::::::::: $liveRoom");
    var user = liveRoom['user'];
    // String anchorName = '${user['nickname']}-${user['uniqueId']}';
    int status = user['status'] ?? 4;

    // var result = {
    //   "anchor_name": anchorName,
    //   "is_live": false,
    // };
    liveRoom = liveRoom["liveRoom"];

    if (status == 2) {
      List<Quality> qs = [];

      var streamData = liveRoom['streamData']['pull_data']['stream_data'];
      var options = liveRoom['streamData']['pull_data']['options'];
      logger.d(options);
      logger.d(options["qualities"]);
      final qualitiesData = options["qualities"] as List;
      qs = qualitiesData
          .map((q) =>
              Quality(name: q["name"], key: q["sdk_key"], resolution: ""))
          .toList();

      final streamDataMap =
          jsonDecode(streamData)['data'] as Map<String, dynamic>;

      Source? audio;
      List<Source> videos = [];
      streamDataMap.forEach(
        (key, value) {
          var urlInfo = value['main'];
          if (key == "ao") {
            if (urlInfo["flv"] != "") {
              audio = Source(
                  key: key,
                  quality: Quality(name: "", key: key),
                  categroy: Categroy.audio);
            }
          } else {
            final sdkParams = jsonDecode(urlInfo['sdk_params']);
            FileHelper.writeToFile("$k-stream.json", streamData, true);
            FileHelper.writeToFile("$k-sdk.json", urlInfo['sdk_params'], true);

            final int vBitrate = int.parse(sdkParams['vbitrate'].toString());
            final String resolution = sdkParams['resolution'];

            if (vBitrate != 0 && resolution.isNotEmpty) {
              try {
                videos.add(
                  Source(
                    key: key,
                    url: urlInfo["flv"],
                    type: SourceType.flv,
                    quality: qs.firstWhere((q) => q.key == key).copyWith(
                          resolution: sdkParams["resolution"],
                        ),
                    categroy: Categroy.living,
                    order: vBitrate,
                  ),
                );
              } catch (e) {
                logger.d("${platform.name} -- $e");
              }
            }
          }
        },
      );

      if (videos.isNotEmpty) {
        videos.sort((a, b) => b.order.compareTo(a.order));
      }
      var streamInfo = Media(
        categroy: Categroy.living,
        id: liveRoom['streamId'],
        platform: platform.simple(),
        title: liveRoom['title'],
        videos: videos,
        cover: liveRoom['coverUrl'],
        author: Author(
          name: user['nickname'],
          avatar: user['avatarThumb'],
          id: user['secUid'],
          link: '',
        ),
        audio: audio,
        status: true,
      );
      return streamInfo;
    }
    return null;
  }

  Future<Media?> extractData(String htmlStr) async {
    if (!htmlStr.contains('UNEXPECTED_EOF_WHILE_READING')) {
      // try {
      String jsonStr = RegExp(
              r'<script id="SIGI_STATE" type="application/json">(.*?)</script>',
              dotAll: true)
          .firstMatch(htmlStr)!
          .group(1)!;

      FileHelper.writeToFile("$k.json", jsonStr, true);
      return processLiveRoom(jsonDecode(jsonStr));
      // } catch (e) {
      //   throw "请检查你的网络是否可以正常访问TikTok网站 $e";
      // }
    }
    return null;
  }
}
