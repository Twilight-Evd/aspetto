import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bunny/constants/sizes.dart';
import 'package:bunny/constants/theme.dart';
import 'package:bunny/pages/global/notification.dart';
import 'package:bunny/pages/left.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'header.dart';

class Layout extends StatelessWidget {
  final StatefulNavigationShell child;
  const Layout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WindowBorder(
            color: Colors.transparent,
            width: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomCenter, colors: [
                  const Color.fromARGB(255, 110, 242, 226),
                  Color.fromARGB(255, 247, 207, 196),
                  Color.fromRGBO(245, 184, 167, 1),
                ]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: MoveWindow(
                      child: const TitleHeader(),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        LeftView(
                          width: leftWidth,
                          navigationShell: child,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)
                                //  BorderRadius.only(
                                //   topLeft: Radius.circular(10),
                                //   topRight: Radius.circular(10),
                                //   bottomLeft: Radius.circular(10),
                                //   bottomRight: Radius.circular(10),
                                // ),
                                ),
                            margin: EdgeInsets.only(right: mainSpace, bottom: mainSpace),
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: headerHeight - 5,
            right: 0,
            child: CustomNotification(),
          ),
        ],
      ),
    );
  }
}
