import 'dart:io';

import 'package:bunny/pages/global/chat_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharebox/models/device.dart';
import 'package:sharebox/models/file.dart';
import 'package:sharebox/models/message.dart';
import 'package:sharebox/providers/courier/courier.dart';
import 'package:sharebox/utils/debounce_throttle.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/path.dart';
import 'package:sharebox/utils/util.dart';
import 'package:sharebox/widgets/dot.dart';
import 'package:sharebox/widgets/modal_widget.dart';
import 'package:sharebox/widgets/widget.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final List<Device> devices;
  final double maxWidth;
  const ChatScreen({
    super.key,
    this.onClose,
    required this.maxWidth,
    required this.devices,
  });
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier loading = ValueNotifier(false);
  final TextEditingController tec = TextEditingController();
  ClientCubit? cubit;
  int? page;
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    cubit = context.read<ClientCubit>();
    cubit?.onClientsStatusChange(ClientsStatusChangeEvent(widget.devices, DeviceStatus.inChat));
    cubit?.onLoadMessage(LoadMessageEvent(widget.devices.first, 1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (page != null) {
          DebounceThrottle.throttle(() {
            cubit?.onLoadMessage(LoadMessageEvent(widget.devices.first, page! + 1));
          }, key: "loadingMessage")();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cubit?.onClientsStatusChange(ClientsStatusChangeEvent(widget.devices, DeviceStatus.inChat));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    tec.dispose();
    loading.dispose();
    messages.clear();
    cubit?.onClientsStatusChange(ClientsStatusChangeEvent(widget.devices, DeviceStatus.idle));
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _pickFiles() async {
    try {
      MyModal.loading(msg: tr("opening"));

      final paths = (await FilePicker.platform.pickFiles(
        compressionQuality: 30,
        type: FileType.any,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) {
          logger.d(status);
        },
        allowedExtensions: null,
        dialogTitle: "选择文件",
        initialDirectory: "",
        // lockParentWindow: true,
      ))
          ?.files;

      if (paths != null) {
        List<FileWithFolder> files = [];
        String path = "";
        for (var e in paths) {
          if (path.isEmpty) {
            path = File(e.path!).parent.path;
          }
          var fileModel = FileModel()
            ..id = Utils.id
            ..name = e.name
            ..size = e.size
            ..type = FileHelper.classifyFileType(e.path!);
          files.add(FileWithFolder()..fileModel = fileModel);
        }
        if (files.isNotEmpty) {
          cubit?.onSendFile(SendFileEvent(
            devices: widget.devices,
            files: files,
            path: path,
            // isFile: true,
          ));
        }
      }
    } on PlatformException catch (e) {
      logger.e('Unsupported operation$e');
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void _pickFolder() async {
    try {
      MyModal.loading(msg: tr("opening"));

      String? path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "选择文件夹",
        initialDirectory: "",
        // lockParentWindow: true,
      );
      if (path != null) {
        final files = await FileHelper.getFilesInDirectory(
          path,
          recursive: true,
          filter: (path) {
            final name = path.split(Platform.pathSeparator).last; // 提取文件名
            return !name.startsWith('.');
          },
        );
        final folder = PathHelper.basename(path);
        final basePath = Directory(path); //.path; //parent.path;
        List<FileWithFolder> folderFiles = [];
        for (var file in files) {
          var fileModel = FileModel()
            ..id = Utils.id
            ..name = PathHelper.basename(file.path)
            ..size = file.lengthSync()
            ..type = FileHelper.classifyFileType(file.path);

          final relativePath = PathHelper.getRelativePath(basePath.path, file.parent.path);
          final folder = FileWithFolder()
            ..fileModel = fileModel
            ..folder = relativePath;
          folderFiles.add(folder);
        }
        if (folderFiles.isNotEmpty) {
          cubit?.onSendFile(SendFileEvent(
            devices: widget.devices,
            files: folderFiles,
            path: basePath.parent.path,
            folder: folder,
          ));
        }
      }
    } on PlatformException catch (e) {
      logger.e('Unsupported operation$e');
    } catch (e) {
      logger.e(e.toString());
    } finally {}
  }

  void sendMessage(
    BuildContext context,
  ) {
    try {
      if (tec.text.trim().isNotEmpty) {
        cubit?.onSendMessage(SendMessageEvent(widget.devices, tec.text));
        tec.clear();
      }
    } catch (e) {
      logger.d(e);
    }
  }

  Widget chatboxHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      width: widget.maxWidth,
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth * 0.7),
            child: IconWithLabel(
              iconWidget: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Img.image("logo.png", size: Size(30, 30)),
              ),
              labelWidget: Text(
                widget.devices.first.name,
                style: TextStyle(
                  color: colorScheme.secondary,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ),
          ),
          IconWithLabel(
            iconWidget: cubit?.online == true
                ? Dot(
                    key: ValueKey("${cubit?.device.physicsId}_online"),
                    color: Colors.green,
                    animated: true,
                  )
                : Dot(
                    key: ValueKey("${cubit?.device.physicsId}_offline"),
                    color: Colors.grey,
                  ),
            labelWidget: Text(
              cubit?.online == true ? tr("online") : tr("offline"),
              style: TextStyle(color: colorScheme.secondary, fontSize: 10),
            ),
          ),

          Spacer(),
          // CustomButton(
          //   padding: EdgeInsets.zero,
          //   child: Img.image("minimize.png", color: colorScheme.secondary),
          // ),
          // CustomButton(
          //   padding: EdgeInsets.zero,
          //   child: Img.image("maximize.png", color: colorScheme.secondary),
          // ),
          CustomButton(
            onTap: widget.onClose,
            padding: EdgeInsets.zero,
            child: Img.image("close.png", color: colorScheme.secondary),
          ).animated
        ],
      ),
    );
  }

  Widget chatboxToolbar() {
    final colorScheme = Theme.of(context).colorScheme;
    Color? statusColor;
    if (cubit?.online != true) {
      statusColor = Colors.grey;
    }
    return Container(
      decoration: BoxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimationWidget(
            onCompleted: cubit?.online == true
                ? () {
                    _pickFiles();
                  }
                : null,
            hoverText: "选择附件",
            child: Img.image("attach_file.png", size: Size(25, 25), color: statusColor),
          ),
          SizedBox(
            width: 10,
          ),
          AnimationWidget(
            onCompleted: cubit?.online == true
                ? () {
                    _pickFolder();
                  }
                : null,
            hoverText: "选择文件夹",
            child: Img.image("folder.png", size: Size(25, 25), color: statusColor),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: CustomFormTextField(
              style: TextStyle(color: colorScheme.onPrimary),
              controller: tec,
              maxLines: 5,
              minLines: 1,
              radius: Radius.circular(5),
              readOnly: cubit?.online != true,
              borderColor: cubit?.online != true ? statusColor : null,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          ValueListenableBuilder(
            valueListenable: tec,
            builder: (context, value, child) {
              Color? color;
              if (value.text.isEmpty) {
                color = Colors.grey;
              }
              return AnimationWidget(
                onCompleted: () {
                  DebounceThrottle.debounce(() {
                    sendMessage(context);
                  }, key: "sending")();
                },
                hoverText: "发送",
                child: Img.image(
                  "send.png",
                  size: Size(30, 30),
                  color: color,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chatboxHeader(),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (_) {}, // Absorb pointer events in this area
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              color: Colors.white,
              child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: BlocConsumer<ClientCubit, CourierState>(
                    buildWhen: (previous, current) => current is CourierMessageLoaded || current is CourierMessageAppended || current is CourierMessageDeleted, // current is CourierReceivedItem,
                    builder: (context, state) {
                      if (state is CourierMessageLoaded) {
                        Utils.updateList(messages, state.messages);
                        if (messages.length != state.count) {
                          page = state.page;
                        } else {
                          page = null;
                        }
                      } else if (state is CourierMessageAppended) {
                        if (state.messages.isNotEmpty) {
                          if (messages.isNotEmpty && messages.first.id == state.messages.first.id) {
                            messages[0] = state.messages.first;
                          } else {
                            messages.insertAll(0, state.messages);
                          }
                        }
                      } else if (state is CourierMessageDeleted) {
                        messages.removeWhere((message) => state.ids.contains(message.id));
                      }

                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(10.0),
                            itemCount: messages.length, // 假设有 10 条消息
                            reverse: true,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              bool isSentByUser = false;

                              if (message is MessageModel) {
                                isSentByUser = message.isSender(widget.devices.first.device);
                              } else if (message is MessageCubit) {
                                isSentByUser = message.messageModel.isSender(widget.devices.first.device);
                              }
                              return Align(
                                alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: isSentByUser ? Color.fromRGBO(151, 226, 210, 1) : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ChatMessage(
                                    key: Key("${message.id}"),
                                    message: message,
                                    maxWidth: widget.maxWidth * .60,
                                    isSentByUser: isSentByUser,
                                    onDelete: () {
                                      cubit?.onDeleteMessage(message.id);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: loading,
                            builder: (context, value, child) {
                              return Visibility(visible: value, child: child!);
                            },
                            child: Ball3Loading(
                              color: Color.fromRGBO(151, 226, 210, 1),
                            ),
                          ),
                        ],
                      );
                    },
                    listener: (BuildContext context, CourierState state) {
                      if (state is CourierMessageLoading) {
                        loading.value = true;
                      } else {
                        loading.value = false;
                        if (state is ClientOffline || state is ClientOnline) {
                          setState(() {});
                        }
                      }
                    },
                  )),
            ),
          ),
        ),
        chatboxToolbar()
      ],
    );
  }
}
