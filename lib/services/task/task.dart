import 'dart:isolate';

import 'package:sharebox/utils/debounce_throttle.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';

// 定义状态枚举
enum TaskStatus {
  idled,
  running,
  started,
  paused,
  error,
  completed,
  stopped,
}

enum TaskCmd {
  exit,
  pause,
  resume,
}

// 创建一个用于发送的消息类
// @JsonSerializable()
class TaskMessage {
  final TaskStatus status;
  final String taskId;
  final String? error; // 可选的错误信息
  final int? received; // 可选的已接收字节数
  final int? total; // 可选的总字节数
  final String? extra;
  final Duration? time;
  final double? speed;

  TaskMessage({
    required this.status,
    required this.taskId,
    this.error,
    this.received,
    this.total,
    this.extra,
    this.time,
    this.speed,
  });
}

/// 抽象任务基类
abstract class Task {
  final String id;
  final String url;
  final String savePath;
  final String filename;

  late SendPort sendPort; //外部ReceivePort, 用户 内部往外传send

  Task(this.id, this.url, this.savePath, this.filename);

  Future<void> start() async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((message) async {
      if (message == TaskCmd.exit) {
        await exit();
        receivePort.close();
      } else if (message == TaskCmd.pause) {
        await pause();
      } else if (message == TaskCmd.resume) {
        await resume();
      }
    });
  }

  Future<String> buildFileName() async {
    final entity = await FileHelper.generateUniqueEntity(savePath, filename,
        isFolder: false);
    return entity.entity.path;
  }

  Future<void> exit();
  Future<void> pause() async {}
  Future<void> resume() async {}
}

class TaskChannel {
  final Isolate taskIsolate;
  late SendPort? sendPort; //像内部传信息

  TaskChannel({
    required this.taskIsolate,
    this.sendPort,
  });

  dispose() {
    taskIsolate.kill(priority: Isolate.immediate);
    sendPort = null;
  }

  emit(TaskCmd cmd) {
    if (sendPort != null) {
      sendPort?.send(cmd);
    }
  }
}

class TaskManager {
  static final TaskManager _instance = TaskManager._internal();
  TaskManager._internal();
  factory TaskManager() {
    return _instance;
  }

  final Map<String, TaskChannel> _tasks = {};

  Future<TaskChannel> addTask(Task task, {Function? callback}) async {
    if (_tasks.containsKey(task.id)) return _tasks[task.id]!;
    final ReceivePort receivePort = ReceivePort();
    task.sendPort = receivePort.sendPort;
    final isolate = await Isolate.spawn(_taskEntryPoint, task);
    _tasks[task.id] = TaskChannel(taskIsolate: isolate);

    receivePort.listen((message) {
      if (message is SendPort) {
        _tasks[task.id]!.sendPort = message;
      } else {
        final taskMessage = message as TaskMessage; // 将 message 转换为 TaskMessage
        DebounceThrottle.debounce(() {
          callback?.call(taskMessage);
        }, milliseconds: 1000, key: task.id)();
        if (taskMessage.status == TaskStatus.completed ||
            taskMessage.status == TaskStatus.stopped) {
          _tasks[task.id]?.dispose();
          _tasks.remove(task.id);

          receivePort.close();
          callback?.call(taskMessage);
        } else if (taskMessage.status != TaskStatus.running) {
          callback?.call(taskMessage);
        }
        if (taskMessage.extra != null) {
          logger.d(">>>>>>>>>>>> ${taskMessage.extra}");
        }
      }
    });
    return _tasks[task.id]!;
  }

  Future<void> exitTask(String taskId) async {
    if (_tasks.containsKey(taskId)) {
      _tasks[taskId]?.emit(TaskCmd.exit);
    }
  }

  Future<void> pauseTask(String taskId) async {
    if (_tasks.containsKey(taskId)) {
      _tasks[taskId]?.emit(TaskCmd.pause);
    }
  }

  Future<void> resumeTask(String taskId) async {
    if (_tasks.containsKey(taskId)) {
      _tasks[taskId]?.emit(TaskCmd.resume);
    }
  }

  Future<void> stopAllTasks() async {
    for (var task in _tasks.values) {
      await task.emit(TaskCmd.exit);
    }
    _tasks.clear();
  }

  Future<void> dispose() async {
    return stopAllTasks();
  }

  static void _taskEntryPoint(Task task) async {
    await task.start();
  }
}
