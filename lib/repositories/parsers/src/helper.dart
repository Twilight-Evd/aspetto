import 'package:bunny/models/record.dart';
import 'package:sharebox/utils/log.dart';

import 'parser.dart';

class ParserMap {
  final Parser parser;
  final MediaPlatform platform;

  const ParserMap(this.parser, this.platform);
}

class ParserHelper {
  static final ParserHelper _instance = ParserHelper._internal();
  List<ParserMap> parserMaps = [];
  ParserHelper._internal();
  factory ParserHelper() {
    return _instance;
  }
  List<MediaPlatform> getMediaPlatforms() {
    return parserMaps.map((pm) => pm.platform).toList();
  }

  void registerParser(Parser p) {
    if (p.platform.domains != null &&
        p.platform.domains!.isNotEmpty &&
        p.platform.enabled != false) {
      parserMaps.add(ParserMap(p, p.platform));
    }
  }

  Parser? getParser(String url) {
    for (var parserMap in parserMaps) {
      if (parserMap.platform.domains != null &&
          parserMap.platform.domains!.isNotEmpty) {
        for (var platformDomain in parserMap.platform.domains!) {
          if (url.contains(platformDomain)) {
            return parserMap.parser;
          }
        }
      }
    }
    return null;
  }

  Parser? getParserByPlatform(MediaPlatform platform) {
    try {
      final pm = parserMaps.firstWhere((p) => p.platform.name == platform.name);
      return pm.parser;
    } catch (e) {
      logger.d("can not found platform ${platform.name}");
      return null;
    }
  }
}
