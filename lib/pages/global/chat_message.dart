import 'package:bunny/services/service.dart';
import 'package:bunny/utils/extension.dart';
import 'package:bunny/widgets/confirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sharebox/models/message.dart';
import 'package:sharebox/models/transfer.dart';
import 'package:sharebox/providers/courier/bloc/message_cubit.dart';
import 'package:sharebox/utils/extensions/ext.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/screen.dart';
import 'package:sharebox/utils/util.dart';
import 'package:sharebox/widgets/autolinktext.dart';
import 'package:sharebox/widgets/bubble_arrow.dart';
import 'package:sharebox/widgets/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessage extends StatelessWidget {
  final Message message;
  final double maxWidth;
  final bool isSentByUser;
  final Function onDelete;

  ChatMessage({
    super.key,
    required this.message,
    required this.maxWidth,
    required this.isSentByUser,
    required this.onDelete,
  });

  final GlobalKey columnKey = GlobalKey();

  void _showContextMenu(
    BuildContext context,
    Offset position,
  ) {
    final RenderBox renderBox = columnKey.currentContext!.findRenderObject() as RenderBox;
    final Offset topLeft = renderBox.localToGlobal(Offset.zero);
    final Offset bottomRight = renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero));
    final double width = bottomRight.dx - topLeft.dx;

    logger.d(topLeft);
    logger.d(bottomRight);
    final size = Size(140, 70);

    double? left = topLeft.dx - 10;
    double? right;
    double top = bottomRight.dy + 5;
    double arrowOffset = 0;
    BubbleArrowDirection arrowPosition = BubbleArrowDirection.top;

    if (width < size.width) {
      arrowOffset = (size.width - width) / 2 - 6;
      if (!isSentByUser) {
        arrowOffset = -arrowOffset;
      }
    }
    final screen = ScreenHelper.getScreenSize(context);
    if (bottomRight.dy + size.height + 5 > screen.height) {
      arrowPosition = BubbleArrowDirection.bottom;
      top = topLeft.dy - (size.height + 5);
    }

    final btnStyle = TextStyle(fontSize: 12);
    final deleteBtn = CustomButton(
      borderRadius: 0,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      direction: Axis.vertical,
      icon: Img.image("delete.png"),
      child: Text(
        "删除",
        style: btnStyle,
      ),
    );

    logger.d("?>>>>> $left, $top");
    SmartDialog.show(
      tag: "toolbar",
      usePenetrate: true,
      animationType: SmartAnimationType.fade,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: top,
              left: left,
              right: right,
              child: BubbleWidget(
                width: size.width,
                height: size.height,
                color: Colors.grey.withValues(alpha: .4),
                position: arrowPosition,
                style: PaintingStyle.stroke,
                borderColor: Color.fromRGBO(248, 246, 246, 1),
                arrowOffset: arrowOffset,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (message.type == MessageType.message)
                      deleteBtn
                          .copyWith(
                            icon: Img.image("copy.png"),
                            child: Text(
                              "复制",
                              style: btnStyle,
                            ),
                            onTap: () async {
                              await Services.copyData((message as MessageModel).message!);
                              SmartDialog.dismiss(tag: "toolbar");
                            },
                          )
                          .splash(Colors.grey.withValues(alpha: .2)),
                    deleteBtn.copyWith(onTap: () {
                      SmartDialog.dismiss(tag: "toolbar");
                      SmartDialog.show(
                        tag: "ask_to_delete",
                        builder: (_) {
                          return ConfirmDialog(
                            title: '删除提示',
                            content: "是否删除该条消息？",
                            onConfirm: () {
                              onDelete();
                            },
                          );
                        },
                      );
                    }).splash(Colors.grey.withValues(alpha: .2))
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (details) {
          _showContextMenu(context, details.globalPosition);
        },
        onSecondaryTapDown: (details) {
          _showContextMenu(context, details.globalPosition);
        },
        child: Row(
          key: columnKey,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MessageContent(
                    message: message,
                    maxWidth: maxWidth,
                  ),
                  Text(
                    Utils.format(message.time, format: "HH:mm"),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class MessageContent extends StatelessWidget {
  final Message message;
  final double maxWidth;

  MessageContent({super.key, required this.message, required this.maxWidth});

  final ValueNotifier<List<double?>> progress = ValueNotifier([]);

  double progressPercentage() {
    final totalProgress = progress.value.fold(0.0, (sum, element) => sum + (element ?? 0));
    final averageProgress = totalProgress / progress.value.length;
    return averageProgress;
  }

  bool allDone() {
    return progress.value.every((element) => element == 1);
  }

  Widget buildFiles(MessageModel message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(message.files!.length, (i) {
        final file = message.files![i]!.fileModel!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: ValueListenableBuilder(
                      valueListenable: progress,
                      builder: (context, value, child) {
                        if (value.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return Visibility(
                          visible: value.isNotEmpty && value[i] != null && value[i]! < 1,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: value[i],
                          ),
                        );
                      },
                    ),
                  ),
                  file.type.icon(size: Size(24, 24)),
                ],
              ),
              const SizedBox(width: 5),
              InkWell(
                onTap: () async {
                  if (!await launchUrl(Uri.directory(message.path!))) {
                    throw Exception('Could not launch ${message.path}');
                  }
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Text(
                    file.name!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
              if (file.size != null) ...[
                SizedBox(
                  width: 10,
                ),
                Text(
                  file.size!.toDouble().formatBytes(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ]
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildFolder(MessageModel message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              SizedBox(
                height: 30.0,
                width: 30.0,
                child: ValueListenableBuilder(
                  valueListenable: progress,
                  builder: (context, value, child) {
                    if (value.isEmpty) {
                      return SizedBox.shrink();
                    }
                    final percentage = progressPercentage();
                    return Visibility(
                      visible: percentage < 1,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: percentage,
                      ),
                    );
                  },
                ),
              ),
              Img.image("folder_file.png", size: Size(24, 24))
            ],
          ),
          const SizedBox(width: 5),
          InkWell(
            onTap: () async {
              if (!await launchUrl(Uri.directory(message.folderPath))) {
                throw Exception('Could not launch ${message.folderPath}');
              }
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Text(
                message.folder!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            message.files!.fold(0, (sum, f) => f!.fileModel?.size ?? 0).toDouble().formatBytes(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MessageModel messageModel;
    if (message is MessageModel) {
      messageModel = message as MessageModel;
      if (messageModel.type == MessageType.message) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: AutoLinkText(
            text: messageModel.message!,
            style: TextStyle(
              color: Colors.black87,
            ),
            linkStyle: TextStyle(color: Colors.blue),
          ),
        );
      } else if (messageModel.type == MessageType.file) {
        return buildFiles(messageModel);
      }
      return buildFolder(messageModel);
    } else {
      messageModel = (message as MessageCubit).messageModel;
    }
    return BlocProvider.value(
      value: message as MessageCubit,
      child: BlocListener<MessageCubit, TransferState?>(
        child: messageModel.type == MessageType.file ? buildFiles(messageModel) : buildFolder(messageModel),
        listener: (context, state) {
          if (state != null) {
            final bm = state.fileBatchMarker!;
            if (progress.value.isEmpty) {
              progress.value = List.filled(bm.total, null);
            }
            progress.value = [...progress.value]..[bm.index] = state.progress;
            if (state.status == TransferStatus.completed) {
              if (allDone()) {
                (message as MessageCubit).succed();
              }
            }
          }
        },
      ),
    );
  }
}
