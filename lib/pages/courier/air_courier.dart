import 'dart:io';

import 'package:bunny/constants/colors.dart';
import 'package:bunny/constants/sizes.dart';
import 'package:bunny/pages/global/open_chat.dart';
import 'package:bunny/pages/global/popover.dart';
import 'package:bunny/providers/setting/setting.dart';
import 'package:bunny/services/service.dart';
import 'package:bunny/utils/extension.dart';
import 'package:bunny/widgets/path_menu.dart';
import 'package:bunny/widgets/refresh_button.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharebox/models/device.dart';
import 'package:sharebox/models/file.dart';
import 'package:sharebox/models/message.dart';
import 'package:sharebox/models/transfer.dart';
import 'package:sharebox/providers/courier/courier.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/path.dart';
import 'package:sharebox/utils/screen.dart';
import 'package:sharebox/utils/util.dart';
import 'package:sharebox/widgets/animation_widget.dart';
import 'package:sharebox/widgets/button.dart';
import 'package:sharebox/widgets/icon_label.dart';
import 'package:sharebox/widgets/image.dart';
import 'package:sharebox/widgets/water.dart';
import 'package:url_launcher/url_launcher.dart';

class AirCourier extends StatelessWidget {
  const AirCourier({super.key});

  static List<ClientCubit> devices = [];

  Future<FileWithFolder> parseFile(DropItem file,
      [int depth = 0, String? path]) async {
    final fileModel = FileModel()
      ..id = Utils.id
      ..name = file.name
      ..size = await file.length()
      ..type = FileHelper.parseMimeType(file.mimeType);
    final fwf = FileWithFolder()..fileModel = fileModel;
    if (depth > 0 && path != null) {
      fwf.folder = path;
    }
    return fwf;
  }

  Future<List<dynamic>> parseFolder(List<DropItem> files,
      [int depth = 0, String? path]) async {
    List<FileWithFolder> sendFiles = [];
    List<FileWithFolder> sendFolders = [];
    String? filePath;
    String? folderPath;

    for (final file in files) {
      if (file is DropItemDirectory) {
        folderPath = file.path;
        logger.d(folderPath);
        final segments = Uri.parse(file.path).pathSegments;
        final segs = segments.sublist(segments.length - depth);
        logger.d(segs);
        final folders = await parseFolder(
          file.children,
          depth + 1,
          segs.join(Platform.pathSeparator),
        );
        sendFolders.addAll(folders[2]);
      } else {
        if (depth == 0) {
          filePath = File(file.path).parent.path;
          sendFiles.add(await parseFile(file, depth, path));
        } else {
          sendFolders.add(await parseFile(file, depth, path));
        }
      }
    }
    return [sendFiles, filePath, sendFolders, folderPath];
  }

  Future<void> sendFile(
      BuildContext context, ClientCubit cubit, List<DropItem> files,
      [int depth = 0]) async {
    final sendFiles = await parseFolder(files);
    if (sendFiles.isNotEmpty) {
      if (sendFiles[0].isNotEmpty) {
        cubit.onSendFile(SendFileEvent(
          devices: [cubit.device],
          files: sendFiles[0],
          path: sendFiles[1],
        ));
      }
      if (sendFiles[2].isNotEmpty) {
        final folder = PathHelper.basename(sendFiles[3]);
        final path = Directory(sendFiles[3]).parent.path;
        cubit.onSendFile(SendFileEvent(
          devices: [cubit.device],
          files: sendFiles[2],
          path: path, //sendFiles[3],
          folder: folder,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CourierBloc>()..add(LoadClientsEvent());
    final me = bloc.me;
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = ScreenHelper.getScreenSizeWithBuild(context);
    const double desiredBlockWidth = 120;
    final int crossAxisCount =
        ((screenSize.width - leftWidth - mainSpace) / desiredBlockWidth)
            .floor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.only(left: 20),
          child: IconWithLabel(
            iconWidget: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: Img.image("logo_round.png", size: Size(50, 50)),
            ),
            labelWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "显示为",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Row(
                  children: [
                    Text(me.name),
                    // CustomButton(
                    //   hoverText: "编辑名称",
                    //   child: Img.image("edit.png", size: Size(12, 12)),
                    // )
                  ],
                )
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Text("附近的设备"),
              SizedBox(
                width: 20,
              ),
              RefreshButton(
                onTap: () {
                  bloc.add(LoadClientsEvent());
                },
              )
            ],
          ),
        ),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: BlocBuilder<CourierBloc, CourierState>(
                builder: (context, state) {
                  if (state is CourierClientsLoaded) {
                    // devices.clear();
                    // devices.addAll(state.clients);
                    Utils.updateList(devices, state.clients);
                  } else if (state is CourierClientsDeleted) {
                    devices.removeWhere(
                        (e) => state.ids.contains(e.device.physicsId));
                  }
                  if (devices.isEmpty) {
                    return Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        direction: Axis.vertical,
                        children: [
                          Text(
                            "未找到用户",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "附近没有可共享的人",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: devices.length,
                    // semanticChildCount: 15,
                    padding: EdgeInsets.all(0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount == 0 ? 5 : crossAxisCount,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final cubit = devices[index];
                      final device = cubit.device;
                      return Container(
                        constraints: BoxConstraints(
                          maxHeight: desiredBlockWidth,
                          maxWidth: desiredBlockWidth,
                        ),
                        height: desiredBlockWidth,
                        width: desiredBlockWidth,
                        child: WaterRipple(
                          count: 3,
                          color: Colors.grey,
                          size: Size(desiredBlockWidth, desiredBlockWidth),
                          label: Text(
                            device.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 12),
                          ),
                          child: DropTarget(
                            onDragDone: (detail) async {
                              await sendFile(context, cubit, detail.files);
                            },
                            onDragUpdated: (details) {},
                            onDragEntered: (detail) {},
                            onDragExited: (detail) {},
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey
                                        .withValues(alpha: 0.2), // 阴影颜色
                                    blurRadius: 3.0, // 模糊半径
                                    spreadRadius: 5.0, // 扩散半径
                                    offset: Offset(0, 0), // 阴影偏移
                                  ),
                                ],
                              ),
                              child: BlocProvider.value(
                                key: Key(device.physicsId),
                                value: cubit,
                                child: BlocBuilder<ClientCubit, CourierState>(
                                  builder: (context, state) {
                                    bool inListPage = true;
                                    if (state is CourierReceivedItem) {
                                      inListPage =
                                          (state.transferState.device.status ==
                                                  null ||
                                              state.transferState.device.status!
                                                  .inListPage);
                                    }

                                    bool show = false;
                                    String confirmMessage = "";
                                    if (state is CourierReceivedItemAsk) {
                                      show = true;
                                      confirmMessage = "ask".tr(
                                          gender: state.files.folder != null
                                              ? "folder"
                                              : "file",
                                          args: [
                                            "${state.files.files.length}"
                                          ]);
                                    }
                                    return Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        if (state is CourierReceivedItem &&
                                            inListPage &&
                                            state.transferState.status ==
                                                TransferStatus.inProgress)
                                          SizedBox(
                                            height: 63.0,
                                            width: 63.0,
                                            child: CircularProgressIndicator(
                                              color: colorScheme.primary,
                                              value: state
                                                      .transferState.progress ??
                                                  0,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        AnimationWidget(
                                          onCompleted: () {
                                            openChatbox(
                                                context, cubit, [device]);
                                          },
                                          child: Popover(
                                            key: Key(device.physicsId),
                                            show: show,
                                            confirmMessage:
                                                confirmMessage, // "请求发送文件",
                                            onComfirm: () {
                                              cubit.onConfirmItem(
                                                true,
                                                SaveWay(
                                                  gallery: false,
                                                  savePath: SettingRepository()
                                                      .getReceviedPath(),
                                                ),
                                                [],
                                              );
                                            },
                                            onCancel: () {
                                              cubit.onConfirmItem(
                                                false,
                                                SaveWay(
                                                  gallery: false,
                                                  savePath: SettingRepository()
                                                      .getReceviedPath(),
                                                ),
                                                [],
                                              );
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 30,
                                              child: device.type.icon,
                                            ),
                                          ),
                                        ),
                                        // if (device.model != null)
                                        //   Positioned(
                                        //     right: 0,
                                        //     top: 0,
                                        //     child: Img.device(
                                        //       device.model!.toLowerCase(),
                                        //     ),
                                        //   )
                                      ],
                                    );
                                  },
                                ),
                              ),
                              // },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                buildWhen: (previous, current) {
                  return current is CourierClientsLoaded ||
                      current is CourierClientsDeleted;
                },
              )),
        ),
        BlocBuilder<CourierBloc, CourierState>(
          builder: (context, state) {
            List<ClientCubit> devices = [];
            if (state is CourierClientsLoaded) {
              devices = state.history;
            }
            if (devices.isEmpty) {
              return SizedBox.shrink();
            }
            return SizedBox(
              height: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("最近互动设备"),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: devices.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final cubit = devices[index];
                        final device = cubit.device;
                        return SizedBox(
                          width: 100,
                          height: 50,
                          child: AnimationWidget(
                            onCompleted: () {
                              openChatbox(context, cubit, [device]);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey
                                            .withValues(alpha: 0.2), // 阴影颜色
                                        blurRadius: 3.0, // 模糊半径
                                        spreadRadius: 5.0, // 扩散半径
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 20,
                                    child:
                                        device.type.iconWithSize(Size(25, 25)),
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  device.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          buildWhen: (previous, current) {
            return current is CourierClientsLoaded;
          },
        ),
        Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor))),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<SettingCubit, SettingState>(
                builder: (context, state) {
              return Row(
                children: [
                  Text(
                    "文件存储到：",
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  PathMenu(
                    path: state.model.receivedPath,
                    updatePath: (path) async {
                      SettingCubit cubit = context.read<SettingCubit>();
                      Directory dir = await Services.toAppPath(path);
                      cubit.setReceviedPath(dir);
                    },
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  CustomButton(
                    hoverText: "打开文件夹",
                    onTap: () async {
                      if (!await launchUrl(
                          Uri.directory(state.model.receivedPath))) {
                        throw Exception(
                            'Could not launch ${state.model.receivedPath}');
                      }
                    },
                    color: Skin.transparent,
                    icon: Img.image(
                      "open_folder.png",
                    ),
                  )
                ],
              );
            }))
      ],
    );
  }
}
