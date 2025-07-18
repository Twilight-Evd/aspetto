import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;

class YyParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: 'YY',
        link: 'https://www.yy.com/',
        icon: 'yy.png',
        domains: <String>[
          "www.yy.com",
          "yy.com",
        ],
      );

  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Referer': 'https://www.yy.com/',
    'Cookie':
        'hiido_ui=0.6187945792325629; hd_newui=0.752379514187306; hdjs_session_id=0.2599069743514597; hiido_ui=0.27021556643416655; Hm_lvt_c493393610cdccbddc1f124d567e36ab=1731244003; HMACCOUNT=1B1AC1EA505B9981; hdjs_session_time=1731244779719; Hm_lpvt_c493393610cdccbddc1f124d567e36ab=1731244781'
  };
  late Dio dio;
  late String k;
  YyParser() : super() {
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
    final authorId =
        RegExp(r'uid\s*:\s*"([^"]*)"').firstMatch(htmlStr)?.group(1);

    final authorName =
        RegExp(r'nick\s*:\s*"([^"]*)"').firstMatch(htmlStr)?.group(1);

    final logo = RegExp(r'logo\s*:\s*"([^"]*)"').firstMatch(htmlStr)?.group(1);

    final roomName = RegExp(r'roomName\s*:\s*decodeURIComponent\((.*?)\)')
        .firstMatch(htmlStr)
        ?.group(1);

    final cid = RegExp(r'sid : "(.*?)",\n\s+ssid', dotAll: true)
        .firstMatch(htmlStr)
        ?.group(1);

    String t10 = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    var data =
        '{"head":{"seq":1701869217590,"appidstr":"0","bidstr":"121","cidstr":"$cid","sidstr":"$cid","uid64":0,"client_type":108,"client_ver":"5.19.4","stream_sys_ver":1,"app":"yylive_web","playersdk_ver":"5.19.4","thundersdk_ver":"0","streamsdk_ver":"5.19.4"},"client_attribute":{"client":"web","model":"web1","cpu":"","graphics_card":"","os":"chrome","osversion":"130.0.0.0","vsdk_version":"","app_identify":"","app_version":"","business":"","width":"1920","height":"1080","scale":"","client_type":8,"h265":1},"avp_parameter":{"version":1,"client_type":8,"service_type":0,"imsi":0,"send_time":$t10,"line_seq":-1,"gear":4,"ssl":1,"stream_format":0}}';
    var dataBytes = utf8.encode(data);
    var url2 =
        'https://stream-manager.yy.com/v3/channel/streams?uid=0&cid=$cid&sid=$cid&appid=0&sequence=1701869217590&encode=json';
    // https: //stream-manager.yy.com/v3/channel/streams?uid=0&cid=54880976&sid=54880976&appid=0&sequence=1731244816749&encode=json
    var response = await dio.post(url2,
        data: dataBytes,
        options: Options(
          contentType: "application/x-www-form-urlencoded",
        ));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.data);
      if (jsonData["avp_info_res"] != null) {
        var streams = jsonData["channel_stream_info"]["streams"] as List;
        logger.d(streams);
        List<Quality> qs = [];
        for (var stream in streams) {
          if (stream["stream_key"] != null) {
            var streamJson = jsonDecode(stream["json"]);
            if (streamJson["gear_info"] != null) {
              qs.add(Quality(
                  name: streamJson["gear_info"]["name"],
                  key: stream["stream_key"],
                  resolution:
                      "${streamJson['width']}x${streamJson['height']}"));
            }
          }
        }
        // for (var stream in streams) {
        //   if (stream["stream_key"] != null) {
        //     var streamJson = jsonDecode(stream["json"]);
        //     if (streamJson["gear_info"] != null) {
        //       qs[stream["stream_key"]] = Quality(
        //           name: streamJson["gear_info"]["name"],
        //           key: stream["stream_key"],
        //           resolution: "${streamJson['width']}x${streamJson['height']}");
        //     }
        //   }
        // }
        var streamLineAddr =
            jsonData['avp_info_res']['stream_line_addr'] as Map;

        // Map<String, dynamic> flvs = {};
        List<Source> videos = [];
        streamLineAddr.forEach((k, addr) {
          final i = qs.indexWhere((q) => q.key == k);
          if (i != -1) {
            videos.add(
              Source(
                key: k,
                url: addr["cdn_info"]["url"],
                type: SourceType.flv,
                quality: qs.elementAt(i),
                categroy: Categroy.living,
              ),
            );
          }
        });
        var streamInfo = Media(
          categroy: Categroy.living,
          id: cid.toString(),
          platform: platform.simple(),
          title: Uri.decodeComponent(roomName.toString()),
          videos: videos,
          cover: logo.toString(),
          author: Author(
            name: authorName.toString(),
            avatar: logo.toString(),
            id: authorId.toString(),
            link: '',
          ),
          status: true,
        );
        return streamInfo;
      }
    } else {
      throw Exception('请求失败: ${response.statusCode}');
    }
    return null;
  }
}
