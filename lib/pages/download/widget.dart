import 'package:bunny/constants/theme.dart';
import 'package:bunny/providers/download/download.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/util.dart';
import 'package:sharebox/widgets/dialog.dart';
import 'package:sharebox/widgets/modal_widget.dart';
import 'package:sharebox/widgets/widget.dart';

class ParseView extends StatelessWidget {
  ParseView({super.key});

  TextEditingController tec = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<DownloadCubit, DownloadState>(
      builder: (context, state) {
        if (state.url != null && state.url != "") {
          Widget child;
          if (state.isLoading) {
            child = SizedBox(
              height: 200,
              child: LoadingView(),
            );
          } else if (state.error != null) {
            // 如果异步任务出现错误，显示错误信息
            child = ErrorView();
          } else {
            child = MediaListView(state: state);
          }
          String head = state.url ?? "";
          if (state.media != null) {
            List<String> heads = [];
            if (state.media!.title != "") {
              heads.add(state.media!.title);
            }
            if (state.media!.author != null) {
              heads.add("(${state.media!.author!.name})");
            }
            heads.add(state.media!.platform.name);
            head = heads.join(" - ");
          }
          return MyDialog(
            width: 460,
            bgColor: bgColor,
            header: head,
            bottom: CustomButton(
              onTap: () async {
                final rs = await context.read<DownloadCubit>().toDownload();
                if (rs == true) {
                  SmartDialog.dismiss(tag: "downloadImport");
                }
              },
              disabled: state.selection == null || !state.selection!.enabledBtn() || state.isLoading,
              color: colorScheme.primary,
              disabledColor: colorScheme.onSurface,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: Text(
                "下载",
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
            child: child,
            onClose: () {},
          );
        } else {
          return MyDialog(
            width: 460,
            header: "内容解析",
            bgColor: bgColor,
            bottom: ValueListenableBuilder(
              valueListenable: tec,
              builder: (context, value, child) {
                bool enable = false;
                var url = Utils.matchUrlFromString(value.text);
                if (url != null && url != "") {
                  enable = true;
                }
                return CustomButton(
                  onTap: () {
                    if (url != null) {
                      context.read<DownloadCubit>().loadData(url);
                    }
                  },
                  disabled: !enable,
                  color: colorScheme.primary,
                  disabledColor: colorScheme.onSurface,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: Text(
                    "解析",
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                );
              },
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("请将复制的分享内容或网页地址粘贴到这里", style: TextStyle(color: colorScheme.onPrimary)),
                SizedBox(height: 10),
                CustomFormTextField(
                  style: TextStyle(color: colorScheme.onPrimary),
                  controller: tec,
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "该项为必填项"; // 表示不验证错误
                    }
                    var url = Utils.matchUrlFromString(value);
                    if (url != null && url != "") {
                      return null;
                    }
                    return "内容中需要包含要解析的网址"; // 表示不验证错误
                  },
                )
              ],
            ),
          );
        }
      },
      listener: (BuildContext context, DownloadState state) {
        if (state.selection != null && state.selection!.error != "") {
          MyModal.toast("暂时无法找到该资源，请选择其他");
        }
      },
    );
  }
}

class MediaListView extends StatelessWidget {
  DownloadState state;

  MediaListView({super.key, required this.state});

  List<Widget> dataToWiew(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final records = state.media;
    final List<Widget> widgets = [];

    final video = state.selection?.video; //, audio = state.selection?.audio;
    // images = state.selection?.images ?? [];

    logger.d(">>>>>>>>>>>. video : $video");
    DownloadCubit dc = context.read<DownloadCubit>();
    if (records != null) {
      if (records.videos != null && records.videos!.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: IconWithLabel(
            iconWidget: Img.image("video.png", size: Size(30, 30)),
            text: "视频",
            textStyle: textTheme.titleMedium!.copyWith(color: colorScheme.onTertiary),
          ),
        ));

        for (var i = 0; i < records.videos!.length; i++) {
          final source = records.videos![i];
          widgets.add(CustomListTile(
            onTap: () {
              dc.selectMedia(video: i);
            },
            colorHover: colorScheme.tertiary.withValues(alpha: 0.3),
            leading: IconWithLabel(
              iconWidget: video == i ? Img.image("checked.png") : Img.image("check.png"),
              text: "MP4",
              textStyle: textTheme.titleSmall!.copyWith(color: colorScheme.onTertiary),
            ),
            trailing: Container(
              alignment: Alignment.centerRight,
              constraints: BoxConstraints(minWidth: 80),
              child: Text(
                source.quality.resolution != null ? source.quality.resolution! : "-",
                style: textTheme.titleSmall!.copyWith(color: colorScheme.onTertiary),
              ),
            ),
            child: Center(
                child: Text(
              source.quality.name,
              style: textTheme.titleSmall!.copyWith(color: colorScheme.onTertiary),
            )),
          ));
        }
      }
    }

    // logger.d("<><<<  ${records.audio}");
    // if (records.audio != null && records.audio!.isNotEmpty) {
    //   widgets.add(Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 10),
    //     child: IconWithLabel(
    //       iconWidget: Img.image("music.png", size: Size(30, 30)),
    //       text: "音频",
    //       fontSize: 18,
    //     ),
    //   ));
    //   widgets.add(CustomListTile(
    //     onTap: () {
    //       dc.selectMedia(audio: records.audio);
    //     },
    //     colorHover: Theme.of(context).colorScheme.tertiary.withValues(alpha:0.3),
    //     leading: IconWithLabel(
    //       iconWidget: audio != null && audio == records.audio
    //           ? Img.image("checked.png")
    //           : Img.image("check.png"),
    //       text: "MP3",
    //       fontSize: 14,
    //     ),
    //     trailing: Text(""),
    //     child: Center(child: Text("")),
    //   ));
    // }

    // if (records.coverUrl != "" ||
    //     (records.author != null && records.author!.avatar != "")) {
    //   widgets.add(Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 10),
    //     child: IconWithLabel(
    //       icon: Icons.image,
    //       text: "图片",
    //       iconSize: 30,
    //       fontSize: 18,
    //     ),
    //   ));
    // if (records.author != null && records.author!.avatar != "") {
    //   widgets.add(CustomListTile(
    //     onTap: () {
    //       if (images.contains("avatar")) {
    //         images.remove("avatar");
    //       } else {
    //         images.add("avatar");
    //       }
    //       dc.selectMedia(images: images);
    //     },
    //     backgroundColor: Colors.transparent,
    //     leading: IconWithLabel(
    //       icon: images.contains("avatar")
    //           ? Icons.check_box
    //           : Icons.check_box_outline_blank,
    //       text: "主播头像",
    //       iconSize: 20,
    //       fontSize: 14,
    //     ),
    //     trailing: Text(""),
    //     child: Center(child: Text("")),
    //   ));
    // }
    // if (records.coverUrl != "") {
    //   widgets.add(CustomListTile(
    //     onTap: () {
    //       if (images.contains("cover")) {
    //         images.remove("cover");
    //       } else {
    //         images.add("cover");
    //       }
    //       dc.selectMedia(images: images);
    //     },
    //     backgroundColor: Colors.transparent,
    //     leading: IconWithLabel(
    //       icon: images.contains("cover")
    //           ? Icons.check_box
    //           : Icons.check_box_outline_blank,
    //       text: "封面",
    //       iconSize: 20,
    //       fontSize: 14,
    //     ),
    //     trailing: Text(""),
    //     child: Center(child: Text("")),
    //   ));
    // }
    // }
    // }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: dataToWiew(context),
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(
          height: 10,
        ),
        Text("正在解析"),
      ],
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: IconWithLabel(
              iconWidget: Img.image("link-off.png", size: Size(36, 36)),
              text: "解析失败",
              textStyle: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text("可能原因："),
          Text("1.你复制的地址不支持下载。"),
          Text("2.当前地址可能需要会员才能访问。"),
          Text("3.系统暂未支持该网站下载。"),
          Text("4.网络不稳定，暂时无法读取资源。"),
          SizedBox(
            height: 20,
          ),
          Text("提示*"),
          Text("1.请确保网络稳定。"),
          Text("2.请检查地址，关闭弹窗后重试。"),
          Text("3.如仍然失败，请联系我们获取最新版本。"),
        ],
      ),
    );
  }
}
