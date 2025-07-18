import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/file.dart';
import 'package:dio/dio.dart';

class HuajiaoParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: '花椒',
        link: 'https://www.huajiao.com/',
        icon: 'huajiao.png',
        domains: <String>[
          "www.huajiao.com",
          "huajiao.com",
        ],
      );

  var headers = {
    'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'referer': 'https://www.huajiao.com/',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0',
  };
  late Dio dio;
  late String k;
  HuajiaoParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }
  @override
  Future<Media?> streaming(String shareUrl) async {
    // 调用 `getHuajiaoUserInfo` 函数以获取用户信息
    final userInfo = await getHuajiaoUserInfo(shareUrl);
    if (userInfo != null) {
      var author = userInfo['author'] as Author;
      final sn = userInfo['sn'];
      final uid = author.id;
      final liveId = userInfo['live_id'];

      // 设置请求参数
      final params = {
        "time": DateTime.now().millisecondsSinceEpoch.toString(),
        "version": "1.0.0",
        "sn": sn,
        "uid": uid,
        "liveid": liveId,
        "encode": "h265" // 可选 h264
      };
      // 拼接 API 请求地址
      final apiUrl = Uri.parse('https://live.huajiao.com/live/substream')
          .replace(queryParameters: params);
      try {
        var response = await dio.get(apiUrl.toString());
        if (response.statusCode == 200) {
          final jsonData = response.data;
          var streamInfo = Media(
            categroy: Categroy.living,
            id: liveId,
            platform: platform.simple(),
            title: author.name,
            videos: [
              Source(
                key: "0",
                url: jsonData['data']['h264_url'],
                type: SourceType.flv,
                quality: Quality(name: "原画", key: "0", resolution: ""),
                categroy: Categroy.living,
              )
            ],
            cover: author.avatar,
            author: author,
            status: true,
          );
          return streamInfo;
        } else {
          throw Exception('Failed to fetch stream URL');
        }
      } catch (e) {
        throw Exception('流媒体请求出错: $e');
      }
    }
    return null;
  }

  Future<Media?> extractData(String htmlStr) async {
    return null;
  }

  Future<Map<String, dynamic>?> getHuajiaoUserInfo(String url,
      {String? cookies, String? proxyAddr}) async {
    // 设置请求头

    // 判断是否包含 'user' 以获取 uid
    if (url.contains('user')) {
      // final headers = {
      //   'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
      //   'referer': 'https://www.huajiao.com/',
      //   'user-agent':
      //       'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0',
      //   if (cookies != null) 'Cookie': cookies,
      // };

      return null;
      // final uid = url.split('?')[0].split('user/')[1];
      // final params = {
      //   'uid': uid,
      //   'fmt': 'json',
      //   '_': DateTime.now().millisecondsSinceEpoch.toString(),
      // };
      // // 构造 API URL
      // final api = Uri.https('webh.huajiao.com', '/User/getUserFeeds', params);
      // // 发送 API 请求
      // final jsonResponse =
      //     await dio.get(api.toString(), options: Options(headers: headers));
      // if (jsonResponse.statusCode != 200) {
      //   throw Exception("Failed to load JSON data");
      // }
      // final jsonData = json.decode(jsonResponse.data);
      // logger.d(jsonData);
      // final htmlResponse = await dio.get('https://www.huajiao.com/user/$uid',
      //     options: Options(headers: headers));
      // if (htmlResponse.statusCode != 200) {
      //   throw Exception("Failed to load HTML page");
      // }
      // final htmlStr = htmlResponse.data;
      // // 提取主播名
      // final anchorNameMatch =
      //     RegExp(r'<title>(.*?)的主页.*</title>').firstMatch(htmlStr);
      // final anchorName = anchorNameMatch?.group(1) ?? '未知主播';
      // // 检查直播状态
      // if (jsonData['data'] != null &&
      //     jsonData['data']['feeds'][0]['feed']['rtop'] != null) {
      //   logger.d(jsonData["data"]);
      //   final liveId = jsonData['data']['feeds'][0]['feed']['relateid'];
      //   final sn = jsonData['data']['feeds'][0]['feed']['sn'];

      //   return {
      //     'author': Author(
      //         id: jsonData['author']['uid'].toString(),
      //         name: jsonData['author']['nickname'],
      //         avatar: jsonData['author']['avatar'],
      //         link: ''),
      //     'sn': sn,
      //     'live_id': liveId,
      //   };

      //   // return {
      //   //   'anchor_name': anchorName,
      //   //   'live_info': [sn, uid, liveId],
      //   // };
      // } else {
      //   return {
      //     'anchor_name': anchorName,
      //     'live_info': null,
      //   };
      // }
    } else {
      return await getHuajiaoSn(url);
    }
  }

  Future<Map<String, dynamic>?> getHuajiaoSn(String url,
      {String? cookies, String? proxyAddr}) async {
    // 设置请求头
    final headers = {
      'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
      'referer': 'https://www.huajiao.com/',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0',
      if (cookies != null) 'Cookie': cookies,
    };
    // 提取 live_id
    final liveId = url.split('?')[0].split('/').last;
    final apiUrl = Uri.parse('https://www.huajiao.com/l/$liveId');
    try {
      // 发送请求获取页面内容
      final response =
          await dio.get(apiUrl.toString(), options: Options(headers: headers));
      if (response.statusCode != 200) {
        throw Exception("Failed to load live room page");
      }
      final htmlStr = response.data;
      FileHelper.writeToFile("ssss.html", htmlStr);
      // 使用正则表达式提取 JSON 数据
      final match = RegExp(r'var feed = (.*?});').firstMatch(htmlStr);
      if (match == null) {
        throw Exception("Failed to find JSON data in HTML");
      }
      final jsonStr = match.group(1);
      // 解析 JSON
      final jsonData = jsonDecode(jsonStr!);
      return {
        'author': Author(
            id: jsonData['author']['uid'].toString(),
            name: jsonData['author']['nickname'],
            avatar: jsonData['author']['avatar'],
            link: ''),
        'sn': jsonData['feed']['sn'],
        'live_id': liveId,
      };
    } catch (e) {
      print("获取直播间数据失败: $e");
      // 替换 URL 或记录错误
      return null;
    }
  }
}
