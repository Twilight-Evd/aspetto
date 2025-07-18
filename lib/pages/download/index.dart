import 'dart:io';

import 'package:bunny/constants/colors.dart';
import 'package:bunny/pages/download/function.dart';
import 'package:bunny/pages/download/import.dart';
import 'package:bunny/pages/download/list.dart';
import 'package:bunny/providers/download/download.dart';
import 'package:bunny/providers/setting/setting.dart';
import 'package:bunny/services/service.dart';
import 'package:bunny/widgets/path_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharebox/utils/extensions/ext.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/widgets/modal_widget.dart';
import 'package:sharebox/widgets/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State createState() => _DownloadPageState();
}

class _DownloadPageState extends State with SingleTickerProviderStateMixin {
  final ValueNotifier<int> toggleIndex = ValueNotifier(0);
  late final DownloadListCubit cubit;
  @override
  void initState() {
    cubit = context.read<DownloadListCubit>();
    toggleIndex.addListener(() {
      cubit.loadData(toggleIndex.value);
    });
    cubit.loadData(0);
    super.initState();
  }

  @override
  void dispose() {
    toggleIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Positioned(
                left: 0,
                child:
                    // MenuAnchor(
                    //   builder: (BuildContext context, MenuController controller,
                    //       Widget? child) {
                    //     return Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    CustomButton(
                  onTap: () async {
                    // if (controller.isOpen) {
                    //   controller.close();
                    // } else {
                    //   controller.open();
                    // }
                    // DownloadListCubit cubit = context.read<DownloadListCubit>();
                    await showDownloadDialog(context);
                    if (toggleIndex.value != 0) {
                      toggleIndex.value = 0;
                    } else {
                      cubit.loadData(0);
                    }
                  },
                  isOutlined: true,
                  color: colorScheme.primary,
                  borderRadius: 5,
                  padding:
                      EdgeInsets.only(left: 5, top: 3, bottom: 3, right: 10),
                  icon: Img.image("add.png",
                      color: colorScheme.primary, size: Size(18, 18)),
                  child: Text(
                    "粘贴地址",
                    style: TextStyle(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                //   ],
                // );
                //   // },
                //   menuChildren: List<MenuItemButton>.generate(
                //     3,
                //     (int index) => MenuItemButton(
                //       // onPressed: () => setState(
                //       //     () => selectedMenu = SampleItem.values[index]),
                //       child: Text('Item ${index + 1}'),
                //     ),
                //   ),
                // ),
              ),
              Align(
                alignment: Alignment.center,
                child: IntrinsicWidth(
                  child: ToggleButton(
                    fillColor: colorScheme.secondary,
                    selectedColor: colorScheme.primary,
                    textColor: colorScheme.onSecondary,
                    selectedTextcolor: colorScheme.onPrimary,
                    constraints: BoxConstraints(
                      minHeight: 35.0,
                      minWidth: 200.0,
                    ),
                    children: ["下载中", "已下载"],
                    selected: toggleIndex,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: ValueListenableBuilder(
          valueListenable: toggleIndex,
          builder: (context, value, child) {
            return BlocBuilder<DownloadListCubit, DownloadListState>(
                builder: (context, state) {
              state.isLoading ? MyModal.loading() : MyModal.close();
              return IndexedStack(
                alignment: AlignmentDirectional.center,
                index: value,
                children: [
                  state.items.isNotEmpty
                      ? DownloadListView(
                          items: state.items,
                          onDeleted: (_) {
                            cubit.loadData(0);
                          },
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DownloadImportView(
                              onClose: () {
                                cubit.loadData(0);
                              },
                            ),
                          ],
                        ),
                  DownloadListView(
                      items: state.completedItems,
                      onDeleted: (_) {
                        cubit.loadData(1);
                      })
                ],
              );
            });
          },
        )),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor))),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ValueListenableBuilder(
            valueListenable: toggleIndex,
            builder: (context, value, child) {
              if (value == 1) {
                return BlocBuilder<DownloadListCubit, DownloadListState>(
                    builder: (context, state) {
                  int total = state.completedItems.fold(
                      0,
                      (previousValue, element) =>
                          previousValue +
                          (element.item.total != null
                              ? element.item.total!
                              : 0));
                  return Center(
                      child: Text(
                    "${state.completedItems.length} 任务 | ${total.toDouble().formatBytes()}",
                    style: TextStyle(
                      color: colorScheme.secondary,
                    ),
                  ));
                });
              }
              return BlocBuilder<SettingCubit, SettingState>(
                  builder: (context, state) {
                return Row(
                  children: [
                    Text(
                      "存储到：",
                      // style: TextStyle(color: Skin.white),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    PathMenu(
                      path: state.model.downloadPath,
                      updatePath: (path) async {
                        SettingCubit cubit = context.read<SettingCubit>();
                        Directory dir = await Services.toAppPath(path);
                        cubit.setDownloadPath(dir);
                      },
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    CustomButton(
                      hoverText: "打开文件夹",
                      onTap: () async {
                        logger.d(state.model.downloadPath);
                        if (!await launchUrl(
                            Uri.directory(state.model.downloadPath))) {
                          logger.d(
                              'Could not launch ${state.model.downloadPath}');
                          throw Exception(
                              'Could not launch ${state.model.downloadPath}');
                        }
                      },
                      color: Skin.transparent,
                      icon: Img.image(
                        "open_folder.png",
                      ),
                    )
                  ],
                );
              });
            },
          ),
        )
      ],
    );
  }
}
