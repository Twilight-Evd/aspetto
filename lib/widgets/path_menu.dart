import 'dart:io';

import 'package:bunny/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:sharebox/utils/path.dart';
import 'package:sharebox/utils/util.dart';
import 'package:sharebox/widgets/image.dart';

class PathMenu extends StatelessWidget {
  final String path;
  final Function updatePath;
  const PathMenu({super.key, required this.path, required this.updatePath});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      alignmentOffset: Offset(0, -110),
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(colorScheme.tertiary),
      ),
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: child);
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () async {
            Directory? download = await PathHelper.getDirectory();
            if (download != null) {
              updatePath.call(download.path);
            }
          },
          child: Text(
            "流览并选择存储目录",
            style: TextStyle(color: colorScheme.onTertiary),
          ),
        ),
        MenuItemButton(
          onPressed: () {},
          child: Text(
            Utils.truncateWithEllipsis(path, 31),
            style: TextStyle(
                color: colorScheme.onTertiary, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      child: Container(
        constraints: BoxConstraints(maxWidth: 300), // 设定最大宽度
        padding: EdgeInsets.only(left: 5, top: 3, bottom: 3, right: 5),
        decoration: BoxDecoration(
          color: colorScheme.tertiary,
          border: Border.all(color: colorScheme.tertiary),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Utils.truncateWithEllipsis(path, 30),
              style: TextStyle(
                  color: colorScheme.onTertiary,
                  overflow: TextOverflow.ellipsis),
            ),
            SizedBox(
              width: 2,
            ),
            Img.image("dropdown.png",
                color: colorScheme.onTertiary, size: Size(14, 14))
          ],
        ),
      ),
    );
  }
}
