import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bunny/utils/util.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';
import 'package:sharebox/utils/log.dart';

import 'task.dart';

const String userAgent =
    "Mozilla/5.0 (Linux; Android 11; SAMSUNG SM-G973U) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/14.2 Chrome/87.0.4280.141 Mobile Safari/537.36";
const String rwTimeout = "30000000";
const String analyzeduration = "40000000";
const String probesize = "10000000";
const String bufsize = "12000k";
const String maxMuxingQueueSize = "1024";

/// 流媒体录制任务（使用 FFmpeg 的命令行调用方式）
class StreamRecorderTask extends Task {
  bool _isRunning = false;
  Process? _process;

  bool _autoReconnect = true;

  int _maxReconnect = 5;

  int _lastReceived = 0; // 上次接收的字节数

  // final regex = RegExp(
  //     r'time=(\d{2}):(\d{2}):(\d{2})\.(\d{2}).*?bitrate=\s*([\d.]+)kbits/s');
  final regex = RegExp(
      r'\s+size=\s*(\d+)KiB\s+time=(\d{2}):(\d{2}):(\d{2})\.(\d{2})\s+bitrate=\s*([\d.]+)kbits');

  StreamRecorderTask(super.id, super.url, super.savePath, super.filename);

  List<String> baseCommand() {
    List<String> ffmpegCommand = [
      "-y",
      "-v", "verbose",
      "-rw_timeout", rwTimeout,
      "-loglevel", "info",
      "-hide_banner",
      "-user_agent", userAgent,
      "-protocol_whitelist", "rtmp,crypto,file,http,https,tcp,tls,udp,rtp",
      "-thread_queue_size", "1024",
      "-analyzeduration", analyzeduration,
      "-probesize", probesize,
      "-fflags", "+discardcorrupt+genpts",
      "-i", url, // 替代 option.RecordURL
      "-bufsize", bufsize,
      "-sn", "-dn",
      "-reconnect", "1",
      "-reconnect_delay_max", "120",
      "-reconnect_streamed", "1",
      "-reconnect_at_eof", "1",
      "-max_muxing_queue_size", maxMuxingQueueSize,
      "-correct_ts_overflow", "1",
      "-max_interleave_delta", "50M"
    ];
    return ffmpegCommand;
  }

  Future<List<String>> mp4() async {
    List<String> mp4Command = [
      // "-map",
      // "p:0",
      "-c:v",
      "copy",
      "-c:a",
      "copy",
      "-f",
      "mp4",
      await buildFileName(),
    ];
    return mp4Command;
  }

  @override
  Future<void> start() async {
    _isRunning = true;
    _autoReconnect = true;

    await super.start();

    sendPort.send(TaskMessage(status: TaskStatus.started, taskId: id));
    await _run();
  }

  Future<void> _reconnect() async {
    if (_maxReconnect <= 0) {
      await exit();
      return;
    }
    _maxReconnect--;
    await Future.delayed(Duration(seconds: 5));
    if (_isRunning) {
      await _run(); // 自动重连
    }
  }

  Future<void> _run() async {
    try {
      List<String> command = baseCommand()..addAll(await mp4());

      final shellPath = UtilHelper.getShellPath();

      final StreamController<List<int>> stdoutController =
          StreamController<List<int>>();
      final StreamController<List<int>> stderrController =
          StreamController<List<int>>();
      // 监听 stdout 的流
      stdoutController.stream
          .transform(Utf8Decoder(allowMalformed: true))
          .listen((dataString) {
        sendPort.send(TaskMessage(
            status: TaskStatus.running, taskId: id, extra: dataString));
      });

      stderrController.stream
          .transform(Utf8Decoder(allowMalformed: true))
          .listen((dataString) async {
        logger.d("pid: ${_process?.pid}>>>>>>> $dataString");
        if (_isStreamEnded(dataString)) {
          await exit();
        } else if (dataString.contains("bitrate")) {
          final match = regex.firstMatch(dataString);
          if (match != null) {
            _lastReceived = int.parse(match.group(1)!);
            final hours = int.parse(match.group(2)!);
            final minutes = int.parse(match.group(3)!);
            final seconds = int.parse(match.group(4)!);
            final milliseconds = int.parse(match.group(5)!) * 10;
            final timeDuration = Duration(
              hours: hours,
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            );
            final bitrateValue = double.parse(match.group(6)!);
            sendPort.send(TaskMessage(
              status: TaskStatus.running,
              taskId: id,
              time: timeDuration,
              speed: bitrateValue,
              received: _lastReceived,
            ));
          }
        } else if (dataString.contains("error")) {
          sendPort.send(
            TaskMessage(
              status: TaskStatus.error,
              taskId: id,
              error: dataString,
            ),
          );
        }
      });

      final ProcessResult pr = await runExecutableArguments(
        p.join(shellPath, "ffmpeg"),
        command,
        onProcess: (process) async {
          _process = process;
        },
        verbose: true,
        // runInShell: true,
        stdout: stdoutController.sink,
        stderr: stderrController.sink,
      );
      if (pr.exitCode != 0 && _isRunning && _autoReconnect) {
        sendPort.send(TaskMessage(
            status: TaskStatus.error, taskId: id, extra: exitCode.toString()));
        await _reconnect(); // 自动重连
      }
      if (pr.exitCode == 0) {
        sendPort.send(TaskMessage(status: TaskStatus.completed, taskId: id));
      } else {
        sendPort.send(
          TaskMessage(
            status: TaskStatus.completed,
            taskId: id,
            extra: exitCode.toString(),
            received: _lastReceived,
            total: _lastReceived,
          ),
        );
      }
    } catch (e) {
      if (_isRunning && _autoReconnect) {
        await _reconnect(); // 自动重连
      }
    } finally {
      _isRunning = false;
    }
  }

  @override
  Future<void> exit() async {
    if (_isRunning && _process != null) {
      _process!.stdin.write("q");
      if (Platform.isMacOS) {
        _process!.kill(ProcessSignal.sigint);
      }
      sendPort.send(TaskMessage(
        status: TaskStatus.completed,
        taskId: id,
        received: _lastReceived,
        total: _lastReceived,
      ));
      _isRunning = false;
      _autoReconnect = false;
    }
  }

  bool _isStreamEnded(String output) {
    return output.contains("End of file") || output.contains("404 Not Found");
  }
}
