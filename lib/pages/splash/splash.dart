import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bunny/constants/sizes.dart';
import 'package:bunny/services/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sharebox/widgets/image.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  void completeInit(BuildContext context) async {
    appWindow.minSize = minWindowSize;
    appWindow.size = minWindowSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
    GoRouter.of(context).go("/");
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return WindowBorder(
      color: Colors.transparent,
      width: 1,
      child: MoveWindow(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 110, 242, 226),
                Color.fromARGB(255, 247, 207, 196),
                Color.fromRGBO(245, 184, 167, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CloseWindowButton(
                    colors: WindowButtonColors(
                        mouseOver: const Color(0xFFD32F2F),
                        mouseDown: const Color(0xFFB71C1C),
                        iconNormal: const Color(0xFF805306),
                        iconMouseOver: Colors.white)),
              ),
              SizedBox(
                height: 90,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Img.image("logo_icon.png", size: Size(110, 110)),
                      ],
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        Text(
                          tr("title"),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondary,
                          ),
                        ),
                        Text(
                          "Bunny Video",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            // fontStyle: FontStyle.italic,
                            color: colorScheme.onSecondary,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '版本号: 1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSecondary,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Copyright © 2024 Bunny Video. All Rights Reserved.',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 5),
                  child: Text(
                    '系统正在初始化，请稍等...',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              StreamBuilder<double>(
                stream: Services.ensureInitialized(),
                builder: (contextx, snapshot) {
                  final progress = snapshot.data ?? 0.0;
                  if (snapshot.connectionState == ConnectionState.done) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      completeInit(context);
                    });
                  }
                  return LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 110, 242, 226)),
                    value: progress,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
