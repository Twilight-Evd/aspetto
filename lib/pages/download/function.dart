import 'package:bunny/pages/download/widget.dart';
import 'package:bunny/providers/download/cubit/download_cubit.dart';
import 'package:bunny/services/service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sharebox/utils/util.dart';

Future<void> showDownloadDialog(BuildContext context) async {
  final downloadCubit = context.read<DownloadCubit>();
  var s = await Services.readClipboard();

  if (s == "") {
    s = "https://dw.com";
  }
  if (s != "") {
    var url = Utils.matchUrlFromString(s);
    if (url != null && url != "") {
      downloadCubit.loadData(url);
    }
  }

  await SmartDialog.show(
    tag: "downloadImport",
    builder: (_) {
      return BlocProvider.value(
        value: downloadCubit, // 使用已获取的 Cubit 实例
        child: ParseView(),
      );
    },
  );

  downloadCubit.clearData();
}
