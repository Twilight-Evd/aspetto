import 'package:bunny/constants/colors.dart';
import 'package:bunny/constants/global.dart';
import 'package:bunny/constants/sizes.dart';
import 'package:bunny/models/common.dart';
import 'package:bunny/models/download.dart';
import 'package:bunny/models/record.dart';
import 'package:bunny/pages/download/player.dart';
import 'package:bunny/providers/download/download.dart';
import 'package:bunny/services/task/task.dart';
import 'package:bunny/utils/extension.dart';
import 'package:bunny/widgets/confirm.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sharebox/models/file.dart';
import 'package:sharebox/models/message.dart';
import 'package:sharebox/providers/courier/courier.dart';
import 'package:sharebox/utils/drag.dart';
import 'package:sharebox/utils/extensions/ext.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/image_cache.dart';
import 'package:sharebox/utils/screen.dart';
import 'package:sharebox/utils/util.dart';
import 'package:sharebox/widgets/modal_widget.dart';
import 'package:sharebox/widgets/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadListView extends StatefulWidget {
  final List<DownloadItemCubit> items;
  final Function? onDeleted;

  const DownloadListView({
    super.key,
    required this.items,
    this.onDeleted,
  });
  @override
  State<DownloadListView> createState() => _DownloadListViewState();
}

class _DownloadListViewState extends State<DownloadListView> with AutomaticKeepAliveClientMixin {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.items.isEmpty) {
      return Center(
          child: IconWithLabel(
        direction: Axis.vertical,
        iconWidget: Img.image("empty.png", size: Size(80, 80), color: Theme.of(context).colorScheme.onTertiary),
        text: '暂无下载项目',
        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onTertiary),
      ));
    } else {
      return Container(
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.builder(
            primary: false,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final itemCubit = widget.items[index];
              return BlocProvider.value(
                value: itemCubit,
                key: Key(itemCubit.item.id),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.only(bottom: 5),
                  child: CustomListTile(
                    hoverTop: 0,
                    hoverRight: 0,
                    hover: AnimationWidget(
                      hoverText: "删除任务",
                      onCompleted: () {
                        SmartDialog.show(builder: (_) {
                          return ConfirmDialog(
                              title: '删除提示',
                              content: "确认要删除此任务？",
                              onConfirm: () {
                                itemCubit.delete();
                                SmartDialog.dismiss();
                                widget.onDeleted?.call(itemCubit.item);
                              });
                        });
                      },
                      child: CustomButton(onTap: () {}, icon: Img.image("delete.png")),
                    ),
                    colorHover: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
                    leading: LeadingView(
                      item: itemCubit.item,
                    ),
                    trailing: TrailingView(
                      // itemCubit: itemCubit,
                      onDeleted: widget.onDeleted,
                    ),
                    child: itemView(itemCubit.item.source),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}

Widget itemView(Source source) {
  Widget? child;
  switch (source.categroy) {
    case Categroy.living:
      child = LivingItemView();
    case Categroy.video:
      child = VideoItemView();
    case Categroy.audio:
    case Categroy.image:
  }
  return child == null ? SizedBox.shrink() : Padding(padding: const EdgeInsets.only(left: 20, right: 60), child: child);
}

class VideoItemView extends StatelessWidget {
  const VideoItemView({super.key});

  @override
  Widget build(BuildContext context) {
    // final screen = ScreenHelper.getScreenSizeWithBuild(context);
    // final contentWidth = screen.width - leftWidth - mainSpace - 30;

    return BlocBuilder<DownloadItemCubit, DownloadItemState>(builder: (context, state) {
      final item = state.item;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Img.image(item.platform.icon, size: Size(20, 20)),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        overflow: TextOverflow.ellipsis,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              IconWithLabel(
                padding: EdgeInsets.only(right: 20),
                iconWidget: Img.image("mp4.png", size: Size(14, 14)),
              ),
              if (item.source.quality.resolution != "")
                IconWithLabel(
                  padding: EdgeInsets.only(right: 20),
                  iconWidget: Img.image("resolution.png", size: Size(14, 14)),
                  text: item.source.quality.resolution,
                ),
              if (item.total != null && item.total! > 0)
                IconWithLabel(
                  padding: EdgeInsets.only(right: 20),
                  iconWidget: Img.image("storage.png", size: Size(14, 14)),
                  text: item.total!.toDouble().formatBytes(),
                ),
              if (item.totalTime != null)
                IconWithLabel(
                  iconWidget: Img.image("clock.png", size: Size(14, 14)),
                  text: Utils.durationToString(item.totalTime),
                ),
            ],
          ),
          Spacer(),
          if (item.progress != null)
            Container(
              height: 25,
              padding: EdgeInsets.only(bottom: 2),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final progressBarWidth = constraints.maxWidth;
                  return Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      LinearProgressIndicator(
                        value: item.progress, // 设置进度值
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      Positioned(
                        top: -1,
                        left: progressBarWidth * item.progress!, // 动态计算小球的位置
                        child: Img.image("loading.gif"),
                      ),
                    ],
                  );
                },
              ),
            ),
          Row(
            children: [
              if (item.status == TaskStatus.started) ...[
                Text(
                  "正在读取",
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
              if (item.progress != null) ...[
                Text(
                  "总进度：${(item.progress! * 100).toStringAsFixed(2)}%",
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(
                  width: 10,
                )
              ],
              if (item.received != null) ...[
                Text(
                  "已下载：${item.received!.toDouble().formatBytes()}",
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(
                  width: 10,
                )
              ],
              if (item.total != null) ...[
                Text(
                  "总大小：${item.total!.toDouble().formatBytes()}",
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(
                  width: 10,
                )
              ],
              if (item.time != null)
                Text(
                  "剩余时长 ${Utils.durationToString(item.time)}",
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              Spacer(),
              if (item.speed != null)
                Text(
                  item.speed!.formatDataRate(),
                  style: TextStyle(fontSize: 12),
                ),
            ],
          )
        ],
      );
    });
  }
}

class LivingItemView extends StatelessWidget {
  const LivingItemView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadItemCubit, DownloadItemState>(builder: (context, state) {
      final item = state.item;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Img.image(item.platform.icon, size: Size(20, 20)),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        overflow: TextOverflow.ellipsis,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: 30,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(children: [
            if (item.source.quality.name != "")
              IconWithLabel(
                padding: EdgeInsets.only(right: 10),
                iconWidget: Img.image("resolution.png", size: Size(14, 14)),
                text: item.source.quality.name,
                textStyle: Theme.of(context).textTheme.labelSmall,
              ),
            item.source.quality.resolution != ""
                ? IconWithLabel(
                    padding: EdgeInsets.only(right: 10),
                    iconWidget: Img.image("resolution.png", size: Size(14, 14)),
                    text: item.source.quality.resolution,
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  )
                : SizedBox.shrink(),
            (item.total != null && item.total! > 0)
                ? IconWithLabel(
                    padding: EdgeInsets.only(right: 10),
                    iconWidget: Img.image("storage.png", size: Size(14, 14)),
                    text: item.total!.toDouble().formatBytes(),
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  )
                : SizedBox.shrink()
          ]),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                "时长: ",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              Text(
                Utils.durationToString(item.time),
                style: TextStyle(
                  color: Skin.red,
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
              Spacer(),
              if (item.speed != null)
                Text(
                  item.speed!.formatDataRate(),
                  style: TextStyle(fontSize: 12),
                ),
            ],
          )
        ],
      );
    });
  }
}

class LeadingView extends StatelessWidget {
  final DownloadItem item;

  const LeadingView({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenHelper.getScreenSize(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      width: 150,
      height: 100,
      child: HoveringWidget(
        colorHover: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
        onTap: () async {
          if (item.source.url != null && !item.source.url!.startsWith("http")) {
            if (!await FileHelper.fileExist(item.source.url!)) {
              MyModal.notify(tr("file_not_exist"));
              return;
            }
          }
          Size? size;
          if (item.source.quality.resolution != null && item.source.quality.resolution!.isNotEmpty) {
            var q = item.source.quality.resolution!.split("x");
            size = Size(double.parse(q[0]), double.parse(q[1]));
          } else {
            size = Size(screenSize.width / 3 < 400 ? 400 : screenSize.width / 3, screenSize.height / 2 < 550 ? 550 : screenSize.height / 2);
          }
          DragOverlay.show(
            overlay: rootNavigatorKey.currentState!.overlay,
            context: context,
            view: MyPlayer(
              key: videoPlayerKey,
              source: item.source,
              size: size,
              onClose: () {
                DragOverlay.remove();
              },
            ),
            replace: false,
          );
        },
        borderRadius: BorderRadius.circular(10),
        hover: Center(
          child: Opacity(
            opacity: 0.7, // 透明度值，0.0 全透明，1.0 不透明
            child: Img.image("play.png", size: Size(40, 40)),
          ),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(2.0), // 设置圆角半径
            child: CustomCachedImage(
              imageUrl: item.cover,
              errorWidget: Img.image("no-pic.png", size: const Size(40, 40)),
              enableCache: true,
            )),
      ),
    );
  }
}

class TrailingView extends StatelessWidget {
  // final DownloadItemCubit itemCubit;
  // required this.itemCubit,
  final Function? onDeleted;
  const TrailingView({super.key, this.onDeleted});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadItemCubit, DownloadItemState>(builder: (context, state) {
      final item = state.item;
      if (item.status == TaskStatus.completed) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              onTap: () async {
                if (!await launchUrl(Uri.directory(item.savedPath!))) {
                  throw Exception('Could not launch ${item.savedPath!}');
                }
              },
              color: Theme.of(context).colorScheme.secondary,
              child: Text(
                "打开目录",
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
            ShareButton(
              onTap: (ClientCubit cubit) async {
                if (!await FileHelper.fileExist(item.source.url!)) {
                  MyModal.notify(tr("file_not_exist"));
                  return;
                }
                var fileModel = FileModel()
                  ..id = Utils.id
                  ..name = item.filename
                  ..size = item.total
                  ..type = FileHelper.classifyFileType(item.source.url!);
                cubit.onSendFile(
                  SendFileEvent(devices: [cubit.device], files: [FileWithFolder()..fileModel = fileModel], path: item.savedPath!),
                );
              },
            ),
          ],
        );
      }
      return CustomButton(
        onTap: () {
          SmartDialog.show(builder: (_) {
            return ConfirmDialog(
                title: '提示信息',
                content: "确认要停止此任务？",
                onConfirm: () {
                  context.read<DownloadItemCubit>().exit();
                  // itemCubit.exit();
                  SmartDialog.dismiss();
                  onDeleted?.call(item);
                });
          });
        },
        // isOutlined: true,
        color: Theme.of(context).colorScheme.secondary,
        // borderColor: Skin.primary,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Text(
          item.source.categroy == Categroy.living ? "结束录制" : "取消",
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSecondary),
        ),
        // ),
        // CustomButton(
        //   onTap: () {
        //     itemCubit.pasue();
        //   },
        //   isOutlined: true,
        //   color: Skin.primary,
        //   // borderColor: Skin.primary,
        //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        //   child: Text(
        //     "暂停",
        //     style: TextStyle(color: Skin.primary, fontSize: 12),
        //   ),
        // ),
        // CustomButton(
        //   onTap: () {
        //     itemCubit.resume();
        //   },
        //   isOutlined: true,
        //   color: Skin.primary,
        //   // borderColor: Skin.primary,
        //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        //   child: Text(
        //     "恢复",
        //     style: TextStyle(color: Skin.primary, fontSize: 12),
        //   ),
        // ),
        // ],
      );
    });
  }
}

class ShareButton extends StatelessWidget {
  final Function? onTap;
  const ShareButton({super.key, this.onTap});

  static List<ClientCubit> devices = [];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: BlocBuilder<CourierBloc, CourierState>(
        builder: (context, state) {
          if (state is CourierClientsLoaded) {
            Utils.updateList(devices, state.clients);
          } else if (state is CourierClientsDeleted) {
            devices.removeWhere((e) => state.ids.contains(e.device.physicsId));
          }
          if (devices.isEmpty) {
            return SizedBox.shrink();
          }
          return MenuAnchor(
            alignmentOffset: Offset(leftWidth - 120, headerHeight),
            menuChildren: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200), // 全局最大高度
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(devices.length, (i) {
                      final device = devices[i].device;
                      return MenuItemButton(
                        leadingIcon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            child: device.type.iconWithSize(Size(30, 30)),
                          ),
                        ),
                        onPressed: () {
                          onTap?.call(devices[i]);
                        },
                        child: Container(
                          width: 130,
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            device.name,
                            maxLines: 1,
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
            builder: (_, MenuController controller, Widget? child) {
              return CustomButton(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                onTap: () async {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text(
                  "发送到...",
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSecondary),
                ),
              );
            },
          );
        },
        buildWhen: (previous, current) {
          return current is CourierClientsLoaded || current is CourierClientsDeleted;
        },
      ),
    );
  }
}
