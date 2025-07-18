import 'package:bunny/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sharebox/widgets/button.dart';
import 'package:sharebox/widgets/dialog.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final Function onConfirm;
  final Function? onCancel;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      width: 300,
      height: 170,
      header: title,
      bgColor: bgColor,
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            onTap: () {
              SmartDialog.dismiss();
              onCancel?.call();
            },
            borderRadius: 5,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Text(
              "取消",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
            ),
          ).animated,
          SizedBox(width: 10.0),
          CustomButton(
            onTap: () {
              onConfirm();
              SmartDialog.dismiss();
            },
            borderRadius: 5,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              "确定",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 12),
            ),
          ).animated,
        ],
      ),
      child: Text(
        content,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
