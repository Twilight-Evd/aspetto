import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/log.dart';
import 'package:dio/dio.dart';

class XhsParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: '小红书',
        link: 'https://www.xiaohongshu.com',
        icon: 'xhs.png',
        domains: <String>[
          "www.redelight.cn",
          "www.xiaohongshu.com",
          "xhslink.com"
        ],
      );

  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language':
        'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
    'Referer':
        'https://www.redelight.cn/hina/livestream/569077534207413574/1707413727088?share_source=&share_source_id=null&source=share_out_of_app&host_id=58bafe4282ec39085a56ece9&xhsshare=WeixinSession&appuid=5f3f478a00000000010005b3&apptime=1707413727',
  };

  late Dio dio;

  XhsParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }

  @override
  Future<Media?> streaming(String shareUrl) async {
    try {
      var response = await dio.get(
        shareUrl,
        options: Options(followRedirects: true, maxRedirects: 5, headers: {
          'User-Agent': headers["User-Agent"],
        }),
      );
      if (response.statusCode == 200) {
        logger.d(response.realUri);
        return extractData(response.realUri.pathSegments.last);
      } else {
        throw Exception('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('流媒体请求出错: $e');
    }
  }

  Future<Media?> extractData(String roomId) async {
    String appApi =
        'https://www.xiaohongshu.com/api/sns/red/live/app/v1/ecology/outside/share_info?room_id=$roomId';

    final dataResponse = await dio.get(appApi);
    if (dataResponse.statusCode == 200) {
      final jsonData = dataResponse.data;

      Map<String, dynamic> room = jsonData['data']['room'];
      Map<String, dynamic> hostInfo = jsonData['data']['host_info'];

      var streamInfo = Media(
        categroy: Categroy.living,
        id: room['room_id'],
        platform: platform.simple(),
        title: room['name'],
        videos: [
          Source(
            key: "0",
            url: "http://live.xhscdn.com/live/$roomId.flv",
            type: SourceType.flv,
            quality: Quality(name: "原画-线路1", key: "0", resolution: ""),
            categroy: Categroy.living,
          ),
          Source(
            key: "1",
            url: "http://live-play.xhscdn.com/live/$roomId.flv",
            type: SourceType.flv,
            quality: Quality(name: "原画-线路1", key: "1", resolution: ""),
            categroy: Categroy.living,
          )
        ],
        author: Author(
          name: hostInfo['nickname'],
          avatar: hostInfo['avatar'],
          id: room['host_id'],
          link: '',
        ),
        status: true,
      );
      return streamInfo;
    }
    return null;
  }
}
