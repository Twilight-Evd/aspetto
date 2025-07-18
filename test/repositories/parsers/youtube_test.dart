import 'dart:convert';
import 'dart:io';

import 'package:bunny/repositories/parsers/src/platform/youtube.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:sharebox/utils/file.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  group('YoutubeParser', () {
    late YoutubeParser parser;
    // late MockDio mockDio;

    setUp(() {
      // mockDio = MockDio();
      parser = YoutubeParser();
      // parser.dio = mockDio;
    });

    test('streaming 方法成功解析直播信息', () async {
      // 模拟成功的HTTP响应
      // when(mockDio.get()).thenAnswer((_) async => Response(
      //       data: '{"state": {"roomStore": {"roomInfo": {"room": {}}}}}',
      //       statusCode: 200,
      //       requestOptions: RequestOptions(path: ''),
      //     ));

      var dio = Dio(BaseOptions(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        },
        responseType:
            ResponseType.bytes, // Set to bytes to avoid decoding issues
      ));

      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));

      try {
        var response = await dio.get(
          'https://www.youtube.com/watch?v=EsGYCU9IMog',
          options: Options(
            responseType: ResponseType.bytes, // 获取原始字节数据
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
              // 'Accept-Encoding': 'gzip, deflate, br',
            },
          ),
        );

        var bytes = response.data;
        var isGzip = bytes.isNotEmpty && bytes[0] == 0x1f && bytes[1] == 0x8b;
        if (isGzip) {
          // 解压 GZIP 内容
          var decodedBody = utf8.decode(GZipCodec().decode(bytes));
          print(decodedBody);
        } else {
          print(utf8.decode(bytes));
        }

        // // 手动解压 GZIP 数据

        // print(utf8.decode(response.data));

        // final decodedResponse = utf8.decode(GZipCodec().decode(response.data));

        // print(decodedResponse); // 输出解压后的 HTML 内容
      } catch (e) {
        print("Error: $e");
      }

      // final result =
      //     await parser.streaming('https://www.youtube.com/watch?v=EsGYCU9IMog');

      // expect(result, isA<Media>());
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
      var mockHtml = await FileHelper.readFromFile(
          "./Youtube-e8d4bee8e542046ae86dc49f0057e8a4-youtbe.html");

      RegExp regExp = RegExp(
        r'"channelAvatar"\s*:\s*{\s*"thumbnails"\s*:\s*\[\s*{"url"\s*:\s*"([^"]+)"}',
      );
      final matches = regExp.firstMatch(mockHtml);
      if (matches != null) {
        print(matches.group(1));
      }
      exit(0);

      final document = htmlParser.parseFragment(mockHtml);
      final scriptReg = RegExp(r'<script\b[^>]*>([\s\S]*?)<\/script>',
          multiLine: true, caseSensitive: false);
      final scriptTags = document.querySelectorAll('script');
      for (var script in scriptTags) {
        final scriptContent = script.text;

        if (scriptContent.contains('var ytInitialData')) {
          var s = scriptContent.replaceAll(scriptReg, "\$1");
          FileHelper.writeToFile("./-youtbe-x.json", s);
        }
      }
      // final result = await parser.parseResult(document.outerHtml);

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
