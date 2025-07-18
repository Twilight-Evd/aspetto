import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/log.dart';
import 'package:dio/dio.dart';

class InkeParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: '映客',
        link: 'https://www.inke.cn/',
        icon: 'inke.png',
        domains: <String>[
          "www.inke.cn",
          "inke.cn",
        ],
      );

  var headers = {
    'Referer': 'https://www.inke.cn/',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0',
  };
  late Dio dio;
  late String k;
  InkeParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }
  @override
  Future<Media?> streaming(String shareUrl) async {
    // try {

    final uri = Uri.parse(shareUrl);
    final uid = uri.queryParameters['uid'] ?? '';
    final liveId = uri.queryParameters['id'] ?? '';

    if (uid.isEmpty || liveId.isEmpty) {
      throw ArgumentError('URL中缺少必要的参数 (uid 或 id)');
    }
    final params = {
      'uid': uid,
      'id': liveId,
      '_t': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    final apiUrl =
        Uri.https('webapi.busi.inke.cn', '/web/live_share_pc', params);
    try {
      final response = await dio.get(apiUrl.toString());
      if (response.statusCode != 200) {
        throw Exception('请求失败，状态码: ${response.statusCode}');
      }
      final jsonData = json.decode(response.data);
      if (jsonData["message"] == "ok") {
        final data = jsonData["data"];
        final file = data["file"];
        final liveAddr = data["live_addr"] as List;
        logger.d(liveAddr);
        var streamInfo = Media(
          categroy: Categroy.living,
          id: data['liveid'],
          platform: platform.simple(),
          title: file['title'],
          videos: [
            Source(
              key: "0",
              url: liveAddr.first["stream_addr"],
              type: SourceType.flv,
              quality: Quality(name: "原画", key: "0", resolution: ""),
              categroy: Categroy.living,
            )
          ],
          cover: file['pic'],
          author: Author(
            name: data['live_name'],
            avatar: data['portrait'],
            id: data['live_uid'].toString(),
            link: '',
          ),
          status: true,
        );
        return streamInfo;
      }
    } catch (e) {
      throw Exception('流媒体请求出错: $e');
    }
    return null;
  }
}
