import 'package:air/register_as_subclass.dart';
import 'package:bunny/models/common.dart';
import 'package:bunny/models/record.dart';
import 'package:sharebox/utils/log.dart';

import 'helper.dart';

@RegisterAsSubclass()
abstract class Parser {
  Parser() {
    ParserHelper().registerParser(this);
  }
  MediaPlatform get platform;
  Future<Media?> streaming(String shareUrl);
  Future<Source?> chooseQuality(Media m, Quality quality) => Future(() => null);
  List<Quality> supportQualities() => [];
  List<Source> filledSource(Categroy categroy) {
    return supportQualities()
        .map((q) => Source(key: q.key, quality: q, categroy: categroy))
        .toList();
  }

  Quality? getQualityByKey(String key) {
    try {
      return supportQualities().firstWhere((q) => q.key == key);
    } catch (e) {
      logger.d("platfrom ${platform.name}  cannot find quality $key");
    }
    return null;
  }
}
