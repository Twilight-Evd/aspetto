import 'dart:convert';

import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/repositories/parsers/src/parser.dart';
import 'package:sharebox/utils/extension.dart';
import 'package:sharebox/utils/log.dart';
import 'package:dio/dio.dart';

class DouyinParser extends Parser {
  @override
  MediaPlatform get platform => MediaPlatform(
        name: '抖音',
        link: 'https://www.douyin.com',
        icon: 'douyin.png',
        domains: <String>[
          "live.douyin.com",
          "www.douyin.com",
          "v.douyin.com",
          "douyin.com"
        ],
        order: 100,
      );

  var headers = {
    'User-Agent':
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0",
    'Accept-Language':
        "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
    'Referer': "https://live.douyin.com/",
    'Cookie':
        "ttwid=1%7CB1qls3GdnZhUov9o2NxOMxxYS2ff6OSvEWbv0ytbES4%7C1680522049%7C280d802d6d478e3e78d0c807f7c487e7ffec0ae4e5fdd6a0fe74c3c6af149511; my_rd=1; passport_csrf_token=3ab34460fa656183fccfb904b16ff742; passport_csrf_token_default=3ab34460fa656183fccfb904b16ff742; d_ticket=9f562383ac0547d0b561904513229d76c9c21; n_mh=hvnJEQ4Q5eiH74-84kTFUyv4VK8xtSrpRZG1AhCeFNI; store-region=cn-fj; store-region-src=uid; LOGIN_STATUS=1; __security_server_data_status=1; FORCE_LOGIN=%7B%22videoConsumedRemainSeconds%22%3A180%7D; pwa2=%223%7C0%7C3%7C0%22; download_guide=%223%2F20230729%2F0%22; volume_info=%7B%22isUserMute%22%3Afalse%2C%22isMute%22%3Afalse%2C%22volume%22%3A0.6%7D; strategyABtestKey=%221690824679.923%22; stream_recommend_feed_params=%22%7B%5C%22cookie_enabled%5C%22%3Atrue%2C%5C%22screen_width%5C%22%3A1536%2C%5C%22screen_height%5C%22%3A864%2C%5C%22browser_online%5C%22%3Atrue%2C%5C%22cpu_core_num%5C%22%3A8%2C%5C%22device_memory%5C%22%3A8%2C%5C%22downlink%5C%22%3A10%2C%5C%22effective_type%5C%22%3A%5C%224g%5C%22%2C%5C%22round_trip_time%5C%22%3A150%7D%22; VIDEO_FILTER_MEMO_SELECT=%7B%22expireTime%22%3A1691443863751%2C%22type%22%3Anull%7D; home_can_add_dy_2_desktop=%221%22; __live_version__=%221.1.1.2169%22; device_web_cpu_core=8; device_web_memory_size=8; xgplayer_user_id=346045893336; csrf_session_id=2e00356b5cd8544d17a0e66484946f28; odin_tt=724eb4dd23bc6ffaed9a1571ac4c757ef597768a70c75fef695b95845b7ffcd8b1524278c2ac31c2587996d058e03414595f0a4e856c53bd0d5e5f56dc6d82e24004dc77773e6b83ced6f80f1bb70627; __ac_nonce=064caded4009deafd8b89; __ac_signature=_02B4Z6wo00f01HLUuwwAAIDBh6tRkVLvBQBy9L-AAHiHf7; ttcid=2e9619ebbb8449eaa3d5a42d8ce88ec835; webcast_leading_last_show_time=1691016922379; webcast_leading_total_show_times=1; webcast_local_quality=sd; live_can_add_dy_2_desktop=%221%22; msToken=1JDHnVPw_9yTvzIrwb7cQj8dCMNOoesXbA_IooV8cezcOdpe4pzusZE7NB7tZn9TBXPr0ylxmv-KMs5rqbNUBHP4P7VBFUu0ZAht_BEylqrLpzgt3y5ne_38hXDOX8o=; msToken=jV_yeN1IQKUd9PlNtpL7k5vthGKcHo0dEh_QPUQhr8G3cuYv-Jbb4NnIxGDmhVOkZOCSihNpA2kvYtHiTW25XNNX_yrsv5FN8O6zm3qmCIXcEe0LywLn7oBO2gITEeg=; tt_scid=mYfqpfbDjqXrIGJuQ7q-DlQJfUSG51qG.KUdzztuGP83OjuVLXnQHjsz-BRHRJu4e986",
  };

  late Dio dio;

  DouyinParser() : super() {
    dio = Dio();
    dio.options.headers = headers;
  }

  @override
  Future<Media?> streaming(String shareUrl) async {
    try {
      var response = await dio.get(shareUrl);
      if (response.statusCode == 200) {
        // // var document = htmlParser.parseFragment(response.data);
        // FileHelper.writeToFile("./douyin.html", response.data);
        return extractData(response.data);
      } else {
        throw Respones(400, "请求失败"); //'请求失败: ${response.statusCode}');
      }
    } catch (e) {
      logger.e("fetch err: $e");
      throw Respones(0, "请求失败");
      //Exception('流媒体请求出错: $e');
    }
  }

  final stateRegex = RegExp(r'(\{\\"state\\":.*?)]\\n"]\)');

  final commonRegex =
      RegExp(r'(\{\\"common\\":.*?)]\\n"]\)</script><div hidden');
  final roomStoreRegex =
      RegExp(r'"roomStore":(.*?),"linkmicStore"', dotAll: true);
  final nicknameRegex =
      RegExp(r'"nickname":"(.*?)","avatar_thumb', dotAll: true);
  final originMainRegex =
      RegExp(r'"origin":\{"main":(.*?),"dash"', dotAll: true);
  final jsonMatchRegex =
      RegExp(r'"(\{\\"common\\":.*?)"]\)</script><script nonce=');

  final qualityRegex = RegExp(r'_exp([a-z]+).*?\.[flv|m3u8]');

  Future<Media?> extractData(String htmlStr) async {
    // Match? matchJsonStr;
    // String? jsonStr;
    // String? roomStoreJson;

    Match? matchJsonStr = stateRegex.firstMatch(htmlStr);

    if (matchJsonStr != null) {
      var jsonStr = matchJsonStr.group(1);

      String cleanedString = jsonStr!
          .replaceAll(r'\"', '"')
          .replaceAll('u0026', '&')
          .replaceAll("\\&", "&")
          .replaceAll('\\\\"', '\\"')
          .replaceAll("null", "0");

      Map<String, dynamic> jsonData = jsonDecode(cleanedString);

      final roomStore =
          jsonData.jsonPathValue<Map<String, dynamic>>("state.roomStore");

      final streamStore = jsonData.jsonPathValue<Map<String, dynamic>>(
          "state.streamStore.streamData.H264_streamData");

      Map<String, dynamic> room;
      Map<String, dynamic> owner;
      if (roomStore != null) {
        room = roomStore.jsonPathValue("roomInfo.room");
        owner = room.jsonPathValue("owner");
      } else {
        return null;
      }
      if (streamStore != null) {
        final streamData = streamStore["stream"];
        final qualitiesData = streamStore["options"]["qualities"] as List;

        if (streamData != null) {
          List<Source>? videos = [];
          Source? audio;

          List<Quality> qs = qualitiesData
              .map((v) => Quality(
                    name: v["name"].toString(),
                    key: v["sdk_key"].toString(),
                    resolution: v["resolution"].toString(),
                    order: int.parse(v["level"].toString()),
                  ))
              .toList();
          streamData.forEach(
            (k, v) {
              if (k == "ao") {
                audio = Source(
                  key: k,
                  url: v["main"]["flv"].toString(),
                  type: SourceType.flv,
                  quality: Quality(name: "音频", key: k),
                  categroy: Categroy.audio,
                );
              } else {
                try {
                  Quality quality = qs.firstWhere((q) => q.key == k);
                  videos.add(
                    Source(
                      key: k,
                      url: v["main"]["flv"].toString(),
                      type: SourceType.flv,
                      quality: quality,
                      categroy: Categroy.living,
                      order: quality.order,
                    ),
                  );
                } catch (e) {
                  logger.d("no element $k");
                }
              }
            },
          );

          videos.sort((a, b) => b.order.compareTo(a.order));

          return Media(
            categroy: Categroy.living,
            id: room.jsonPathValue('id_str').toString(),
            platform: platform.simple(),
            title: room.jsonPathValue('title').toString(),
            videos: videos,
            audio: audio,
            cover: room.jsonPathValue('cover.url_list').first.toString(),
            author: Author(
              name: owner.jsonPathValue("nickname").toString(),
              avatar: owner
                  .jsonPathValue("avatar_thumb.url_list")
                  .first
                  .toString(), // owner['avatar_thumb']['url_list'][0],
              id: owner.jsonPathValue("id_str").toString(),
              link: '',
            ),
            status: true,
          );
        }
      }

      // var roomStore = JsonPath(r'$.state.roomStore').read(jsonData).single;
    }
    //else {
    return null;
    // matchJsonStr = commonRegex.firstMatch(htmlStr);
    // if (matchJsonStr != null) {
    //   jsonStr = matchJsonStr.group(1);
    // }
    // }

    // jsonDecode(jsonStr!);
    // FileHelper.writeToFile("./douyin.json", jsonStr!);
    // if (jsonStr != null) {
    //   String cleanedString =
    //       jsonStr.replaceAll(r'\', '').replaceAll('u0026', '&');

    //   final roomStoreMatch = roomStoreRegex.firstMatch(cleanedString);

    //   if (roomStoreMatch != null) {
    //     roomStoreJson = roomStoreMatch.group(1)!;
    //     final anchorNameMatch = nicknameRegex.firstMatch(roomStoreJson);

    //     if (anchorNameMatch != null) {
    //       String anchorName = anchorNameMatch.group(1)!;

    //       roomStoreJson =
    //           '${roomStoreJson.split(',"has_commerce_goods"')[0]}}}}';
    //       try {
    //         Map<String, dynamic>? audio;

    //         Map<String, dynamic> jsonData =
    //             jsonDecode(roomStoreJson)['roomInfo']['room'];
    //         jsonData['anchor_name'] = anchorName;
    //         if (jsonData['status'] == 4) {
    //           var streamInfo = Media(
    //             categroy: Categroy.living,
    //             id: jsonData['id_str'],
    //             platform: platform.simple(),
    //             title: jsonData['title'],
    //             flv: jsonData["stream_url"]["flv_pull_url"],
    //             m3u8: jsonData["stream_url"]["hls_pull_url_map"],
    //             coverUrl: jsonData['cover']['url_list'][0],
    //             streamingStatus: int.parse(jsonData['status'].toString()),
    //           );
    //           return streamInfo;
    //         }
    //         int streamOrientation =
    //             jsonData['stream_url']['stream_orientation'];
    //         List<Match> jsonMatches =
    //             jsonMatchRegex.allMatches(htmlStr).toList();
    //         Map<String, dynamic>? originUrlList;

    //         if (jsonMatches.isNotEmpty) {
    //           jsonStr = (streamOrientation == 1)
    //               ? jsonMatches[0].group(1)!
    //               : jsonMatches[1].group(1)!;
    //           Map<String, dynamic> jsonData2 = jsonDecode(
    //             jsonStr
    //                 .replaceAll(r'\', '')
    //                 .replaceAll('"{', '{')
    //                 .replaceAll('}"', '}')
    //                 .replaceAll('u0026', '&')
    //                 .replaceAll('null', '0'),
    //           );
    //           if (jsonData2['data']['origin'] != null) {
    //             originUrlList = jsonData2['data']['origin']['main'];
    //           }
    //           if (jsonData2['data']['ao'] != null) {
    //             audio = jsonData2['data']['ao']['main'];
    //           }
    //         } else {
    //           htmlStr = htmlStr
    //               .replaceAll(r'\', '')
    //               .replaceAll('u0026', '&')
    //               .replaceAll('null', '0');
    //           final originMainMatch = originMainRegex.firstMatch(htmlStr);
    //           if (originMainMatch != null) {
    //             originUrlList = jsonDecode('${originMainMatch.group(1)!}}');
    //           }
    //         }
    //         if (originUrlList != null) {
    //           Map<String, dynamic> originM3u8 = {
    //             'origin': originUrlList['hls']
    //           };
    //           Map<String, dynamic> originFlv = {'origin': originUrlList['flv']};

    //           Map<String, dynamic> hlsPullUrlMap =
    //               jsonData['stream_url']['hls_pull_url_map'];
    //           Map<String, dynamic> flvPullUrl =
    //               jsonData['stream_url']['flv_pull_url'];

    //           changeKeys(flvPullUrl);
    //           changeKeys(hlsPullUrlMap);

    //           jsonData['stream_url']
    //               ['hls_pull_url_map'] = {...originM3u8, ...hlsPullUrlMap};
    //           jsonData['stream_url']
    //               ['flv_pull_url'] = {...originFlv, ...flvPullUrl};
    //         }
    //         var owner = jsonData["owner"];
    //         List<Quality> qs = [];
    //         try {
    //           var qualitiesData = jsonData["stream_url"]["live_core_sdk_data"]
    //               ["pull_data"]["options"]["qualities"] as List;
    //           qs = qualitiesData
    //               .map((q) => Quality(
    //                     name: q['name'],
    //                     key: q['sdk_key'],
    //                     codec: q['v_codec'],
    //                     resolution: q['resolution'],
    //                     fps: q['fps'].toString(),
    //                   ))
    //               .toList();
    //         } catch (e) {
    //           logger.e(e);
    //         }
    //         var streamInfo = Media(
    //           categroy: Categroy.living,
    //           id: jsonData['id_str'],
    //           platform: platform.simple(),
    //           title: jsonData['title'],
    //           flv: jsonData["stream_url"]["flv_pull_url"],
    //           m3u8: jsonData["stream_url"]["hls_pull_url_map"],
    //           coverUrl: jsonData['cover']['url_list'][0],
    //           streamingStatus: int.parse(jsonData['status'].toString()),
    //           author: Author(
    //             name: owner['nickname'],
    //             avatar: owner['avatar_thumb']['url_list'][0],
    //             id: owner['sec_uid'],
    //             link: '',
    //           ),
    //           qualities: qs,
    //           audio: audio != null && audio.containsKey("flv")
    //               ? audio["flv"]
    //               : null,
    //         );

    //         return streamInfo;
    //       } catch (e) {
    //         logger.d("JSON parsing error: $e");
    //       }
    //     }
    //   }
    // }
    return null;
  }

  // void changeKeys(Map<String, dynamic> urls) {
  //   final List<String> keysToRemove = [];
  //   final Map<String, dynamic> newEntries = {}; // 临时存储新的键值对

  //   urls.forEach((key, value) {
  //     keysToRemove.add(key); // 记录需要移除的键
  //     String newKey = key.toLowerCase();
  //     var match = qualityRegex.firstMatch(value);
  //     if (match != null) {
  //       newKey = match.group(1)!;
  //     } else {
  //       if (key == "FULL_HD1") {
  //         newKey = "origin";
  //       } else if (key == "HD1") {
  //         newKey = "hd";
  //       } else if (key == "SD1") {
  //         newKey = "ld";
  //       } else if (key == "SD2") {
  //         newKey = "sd";
  //       }
  //     }
  //     newEntries[newKey] = value; // 将新的键值对存入临时 Map
  //   });
  //   for (var key in keysToRemove) {
  //     urls.remove(key);
  //   }
  //   urls.addAll(newEntries);
  // }
}
