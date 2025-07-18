import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bunny/providers/setting/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharebox/widgets/button.dart';
import 'package:sharebox/widgets/image.dart';

class TitleHeader extends StatelessWidget {
  const TitleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Platform.isMacOS
              ? const SizedBox(
                  width: 90,
                )
              : const SizedBox.shrink(),
          Expanded(
              child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 5),
                  // child: Row(
                  //   mainAxisAlignment: Platform.isMacOS
                  //       ? MainAxisAlignment.center
                  //       : MainAxisAlignment.start,
                  //   children: [
                  //     Img.image("logo_nbg.png", size: Size(25, 25)),
                  //     SizedBox(
                  //       width: 5,
                  //     ),
                  //     Text(
                  //       tr("title"),
                  //       style: Theme.of(context)
                  //           .textTheme
                  //           .titleMedium
                  //           ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  //     )
                  //   ],
                  // ),
                  )),
          SizedBox(
            child: Flex(
              direction: Axis.horizontal,
              children: [
                BlocBuilder<SettingCubit, SettingState>(
                  builder: (context, state) {
                    return CustomButton(
                      onTap: () {
                        context.read<SettingCubit>().setAlwaysOnTop();
                      },
                      hoverText:
                          state.model.alwaysOnTop == true ? "取消置顶" : "置顶",
                      icon: state.model.alwaysOnTop == true
                          ? Img.image("unpin.png")
                          : Img.image("push-pin.png"),
                    ).animated;
                  },
                  buildWhen: (previous, current) {
                    return previous.model.alwaysOnTop !=
                        current.model.alwaysOnTop;
                  },
                ),
                CustomButton(
                  hoverText: "用户中心",
                  onTap: () {},
                  icon: Img.image("user.png"),
                ).animated,
              ],
            ),
          ),
          Platform.isWindows
              ? Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 20,
                      child: const VerticalDivider(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    const WindowButtons(),
                  ],
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}

// class HeaderBar extends StatelessWidget {
//   final List<Menu> menuData;
//   const HeaderBar({super.key, required this.menuData});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 5),
//       child: Flex(
//         direction: Axis.horizontal,
//         children: [
//           Platform.isMacOS
//               ? const SizedBox(
//                   width: 90,
//                 )
//               : const SizedBox.shrink(),
//           Expanded(
//               child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: List.generate(menuData.length, (int i) {
//               var menu = menuData[i];
//               return Container(
//                 margin: EdgeInsets.only(right: 20),
//                 child: AnimationWidget(
//                   onCompleted: () {
//                     GoRouter.of(context).go(menu.page);
//                   },
//                   key: Key(menu.name),
//                   child: CustomButton(
//                     onDoubleTap: () {},
//                     onTap: () {},
//                     borderRadius: 0,
//                     direction: Axis.vertical,
//                     icon: Icon(
//                       menu.icon,
//                     ),
//                     child: Text(
//                       menu.name,
//                       // style: TextStyle(
//                       //   fontSize: 10,
//                       // ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           )),
//           SizedBox(
//             child: Flex(
//               direction: Axis.horizontal,
//               children: [
//                 AnimationWidget(
//                   onCompleted: () {
//                     context.read<SettingCubit>().setAlwaysOnTop();
//                   },
//                   child: CustomButton(
//                     onTap: () {},
//                     color: Skin.transparent,
//                     icon: Icon(
//                       Icons.push_pin,
//                     ),
//                   ),
//                 ),
//                 AnimationWidget(
//                   child: CustomButton(
//                     onTap: () {},
//                     color: Skin.transparent,
//                     icon: Icon(
//                       Icons.account_circle,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Platform.isWindows
//               ? Row(
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 5),
//                       height: 20,
//                       child: const VerticalDivider(
//                         width: 1,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const WindowButtons(),
//                   ],
//                 )
//               : const SizedBox.shrink()
//         ],
//       ),
//     );
//   }
// }

// final GlobalKey _buttonKey = GlobalKey();

// class ProfileSetting extends StatefulWidget {
//   const ProfileSetting({super.key});

//   @override
//   ProfileSettingState createState() => ProfileSettingState();
// }

// class ProfileSettingState extends State<ProfileSetting> {
//   final ValueNotifier<bool> _show = ValueNotifier(false);

//   @override
//   initState() {
//     super.initState();
//   }

//   @override
//   dispose() {
//     super.dispose();
//     _show.dispose();
//   }

//   // Future<void> _showAttach(BuildContext ctx) async {
//   //   if (!SmartDialog.config.checkExist(
//   //     tag: "profileBox",
//   //   )) {
//   //     _show.value = true;

//   //     RenderBox renderBox =
//   //         _buttonKey.currentContext!.findRenderObject() as RenderBox;
//   //     Offset position = renderBox.localToGlobal(Offset.zero);
//   //     Size size = renderBox.size;

//   //     SmartDialog.showAttach(
//   //       tag: "profileBox",
//   //       targetContext: context,
//   //       usePenetrate: true,
//   //       clickMaskDismiss: true,
//   //       animationType: SmartAnimationType.fade,
//   //       keepSingle: true,
//   //       maskIgnoreArea: Rect.fromLTRB(position.dx, position.dy,
//   //           position.dx + size.width, position.dy + size.height),
//   //       builder: (_) {
//   //         return Container(
//   //             margin: const EdgeInsets.only(right: 10, top: 5),
//   //             child: ProfileDialog());
//   //       },
//   //     );
//   //   } else {
//   //     _show.value = false;
//   //     SmartDialog.dismiss(
//   //       tag: "profileBox",
//   //     );
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       key: _buttonKey,
//       onTap: () {
//         // _showAttach(context);
//         logger.d(">>>>>>>");
//       },
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           // Img.svg("person-circle", size: const Size(20, 20)),
//           Icon(
//             Icons.account_circle,
//             // color: Colors.black54,
//             size: 22.0,
//             // semanticLabel: 'Text to announce in accessibility modes',
//           ),
//           // Container(
//           //   margin: const EdgeInsets.symmetric(horizontal: 5),
//           //   child: ValueListenableBuilder(
//           //     valueListenable: _show,
//           //     builder: (context, value, child) {
//           //       return AnimatedRotation(
//           //         turns: value ? 0 : -0.5,
//           //         duration: const Duration(milliseconds: 200),
//           //         // child: Img.svg("caret-up-fill", size: const Size(10, 10)),
//           //       );
//           //     },
//           //   ),
//           // )
//         ],
//       ),
//     );
//   }
// }

// class ProfileDialog extends StatelessWidget {
//   const ProfileDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.blue,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       padding: const EdgeInsets.all(16.0),
//       width: 300,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Row(
//             children: [
//               CircleAvatar(
//                 radius: 24,
//                 backgroundColor: Colors.grey,
//                 child: Icon(Icons.person, color: Colors.white, size: 32),
//               ),
//               SizedBox(width: 12),
//               Text(
//                 '未登录',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               // Add login functionality here
//             },
//             style: ElevatedButton.styleFrom(
//               minimumSize: const Size(double.infinity, 48),
//               // primary: Colors.blue,
//             ),
//             child: const Text(
//               '登录',
//               style: TextStyle(fontSize: 18),
//             ),
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('设置'),
//             onTap: () {
//               // Add settings functionality here
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
