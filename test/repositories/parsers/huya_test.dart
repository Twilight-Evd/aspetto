import 'dart:convert';

import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/platform/huya.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/util.dart';
// class MockDio extends Mock implements Dio {}

void main() {
  group('HuyaParser', () {
    late HuyaParser parser;
    // late MockDio mockDio;

    setUp(() {
      // mockDio = MockDio();
      parser = HuyaParser();
      // parser.dio = mockDio;
    });

    test('streaming 方法成功解析直播信息', () async {
      // 模拟成功的HTTP响应
      // when(mockDio.get()).thenAnswer((_) async => Response(
      //       data: '{"state": {"roomStore": {"roomInfo": {"room": {}}}}}',
      //       statusCode: 200,
      //       requestOptions: RequestOptions(path: ''),
      //     ));

      // final urlQuery = Uri.parse(
      //         "http://sss.com/?wsSecret=9fd5ee3a18eca48b62248edbef540b8d&wsTime=672f9bf3&fm=RFdxOEJjSjNoNkRKdDZUWV8kMF8kMV8kMl8kMw%3D%3D&ctype=huya_live&fs=bgct")
      //     .queryParameters;

      final result = await parser.streaming('https://www.huya.com/fcsls');

      expect(result, isA<Media>());
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
      var mockHtml = await FileHelper.readFromFile(
          "./0072c500-9abe-11ef-890f-05de2af3d358.html");

      final document = htmlParser.parseFragment(mockHtml);
      // final result = await parser.parseResult(document.outerHtml);

      final result = await parser.extractData(document.outerHtml);

      logger.d(result);
      var f = Utils.generateRandomCode(5);
      await FileHelper.writeToFile("$f.json", jsonEncode(result));
      logger.d(f);

      // logger.d(result);
      // expect(result, isA<Media>());
      // expect(result?.id, equals('123456'));
      // expect(result?.title, equals('测试直播'));
      // expect(result?.platform, equals('抖音'));
      // 添加更多断言来验证解析结果的其他字段
    });
  });
}
