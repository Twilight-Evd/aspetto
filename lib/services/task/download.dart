import 'package:dio/dio.dart';
import 'package:sharebox/utils/speed_tracker.dart';

import 'task.dart';

class DownloadTask extends Task {
  late final Dio _dio;

  bool _isRunning = false;
  bool _isPaused = false;
  int _received = 0; // 保存已接收的字节数

  // late DateTime _lastUpdateTime; // 上次更新的时间
  // int _lastReceived = 0; // 上次接收的字节数
  // double _lastbytesPerSecond = 0;

  late CancelToken _cancelToken;

  DownloadTask(super.id, super.url, super.savePath, super.filename) {
    _dio = Dio();
  }

  @override
  Future<void> start() async {
    await super.start();
    _run();
  }

  Future<void> _run() async {
    _isRunning = true;
    sendPort.send(TaskMessage(status: TaskStatus.started, taskId: id));
    // _lastUpdateTime = DateTime.now();
    _cancelToken = CancelToken();
    try {
      final tracker = SpeedTracker();
      await _dio.download(
        url,
        await buildFileName(),
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            tracker.byTotal(received);
            // int currentTime = DateTime.now().millisecondsSinceEpoch;
            // int elapsedTime =
            //     currentTime - _lastUpdateTime.millisecondsSinceEpoch;
            // if (elapsedTime > 1000) {
            //   _lastbytesPerSecond =
            //       ((_received - _lastReceived) * 1000 ~/ elapsedTime)
            //           .toDouble();
            //   _lastReceived = received;
            //   _lastUpdateTime = DateTime.now();
            // }
            // _received = received;
            sendPort.send(
              TaskMessage(
                status: received == total
                    ? TaskStatus.completed
                    : TaskStatus.running,
                taskId: id,
                received: received,
                total: total,
                speed: tracker.lastBytesPerSecond,
              ),
            );
          }
        },
        options: Options(
          headers: {'range': 'bytes=$_received-'},
        ),
      );
    } catch (e) {
      if (_isPaused) {
        sendPort
            .send(TaskMessage(status: TaskStatus.paused, taskId: id, speed: 0));
      } else {
        sendPort.send(TaskMessage(
          status: TaskStatus.error,
          taskId: id,
          error: e.toString(),
        ));
      }
    } finally {
      _isRunning = false;
      if (!_isPaused) {
        sendPort.send(TaskMessage(
          status: TaskStatus.completed,
          taskId: id,
        ));
      }
    }
  }

  // 暂停任务
  @override
  Future<void> pause() async {
    if (_isRunning) {
      _isPaused = true;
      _cancelToken.cancel();
      sendPort
          .send(TaskMessage(status: TaskStatus.paused, taskId: id, speed: 0));
      _isRunning = false;
    }
  }

  // 恢复任务
  @override
  Future<void> resume() async {
    if (!_isRunning && _isPaused) {
      _cancelToken = CancelToken(); // 重置 cancelToken
      _isPaused = false;
      await _run(); // 重新调用 start() 继续下载
    }
  }

  @override
  Future<void> exit() async {
    _cancelToken.cancel();
    sendPort
        .send(TaskMessage(status: TaskStatus.stopped, taskId: id, speed: 0));
    _isRunning = false;
  }
}
