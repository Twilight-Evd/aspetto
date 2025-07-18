import 'package:bunny/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sharebox/widgets/hover.dart';
import 'package:sharebox/widgets/icon_label.dart';
import 'package:sharebox/widgets/image.dart';

class LeftView extends StatelessWidget {
  final double width;
  final StatefulNavigationShell navigationShell;
  const LeftView({
    super.key,
    required this.width,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    var titleMedium = Theme.of(context).textTheme.titleMedium;
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Img.image("logo_nbg.png", size: Size(65, 65)),
              SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr("title"),
                    style: titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    "Bunny Video",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onPrimary,
                        ),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 220),
                      curve: Curves.easeInCirc,
                      top: navigationShell.currentIndex * 57,
                      child: Container(
                        width: 226,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(157, 246, 235, 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Column(
                      children: List.generate(
                        routes.length,
                        (int i) {
                          var menu = routes[i];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            width: 226,
                            child: HoveringWidget(
                              alignment: Alignment.centerLeft,
                              colorHover: Color.fromRGBO(157, 246, 235, 0.4),
                              onTap: () {
                                navigationShell.goBranch(i);
                              },
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: IconWithLabel(
                                padding: EdgeInsets.only(left: 10),
                                space: 10,
                                iconWidget: Img.image("${menu.name}.png",
                                    size: Size(25, 25),
                                    color: colorScheme.onPrimary),
                                text: "menu".tr(gender: menu.name), //"直播下载",
                                textStyle: titleMedium!
                                    .copyWith(color: colorScheme.onPrimary),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          IconWithLabel(
            iconWidget: Img.image("edit.png", size: Size(18, 18)),
            text: "提交平台",
            textStyle: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}
