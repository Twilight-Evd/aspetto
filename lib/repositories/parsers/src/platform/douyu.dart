import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/extension.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter_js/flutter_js.dart';

class DouyuParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: '斗鱼',
        link: 'https://www.douyu.com/',
        icon: 'douyu.jpg',
        domains: <String>[
          "www.douyu.com",
          "douyu.com",
        ],
      );

  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 11; SAMSUNG SM-G973U) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/14.2 Chrome/87.0.4280.141 Mobile Safari/537.36',
    'Referer':
        'https://m.douyu.com/3125893?rid=3125893&dyshid=0-96003918aa5365bc6dcb4933000316p1&dyshci=181',
    'Cookie':
        'dy_did=413b835d2ae00270f0c69f6400031601; acf_did=413b835d2ae00270f0c69f6400031601; Hm_lvt_e99aee90ec1b2106afe7ec3b199020a7=1692068308,1694003758; m_did=96003918aa5365bc6dcb4933000316p1; dy_teen_mode=%7B%22uid%22%3A%22472647365%22%2C%22status%22%3A0%2C%22birthday%22%3A%22%22%2C%22password%22%3A%22%22%7D; PHPSESSID=td59qi2fu2gepngb8mlehbeme3; acf_auth=94fc9s%2FeNj%2BKlpU%2Br8tZC3Jo9sZ0wz9ClcHQ1akL2Nhb6ZyCmfjVWSlR3LFFPuePWHRAMo0dt9vPSCoezkFPOeNy4mYcdVOM1a8CbW0ZAee4ipyNB%2Bflr58; dy_auth=bec5yzM8bUFYe%2FnVAjmUAljyrsX%2FcwRW%2FyMHaoArYb5qi8FS9tWR%2B96iCzSnmAryLOjB3Qbeu%2BBD42clnI7CR9vNAo9mva5HyyL41HGsbksx1tEYFOEwxSI; wan_auth37wan=5fd69ed5b27fGM%2FGoswWwDo%2BL%2FRMtnEa4Ix9a%2FsH26qF0sR4iddKMqfnPIhgfHZUqkAk%2FA1d8TX%2B6F7SNp7l6buIxAVf3t9YxmSso8bvHY0%2Fa6RUiv8; acf_uid=472647365; acf_username=472647365; acf_nickname=%E7%94%A8%E6%88%B776576662; acf_own_room=0; acf_groupid=1; acf_phonestatus=1; acf_avatar=https%3A%2F%2Fapic.douyucdn.cn%2Fupload%2Favatar%2Fdefault%2F24_; acf_ct=0; acf_ltkid=25305099; acf_biz=1; acf_stk=90754f8ed18f0c24; Hm_lpvt_e99aee90ec1b2106afe7ec3b199020a7=1694003778'
  };
  late Dio dio;
  late String k;
  DouyuParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }
  RegExp regExpRid = RegExp(r'rid=(.*?)(?=&|$)');

  @override
  Future<Media?> streaming(String shareUrl) async {
    RegExpMatch? matchRid = regExpRid.firstMatch(shareUrl);
    String rid;
    if (matchRid != null) {
      rid = matchRid.group(1)!;
    } else {
      RegExp regExpDouyu = RegExp(r'douyu.com/(.*?)(?=\?|$)');
      rid = regExpDouyu.firstMatch(shareUrl)!.group(1)!;
      // var response = await dio.get('https://m.douyu.com/$rid');
      // RegExp regExpJson = RegExp(
      //     r'<script id="vike_pageContext" type="application/json">(.*?)</script>');
      // RegExpMatch? matchJson = regExpJson.firstMatch(response.data);
      // if (matchJson != null) {
      //   String jsonStr = matchJson.group(1)!;
      //   var jsonData = jsonDecode(jsonStr);
      //   rid = jsonData['pageProps']['room']['roomInfo']['roomInfo']['rid']
      //       .toString();
      // }
    }

    k = "${platform.name}-${Utils.strToMd5(rid)}";
    if (await FileHelper.fileExist("$k.json", true)) {
      var data = await FileHelper.readFromFile("$k.json");
      return extractData(jsonDecode(data));
    } else {
      Map<String, dynamic> newHeader = headers;
      newHeader['User-Agent'] =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0';
      final response = await dio.get(
        'https://www.douyu.com/betard/$rid',
        options: Options(headers: newHeader),
      );
      if (response.statusCode == 200) {
        FileHelper.writeToFile("$k.json", jsonEncode(response.data), true);
        if (response.data is String) {
          return null;
        }
        return extractData(response.data);
      } else {
        logger.d('Failed to load data from ');
      }
    }
    return null;
  }

  Future<Media?> extractData(Map<String, dynamic> jsonData) async {
    final roomData = jsonData.jsonPathValue("room");
    if (roomData['videoLoop'] == 0 && roomData['show_status'] == 1) {
      var streamInfo = Media(
        categroy: Categroy.living,
        id: roomData['room_id'].toString(),
        platform: platform.simple(),
        title: roomData['room_name'],
        videos: filledSource(Categroy.living),
        cover: roomData["room_pic"],
        author: Author(
          name: roomData['nickname'],
          avatar: roomData['owner_avatar'],
          id: roomData['owner_uid'].toString(),
          link: '',
        ),
        status: true,
      );
      return streamInfo;
    }
    return null;
  }

  @override
  Future<Source?> chooseQuality(Media m, Quality quality) async {
    String did = '10000000000000000000000000003306';
    Map<String, String> paramsLst = await getTokenJS(m.id, did);
    var newHeaders = {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 11; SAMSUNG SM-G973U) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/14.2 Chrome/87.0.4280.141 Mobile Safari/537.36',
      'Referer':
          'https://m.douyu.com/3125893?rid=3125893&dyshid=0-96003918aa5365bc6dcb4933000316p1&dyshci=181',
      'Cookie':
          'dy_did=413b835d2ae00270f0c69f6400031601; acf_did=413b835d2ae00270f0c69f6400031601; Hm_lvt_e99aee90ec1b2106afe7ec3b199020a7=1692068308,1694003758; m_did=96003918aa5365bc6dcb4933000316p1; dy_teen_mode=%7B%22uid%22%3A%22472647365%22%2C%22status%22%3A0%2C%22birthday%22%3A%22%22%2C%22password%22%3A%22%22%7D; PHPSESSID=td59qi2fu2gepngb8mlehbeme3; acf_auth=94fc9s%2FeNj%2BKlpU%2Br8tZC3Jo9sZ0wz9ClcHQ1akL2Nhb6ZyCmfjVWSlR3LFFPuePWHRAMo0dt9vPSCoezkFPOeNy4mYcdVOM1a8CbW0ZAee4ipyNB%2Bflr58; dy_auth=bec5yzM8bUFYe%2FnVAjmUAljyrsX%2FcwRW%2FyMHaoArYb5qi8FS9tWR%2B96iCzSnmAryLOjB3Qbeu%2BBD42clnI7CR9vNAo9mva5HyyL41HGsbksx1tEYFOEwxSI; wan_auth37wan=5fd69ed5b27fGM%2FGoswWwDo%2BL%2FRMtnEa4Ix9a%2FsH26qF0sR4iddKMqfnPIhgfHZUqkAk%2FA1d8TX%2B6F7SNp7l6buIxAVf3t9YxmSso8bvHY0%2Fa6RUiv8; acf_uid=472647365; acf_username=472647365; acf_nickname=%E7%94%A8%E6%88%B776576662; acf_own_room=0; acf_groupid=1; acf_phonestatus=1; acf_avatar=https%3A%2F%2Fapic.douyucdn.cn%2Fupload%2Favatar%2Fdefault%2F24_; acf_ct=0; acf_ltkid=25305099; acf_biz=1; acf_stk=90754f8ed18f0c24; Hm_lpvt_e99aee90ec1b2106afe7ec3b199020a7=1694003778'
    };

    paramsLst.addAll({
      'ver': '22011191',
      'rid': m.id,
      'rate': quality.key,
    });

    final response = await dio.post(
      "https://www.douyu.com/lapi/live/getH5Play/${m.id}",
      data: Utils.encodeData(paramsLst),
      options: Options(
        headers: newHeaders,
        contentType: "application/x-www-form-urlencoded",
      ),
    );
    if (response.data["msg"] == "ok" && response.data["data"] != null) {
      final jsonData = response.data["data"];
      final rate = jsonData["rate"].toString();
      if (quality.key != rate) {
        quality = getQualityByKey(rate) ?? quality;
      }
      return Source(
        key: quality.key,
        quality: quality,
        categroy: Categroy.living,
        type: SourceType.flv,
        url: jsonData["rtmp_url"] + "/" + jsonData["rtmp_live"],
      );
    }
    return null;
  }

  Future<Map<String, String>> getTokenJS(
    String rid,
    String did,
  ) async {
    final response = await dio.get('https://www.douyu.com/$rid');
    final htmlStr = response.data;
    final funcMatch =
        RegExp(r'(vdwdae325w_64we[\s\S]*function ub98484234[\s\S]*?)function')
            .firstMatch(htmlStr);
    if (funcMatch == null) {
      throw Exception('Function code not found');
    }
    String funcUb9 =
        funcMatch.group(1)!.replaceAll(RegExp(r'eval.*?;'), 'strc;');
    final JavascriptRuntime javascriptRuntime =
        getJavascriptRuntime(forceJavascriptCoreOnAndroid: false);
    await javascriptRuntime.evaluateAsync(
      funcUb9,
    );
    JsEvalResult jsResult2 =
        await javascriptRuntime.evaluateAsync("ub98484234()");
    final res = jsResult2.stringResult;

    String t10 = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final vMatch = RegExp(r'v=(\d+)').firstMatch(res);
    if (vMatch == null) {
      throw Exception('Value v not found');
    }
    String v = vMatch.group(1)!;
    final rb = Utils.strToMd5(rid + did + t10 + v);
    String funcSign = res.replaceAll(RegExp(r'return rt;}\);?'), 'return rt;}');
    funcSign = funcSign
        .replaceAll('(function (', 'function sign(')
        .replaceAll('CryptoJS.MD5(cb).toString()', '"$rb"');

    JsEvalResult jsResult4 = await javascriptRuntime.evaluateAsync('''
      $funcSign
      sign('$rid','$did','$t10');
      ''');
    return Uri.splitQueryString(jsResult4.stringResult);
  }

  @override
  List<Quality> supportQualities() {
    return [
      Quality(name: "原画", key: "0"),
      Quality(name: "蓝光", key: "4"),
      Quality(name: "超清", key: "3"),
      Quality(name: "高清", key: "2"),
      Quality(name: "标清", key: "1"),
      // Quality(name: "流畅", key: "1"),
    ];
  }
}
