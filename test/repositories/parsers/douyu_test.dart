import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/platform/douyu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// class MockDio extends Mock implements Dio {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('DouyuParser', () {
    late DouyuParser parser;
    // late MockDio mockDio;

    setUp(() {
      // mockDio = MockDio();
      parser = DouyuParser();
      // parser.dio = mockDio;
    });

    test('streaming 方法成功解析直播信息', () async {
      // 模拟成功的HTTP响应
      // when(mockDio.get()).thenAnswer((_) async => Response(
      //       data: '{"state": {"roomStore": {"roomInfo": {"room": {}}}}}',
      //       statusCode: 200,
      //       requestOptions: RequestOptions(path: ''),
      //     ));

      // final a = Uri.splitQueryString(
      //     "v=220120241116&did=10000000000000000000000000003306&tt=1731756566&sign=7656e104e22c540589abafd6d188a1e3");
      // logger.d(a);

      // exit(0);

      final result = await parser.streaming(
          'https://www.douyu.com/topic/LOLLEGENDS2?rid=252140&dyshid=0-17be86f14a4b295df46641bf00011701');

      // final source =
      // await parser.chooseQuality(result!, parser.getQualityByKey("0"));
      // logger.d(source?.toJson());

      expect(result, isA<Media>());
      // expect(result?.platform, equals('tiktok'));
      // 添加更多具体的断言来验证解析结果
    });

    // test('streaming 方法处理HTTP错误', () async {
    //   // 模拟HTTP错误
    //   // when(mockDio.get(any)).thenThrow(DioError(
    //   //   requestOptions: RequestOptions(path: ''),
    //   //   response: Response(
    //   //     statusCode: 404,
    //   //     requestOptions: RequestOptions(path: ''),
    //   //   ),
    //   // ));

    //   expect(() => parser.streaming('https://live.Tiktok.com/737508776356'),
    //       throwsA(isA<Exception>()));
    // });

    test('parseResult 方法正确解析HTML文档', () async {
      // var mockHtml = await FileHelper.readFromFile(
      //     "./0072c500-9abe-11ef-890f-05de2af3d358.html");

      // final document = htmlParser.parseFragment(mockHtml);
      // // final result = await parser.parseResult(document.outerHtml);

      // final result = await parser.extractData(document.outerHtml);

      // logger.d(result);
      // var f = Utils.generateRandomCode(5);
      // await FileHelper.writeToFile("$f.json", jsonEncode(result));
      // logger.d(f);

      // logger.d(result);
      // expect(result, isA<Media>());
      // expect(result?.id, equals('123456'));
      // expect(result?.title, equals('测试直播'));
      // expect(result?.platform, equals('抖音'));
      // 添加更多断言来验证解析结果的其他字段
    });
  });
}
