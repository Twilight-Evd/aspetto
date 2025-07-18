import 'package:bunny/constants/global.dart';
import 'package:bunny/constants/sizes.dart';
import 'package:bunny/pages/global/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharebox/models/device.dart';
import 'package:sharebox/providers/courier/courier.dart';
import 'package:sharebox/utils/drag.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/utils/screen.dart';

void openChatbox(context, ClientCubit cubit, List<Device> devices) {
  try {
    final screenSize = ScreenHelper.getScreenSize(context);
    final colorScheme = Theme.of(context).colorScheme;

    DragOverlay.show(
      overlay: rootNavigatorKey.currentState!.overlay,
      context: context,
      replace: true,
      view: AnimatedContainer(
        key: chatBoxKey,
        margin: EdgeInsets.only(left: mainSpace, top: mainSpace),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // 阴影颜色
              blurRadius: 2.0, // 模糊半径
              spreadRadius: 2.0, // 扩散半径
              offset: Offset(0, 0), // 阴影偏移
            ),
          ],
        ),
        width: screenSize.width / 3 < 400 ? 400 : screenSize.width / 3,
        height: screenSize.height / 2 < 550 ? 550 : screenSize.height / 2,
        duration: Duration(milliseconds: 3300),
        child: BlocProvider<ClientCubit>.value(
          key: ValueKey("ChatScreen_${cubit.device.physicsId}"),
          value: cubit,
          child: ChatScreen(
            devices: devices,
            maxWidth: screenSize.width / 3 < 400 ? 400 : screenSize.width / 3,
            onClose: () async {
              DragOverlay.remove();
            },
          ),
        ),
      ),
    );
  } catch (e) {
    logger.e(e);
  }
}
