import 'dart:io';
import 'dart:isolate';

import 'package:sharebox/utils/log.dart';

class IsolateSocket {
  late SendPort _sendPort;
  Isolate? _isolate;
  ReceivePort _receivePort = ReceivePort();
  bool _isIsolateRunning = false;
  String address = "";
  Function? callback;

  IsolateSocket(String path) {
    address = path;
  }

  // 启动Isolate并运行Socket任务
  Future<void> startSocketIsolate() async {
    _receivePort = ReceivePort();
    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message; // 主线程保存Isolate的发送端口
      } else {
        callback?.call(message);
      }
    });
    _isolate =
        await Isolate.spawn(socketHandler, [_receivePort.sendPort, address]);
    _isIsolateRunning = true;
  }

  // 向Socket发送消息
  void sendMessageToSocket(String message, Function? callback) {
    if (_isIsolateRunning) {
      this.callback = callback;
      _sendPort.send(message);
    }
  }

  // Socket后台任务处理
  static void socketHandler(List<dynamic> args) async {
    SendPort mainSendPort = args[0];
    String address = args[1];
    Socket socket;
    try {
      ReceivePort isolateReceivePort = ReceivePort();
      mainSendPort.send(isolateReceivePort.sendPort);
      socket = await Socket.connect(
        InternetAddress(address, type: InternetAddressType.unix),
        0,
      );
      isolateReceivePort.listen((message) async {
        if (message is String) {
          logger.d("write message  $message");
          socket.write(message);
          await socket.flush();
        }
      });
      socket.listen((List<int> data) {
        String received = String.fromCharCodes(data);
        mainSendPort.send(received);
      });
    } catch (e) {
      logger.d("connect to socket error $e");
      mainSendPort.send('failed');
    }
  }

  // 停止Isolate
  void dispose() {
    if (_isolate != null) {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
    }
    _isIsolateRunning = false;
  }
}
