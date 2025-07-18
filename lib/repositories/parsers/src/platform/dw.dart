import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;

class DwParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: '测试平台',
        link: 'https://dw.com',
        icon: 'douyin.png',
        domains: <String>[
          "dw.com",
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
  DwParser() : super() {
    dio = Dio();
    dio.options.headers = {
      'User-Agent': headers["User-Agent"],
      // 'Cookie': cookie,
    };
  }

  @override
  Future<Media?> streaming(String shareUrl) async {
    k = Utils.strToMd5(shareUrl);
    if (await FileHelper.fileExist("$k.html", true)) {
      var data = await FileHelper.readFromFile("$k.html");
      var document = htmlParser.parseFragment(data);
      return extractData(document.outerHtml);
    }
    return Media(
      categroy: Categroy.video,
      id: "11",
      platform: platform.simple(),
      title: "测试下载使用的。。。。",
      videos: [
        Source(
            key: "a",
            url: "https://evermeet.cx/ffmpeg/ffmpeg-7.1.zip",
            type: SourceType.zip,
            quality: Quality(name: "zip", key: "a", resolution: ""),
            categroy: Categroy.video)
      ],
      cover:
          "https://i.pinimg.com/564x/7c/4e/4e/7c4e4ea6a98db9539598bac221732d45.jpg",
      author: Author(
        id: "1",
        name: "测试作者",
        avatar: "https://github.com/images/modules/search/mona-love.png",
        link: "",
      ),
      status: false,
    );
  }

  Future<Media?> extractData(String htmlStr) async {
    return null;
  }
}
