import 'package:bunny/utils/util.dart';
import 'package:process_run/process_run.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/path.dart';

class FfmpegHelper {
  static Future<Map<String, dynamic>> fetchVideoInfo(String filepath) async {
    if (!await FileHelper.fileExist(filepath)) {
      return {};
    }
    final shellPath = UtilHelper.getShellPath();
    final pr = runExecutableArgumentsSync(
      PathHelper.join(shellPath, "ffmpeg"),
      [
        "-i",
        filepath,
      ],
    );
    return parseMediaInfo(pr.errText);
  }

  static Map<String, dynamic> parseMediaInfo(String ffprobeOutput) {
    // 正则表达式解析
    final durationRegex = RegExp(r'Duration: (\d+):(\d+):([\d.]+)');
    final bitrateRegex = RegExp(r'bitrate: (\d+) kb/s');
    final videoResolutionRegex = RegExp(r'Video: .*?, .*?, (\d+x\d+)');

    int? totalSeconds;
    int? totalBitrate;

    Map<String, dynamic> ret = {};
    // 匹配 Duration
    final durationMatch = durationRegex.firstMatch(ffprobeOutput);
    if (durationMatch != null) {
      final hours = int.parse(durationMatch.group(1)!);
      final minutes = int.parse(durationMatch.group(2)!);
      final seconds = double.parse(durationMatch.group(3)!).round();

      totalSeconds = hours * 3600 + minutes * 60 + seconds;
      ret["duration"] = Duration(seconds: totalSeconds);
    }

    // 匹配总比特率 (bitrate)
    final bitrateMatch = bitrateRegex.firstMatch(ffprobeOutput);
    if (bitrateMatch != null) {
      totalBitrate = int.parse(bitrateMatch.group(1)!);
    }

    // 匹配视频分辨率与比特率 (Video)
    final videoResolutionMatch = videoResolutionRegex.firstMatch(ffprobeOutput);
    if (videoResolutionMatch != null) {
      ret["resolution"] = videoResolutionMatch.group(1);
    }

    // 计算文件大小（以字节为单位）
    if (totalSeconds != null && totalBitrate != null) {
      final fileSizeBytes =
          (totalSeconds * totalBitrate * 1000) / 8; // kbps 转换为 bps
      ret["total"] = fileSizeBytes.round();
    }
    return ret;
  }
}
