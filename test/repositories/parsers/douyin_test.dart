import 'package:bunny/models/common.dart';
import 'package:bunny/repositories/parsers/src/platform/douyin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';

void main() {
  group('DouyinParser', () {
    late DouyinParser parser;
    // late MockDio mockDio;

    setUp(() {
      // mockDio = MockDio();
      parser = DouyinParser();
      // parser.dio = mockDio;
    });

    // test('streaming 方法成功解析直播信息', () async {
    //   // 模拟成功的HTTP响应
    //   // when(mockDio.get()).thenAnswer((_) async => Response(
    //   //       data: '{"state": {"roomStore": {"roomInfo": {"room": {}}}}}',
    //   //       statusCode: 200,
    //   //       requestOptions: RequestOptions(path: ''),
    //   //     ));

    //   final result =
    //       await parser.streaming('https://live.douyin.com/95679413409');

    //   expect(result, isA<Media>());
    //   expect(result?.platform, equals('抖音'));
    //   // 添加更多具体的断言来验证解析结果
    // });

    test('streaming 方法处理HTTP错误', () async {
      // 模拟HTTP错误
      // when(mockDio.get(any)).thenThrow(DioError(
      //   requestOptions: RequestOptions(path: ''),
      //   response: Response(
      //     statusCode: 404,
      //     requestOptions: RequestOptions(path: ''),
      //   ),
      // ));

      expect(() => parser.streaming('https://live.douyin.com/148108118778'),
          throwsA(isA<Respones>()));
    });

    test('parseResult 方法正确解析HTML文档', () async {
      var htmlStr = await FileHelper.readFromFile("./douyin.html");

      // // final commonRegex =
      // //     RegExp(r'(\{\\"common\\":.*?)]\\n"]\)</script><div hidden');
      // // var matchJsonStr = commonRegex.firstMatch(htmlStr);
      // // logger.d(matchJsonStr);
      // // var jsonStr = matchJsonStr!.group(1);
      // var jsonStr = await FileHelper.readFromFile("./douyin.json");

      // String cleanedString = jsonStr
      //     .replaceAll(r'\"', '"')
      //     .replaceAll('u0026', '&')
      //     .replaceAll("\\&", "&")
      //     .replaceAll('\\\\"', '\\"')
      //     .replaceAll("null", "0");

      // FileHelper.writeToFile("./douyin3.json", cleanedString);
      // Map<String, dynamic> doc = jsonDecode(cleanedString);

      // final roomStore = doc.jsonPathValue("state.roomStore");
      // logger.d(roomStore);
      // // FileHelper.writeToFile("./douyin.json", jsonStr!);

      //   var mockHtml = await FileHelper.readFromFile("aaax.html");

      //   final document = htmlParser.parseFragment(mockHtml);
      //   // final result = await parser.parseResult(document.outerHtml);

      final result = await parser.extractData(htmlStr);

      //   logger.d(result);
      //   var f = Utils.generateRandomCode(5);
      //   await FileHelper.writeToFile("$f.json", jsonEncode(result));
      //   logger.d(f);

      logger.d(result!.toJson());
      // expect(result, isA<Media>());
      // expect(result?.id, equals('123456'));
      // expect(result?.title, equals('测试直播'));
      // expect(result?.platform, equals('抖音'));
      // 添加更多断言来验证解析结果的其他字段
    });
  });
}
