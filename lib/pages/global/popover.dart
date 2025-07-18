import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sharebox/widgets/bubble_arrow.dart';
import 'package:sharebox/widgets/button.dart';

class Popover extends StatelessWidget {
  final Widget child;
  final bool show;
  final String confirmMessage;
  late ContextMenu? contextMenu;

  final Function? onComfirm;
  final Function? onCancel;

  Popover({
    super.key,
    required this.child,
    required this.show,
    required this.confirmMessage,
    this.onComfirm,
    this.onCancel,
  });

  _show(context) {
    if (SmartDialog.checkExist(tag: key.toString())) {
      return false;
    }
    final colorScheme = Theme.of(context).colorScheme;
    SmartDialog.showAttach(
      tag: key.toString(),
      clickMaskDismiss: false,
      maskColor: Colors.transparent,
      targetContext: context,
      targetBuilder: (targetOffset, targetSize) {
        return Offset(targetOffset.dx - 7, targetOffset.dy - 10);
      },
      alignment: Alignment.topCenter,
      animationType: SmartAnimationType.scale,
      builder: (BuildContext context) {
        return BubbleWidget(
          width: 300,
          height: 50,
          style: PaintingStyle.stroke,
          color: Colors.grey.withValues(alpha: 0.2),
          position: BubbleArrowDirection.bottom,
          borderColor: Color.fromRGBO(248, 246, 246, 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    confirmMessage,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                CustomButton(
                  onTap: onComfirm,
                  color: colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    "接受",
                    style: TextStyle(color: colorScheme.onPrimary, fontSize: 10),
                  ),
                ).animated,
                SizedBox(
                  width: 5,
                ),
                CustomButton(
                  onTap: onCancel,
                  color: colorScheme.error,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    "拒绝",
                    style: TextStyle(color: colorScheme.onError, fontSize: 10),
                  ),
                ).animated,
              ],
            ),
          ), // 阴影颜 ,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (show) {
      _show(context);
    } else {
      SmartDialog.dismiss(tag: key.toString());
    }
    return Material(color: Colors.transparent, child: child);
  }
}
