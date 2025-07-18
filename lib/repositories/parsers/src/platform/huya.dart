import 'dart:convert';
import 'dart:math';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;

class HuyaParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: '虎牙',
        link: 'https://www.huya.com/',
        icon: 'huya.png',
        domains: <String>[
          "www.huya.com",
          "huya.com",
        ],
      );

  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language':
        'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
    'Cookie':
        'huya_ua=webh5&0.1.0&websocket; game_did=zXyXVqV1NF4ZeNWg7QaOFbpIEWqcsrxkoVy; alphaValue=0.80; isInLiveRoom=; guid=0a7df378828609654d01a205a305fb52; __yamid_tt1=0.8936157401010706; __yamid_new=CA715E8BC9400001E5A313E028F618DE; udb_guiddata=4657813d32ce43d381ea8ff8d416a3c2; udb_deviceid=w_756598227007868928; sdid=0UnHUgv0_qmfD4KAKlwzhqQB32nywGZJYLZl_9RLv0Lbi5CGYYNiBGLrvNZVszz4FEo_unffNsxk9BdvXKO_PkvC5cOwCJ13goOiNYGClLirWVkn9LtfFJw_Qo4kgKr8OZHDqNnuwg612sGyflFn1draukOt03gk2m3pwGbiKsB143MJhMxcI458jIjiX0MYq; Hm_lvt_51700b6c722f5bb4cf39906a596ea41f=1708583696; SoundValue=0.50; sdidtest=0UnHUgv0_qmfD4KAKlwzhqQB32nywGZJYLZl_9RLv0Lbi5CGYYNiBGLrvNZVszz4FEo_unffNsxk9BdvXKO_PkvC5cOwCJ13goOiNYGClLirWVkn9LtfFJw_Qo4kgKr8OZHDqNnuwg612sGyflFn1draukOt03gk2m3pwGbiKsB143MJhMxcI458jIjiX0MYq; sdidshorttest=test; __yasmid=0.8936157401010706; _yasids=__rootsid^%^3DCAA3838C53600001F4EE863017406250; huyawap_rep_cnt=4; udb_passdata=3; huya_web_rep_cnt=89; huya_flash_rep_cnt=20; Hm_lpvt_51700b6c722f5bb4cf39906a596ea41f=1709548534; _rep_cnt=3; PHPSESSID=r0klm0vccf08q1das65bnd8co1; guid=0a7df378828609654d01a205a305fb52; huya_hd_rep_cnt=8',
  };
  late Dio dio;
  late String k;

  HuyaParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }

  @override
  Future<Media?> streaming(String shareUrl) async {
    try {
      k = "${platform.name}-${Utils.strToMd5(shareUrl)}";
      if (await FileHelper.fileExist("$k.html", true)) {
        var data = await FileHelper.readFromFile("$k.html");
        var document = htmlParser.parseFragment(data);
        return extractData(document.outerHtml);
      }
      var response = await dio.get(shareUrl);
      if (response.statusCode == 200) {
        FileHelper.writeToFile("$k.html", response.data.toString(), true);
        var document = htmlParser.parseFragment(response.data.toString());
        return extractData(document.outerHtml);
      } else {
        throw Exception('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('流媒体请求出错: $e');
    }
  }

  Future<Media?> extractData(String htmlStr) async {
    // 添加提取 stream 数据的功能
    final RegExp streamPattern =
        RegExp(r'stream: (\{"data".*?),"iWebDefaultBitRate"');
    final Match? streamMatch = streamPattern.firstMatch(htmlStr);
    if (streamMatch != null) {
      final String jsonStr = '${streamMatch.group(1)!}}';
      final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
      final data = jsonData["data"].first;
      final gameLiveInfo = data["gameLiveInfo"];
      final streamInfoList = data["gameStreamInfoList"] as List;
      final qualityList = jsonData["vMultiStreamInfo"] as List;

      List<Source> videos = [];
      var selectCdn = streamInfoList.first;
      videos = qualityList.map((q) {
        String url = getStreamUrl(selectCdn, q["iBitRate"].toString());
        return Source(
          key: q["iBitRate"].toString(),
          url: url,
          type: SourceType.flv,
          quality: Quality(
              name: q["sDisplayName"],
              key: q["iBitRate"].toString(),
              resolution: ""),
          categroy: Categroy.living,
        );
      }).toList();

      var streamInfo = Media(
        categroy: Categroy.living,
        id: gameLiveInfo['liveId'],
        platform: platform.simple(),
        title: gameLiveInfo['introduction'],
        cover: gameLiveInfo['screenshot'],
        videos: videos,
        author: Author(
          name: gameLiveInfo['nick'],
          avatar: gameLiveInfo['avatar180'],
          id: gameLiveInfo['uid'].toString(),
          link: '',
        ),
        status: true,
      );
      logger.d(streamInfo.toJson());
      return streamInfo;
    }

    return null;
  }

  String getStreamUrl(Map selectCdn, String iBitRate) {
    var flvUrl = selectCdn['sFlvUrl'];
    final streamName = selectCdn['sStreamName'];
    final flvUrlSuffix = selectCdn['sFlvUrlSuffix'];
    // final hlsUrl = selectCdn['sHlsUrl'];
    // final hlsUrlSuffix = selectCdn['sHlsUrlSuffix'];
    final flvAntiCode = selectCdn['sFlvAntiCode'];
    final newAntiCode = getAntiCode(flvAntiCode, streamName);

    flvUrl = '$flvUrl/$streamName.$flvUrlSuffix?$newAntiCode&ratio=$iBitRate';
    // hlsUrl = '$hlsUrl/$streamName.$hlsUrlSuffix?$newAntiCode&ratio=$iBitRate';

    return flvUrl; //{"flv": flvUrl, "hls": hlsUrl};
  }

  String getAntiCode(String oldAntiCode, String streamName) {
    // js地址：https://hd.huya.com/cdn_libs/mobile/hysdk-m-202402211431.js
    int paramsT = 100;
    int sdkVersion = 2403051612;
    int t13 = (DateTime.now().millisecondsSinceEpoch); // 当前时间戳（毫秒）
    int sdkSid = t13;
    int initUuid = (t13 % pow(10, 10).toInt() * 1000 +
            (1000 * Random().nextDouble()).toInt()) %
        4294967295;
    int part1 = Random().nextInt(1000000); // Range: 0 to 999,999
    int part2 = Random().nextInt(1000000); // Range: 0 to 999,999
    int uid = 1400000000000 + part1 * 1000000 + part2;
    int seqId = uid + sdkSid; // seqId参数
    int targetUnixTime = (t13 + 110624) ~/ 1000;
    String wsTime = targetUnixTime.toRadixString(16).toLowerCase();

    final urlQuery = Uri.splitQueryString(oldAntiCode);
    String fm = Uri.decodeComponent(urlQuery['fm'] ?? '');
    List<int> decodedBytes = base64Decode(fm);
    String decodedString = utf8.decode(decodedBytes);
    String wsSecretPf = decodedString.split('_')[0];
    String wsSecretHash =
        Utils.strToMd5('$seqId|${urlQuery["ctype"]}|$paramsT');
    String wsSecret =
        '${wsSecretPf}_${uid}_${streamName}_${wsSecretHash}_$wsTime';
    String wsSecretMd5 = Utils.strToMd5(wsSecret);
    String antiCode =
        'wsSecret=$wsSecretMd5&wsTime=$wsTime&seqid=$seqId&ctype=${urlQuery["ctype"]}&ver=1'
        '&fs=${urlQuery["fs"]}&uuid=$initUuid&u=$uid&t=$paramsT&sv=$sdkVersion'
        '&sdk_sid=$sdkSid&codec=264';
    return antiCode;
  }
}
