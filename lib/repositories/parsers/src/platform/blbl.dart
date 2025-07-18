import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/extension.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/util.dart';
import 'package:dio/dio.dart';

class BlblParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: 'B站',
        link: 'https://www.bilibili.com/',
        icon: 'blbl.png',
        domains: <String>[
          "live.bilibili.com",
          "bilibili.com",
        ],
      );

  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language':
        'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
  };
  late Dio dio;
  late String k;
  BlblParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }

  @override
  Future<Media?> streaming(String shareUrl) async {
    try {
      Uri u = Uri.parse(shareUrl);
      var roomId = u.pathSegments.last;

      k = "${platform.name}-${Utils.strToMd5(roomId)}";
      if (await FileHelper.fileExist("$k.json", true)) {
        var data = await FileHelper.readFromFile("$k.json");
        return extractData(jsonDecode(data));
      } else {
        var response = await dio.get(
          'https://api.live.bilibili.com/room/v1/Room/room_init?id=$roomId',
        );
        Map<String, dynamic> jsonData = response.data;
        logger.d(jsonData);
        var uid = jsonData.jsonPathValue("data.uid").toString();
        var response2 = await dio.get(
            'https://api.live.bilibili.com/live_user/v1/Master/info?uid=$uid');
        FileHelper.writeToFile("$k.json", jsonEncode(response2.data), true);

        return extractData(response2.data);
      }
    } catch (e) {
      throw Exception('流媒体请求出错: $e');
    }
  }

  Future<Media?> extractData(Map<String, dynamic> jsonData) async {
    Map<String, dynamic> author = jsonData.jsonPathValue("data.info");
    var streamInfo = Media(
      categroy: Categroy.living,
      id: jsonData.jsonPathValue("data.room_id").toString(),
      platform: platform.simple(),
      title: author.jsonPathValue('uname'),
      cover: author.jsonPathValue('face'),
      videos: filledSource(Categroy.living),
      author: Author(
        name: author.jsonPathValue('uname'),
        avatar: author.jsonPathValue('face'),
        id: author.jsonPathValue('uid').toString(),
        link: '',
      ),
      status: true,
    );
    return streamInfo;
    // }
    // return null;
  }

  Future<Source?> getBilibiliStreamData(
    String roomId, {
    String qn = '10000',
    String platform = 'web',
  }) async {
    // 构造请求头
    Map<String, String> headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0',
      'Accept-Language':
          'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
      'origin': 'https://live.bilibili.com',
      'referer': 'https://live.bilibili.com/26066074',
    };

    // 构造请求参数
    var params = {
      'cid': roomId,
      'qn': qn,
      'platform': platform,
    };
    final playApi =
        Uri.https('api.live.bilibili.com', '/room/v1/Room/playUrl', params);

    // 发送请求并解析响应
    var response =
        await dio.get(playApi.toString(), options: Options(headers: headers));

    Map<String, dynamic> jsonData = response.data;
    logger.d(jsonData);

    final qualities = supportQualities();

    if (jsonData.jsonPathValue<int>('code') == 0) {
      final durls = jsonData.jsonPathValue<List>('data.durl');
      if (durls != null) {
        final key = jsonData.jsonPathValue("data.current_qn").toString();
        return Source(
          key: key,
          url: durls.first["url"],
          type: SourceType.flv,
          quality: qualities.firstWhere((q) => q.key == key,
              orElse: () => qualities.first),
          categroy: Categroy.living,
        );
      }
      return null;
    } else {
      // 第二种请求方式
      params = {
        'room_id': roomId,
        'protocol': '0,1',
        'format': '0,1,2',
        'codec': '0,1,2',
        'qn': qn,
        'platform': 'web',
        'ptype': '8',
        'dolby': '5',
        'panorama': '1',
        'hdr_type': '0,1',
      };
      var api = Uri.https('api.live.bilibili.com',
          '/xlive/web-room/v2/index/getRoomPlayInfo', params);

      response =
          await dio.get(api.toString(), options: Options(headers: headers));

      Map<String, dynamic> jsonData = response.data;

      logger.d(jsonData);
      if (jsonData.jsonPathValue("data.live_status") == 0) {
        logger.d('主播未开播');
        return null;
      }

      final playurlInfo =
          jsonData.jsonPathValue<Map<String, dynamic>>('data.playurl_info');
      final formatList = playurlInfo.jsonPathValue<List>('playurl.stream');

      final flv = formatList?.firstWhere(
        (f) => f["protocol_name"] == "http_stream",
        orElse: () => formatList.first,
      );
      final streamDataList = flv["format"].first['codec'];
      // 排序并选择视频质量
      // streamDataList.sort((a, b) => b['current_qn'].compareTo(a['current_qn']));
      final qnCount = streamDataList.length;
      var selectStreamIndex = qualities.indexWhere((q) => qn == q.key);
      selectStreamIndex = selectStreamIndex == -1 ? 0 : selectStreamIndex;
      selectStreamIndex =
          selectStreamIndex < qnCount ? selectStreamIndex : qnCount - 1;

      final streamData = streamDataList[selectStreamIndex];
      final baseUrl = streamData['base_url'];
      final info = streamData["url_info"].first;

      return Source(
        key: qualities[selectStreamIndex].key,
        url: '{$info["host"]}$baseUrl${info["extra"]}',
        type: SourceType.flv,
        quality: supportQualities().elementAt(selectStreamIndex),
        categroy: Categroy.living,
      );
    }
  }

  @override
  Future<Source?> chooseQuality(Media m, Quality quality) async {
    return await getBilibiliStreamData(m.id, qn: quality.key);
  }

  @override
  List<Quality> supportQualities() => [
        Quality(name: "原画", key: "10000"),
        Quality(name: "蓝光", key: "400"),
        Quality(name: "超清", key: "250"),
        Quality(name: "高清", key: "150"),
        Quality(name: "标清", key: "80"),
        Quality(name: "流畅", key: "80"),
      ];
}
