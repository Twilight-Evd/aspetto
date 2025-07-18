import 'package:flutter/material.dart';
import 'package:sharebox/widgets/splash_widget.dart';
import 'package:sharebox/widgets/widget.dart';

import 'browser.dart';

class BrowserPage extends StatefulWidget {
  @override
  _BrowserPageState createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  int _currentIndex = 0;

  List<Key> tabs = [UniqueKey()];

  // int tabs = 1;

  void newTab() {
    setState(() {
      _currentIndex = tabs.length;
      tabs.add(UniqueKey());
    });
  }

  List<Widget> tabWidgets() {
    final colorScheme = Theme.of(context).colorScheme;
    List<Widget> tabWidget = [];

    for (int i = 0; i < tabs.length; i++) {
      tabWidget.add(
        Container(
          margin: EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: i == _currentIndex ? colorScheme.secondary : colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                offset: Offset(-2, -2),
                blurRadius: 4,
              )
            ],
          ),
          constraints: BoxConstraints(maxWidth: 150),
          child: CustomSplashWidget(
            translucent: true,
            onTap: () {
              setState(() {
                _currentIndex = i;
              });
            },
            splashColor: colorScheme.secondary.withValues(alpha: .3),
            child: IconWithLabel(
              iconWidget: GestureDetector(
                  onTap: () {
                    setState(() {
                      tabs.removeAt(i);
                      if (i <= _currentIndex) {
                        _currentIndex--;
                      }
                    });
                  },
                  child: Text("x")),
              labelWidget: Text(
                "标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1",
                maxLines: 1,
                style: TextStyle(
                  color: i == _currentIndex ? colorScheme.onSecondary : colorScheme.onPrimary,
                ),
              ),
              reversed: true,
            ),
          ),
        ),
      );
    }
    tabWidget.add(CustomButton(
      onTap: () {
        newTab();
      },
      icon: Img.image("add.png"),
      hoverText: "打开新标签",
    ).animated);
    return tabWidget;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          // color: Color(0xFFb1e7e1).withValues(alpha: .7),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: SingleChildScrollView(
            child: Row(children: tabWidgets()
                // tabs.map((tab) {
                //   return Container(
                //     margin: EdgeInsets.only(right: 5),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(5),
                //       color: colorScheme.secondary,
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withValues(alpha: 0.2),
                //           offset: Offset(2, 2),
                //           blurRadius: 4,
                //         ),
                //         BoxShadow(
                //           color: Colors.white.withValues(alpha: 0.3),
                //           offset: Offset(-2, -2),
                //           blurRadius: 4,
                //         )
                //       ],
                //       // color: Colors.amber,
                //     ),
                //     constraints: BoxConstraints(maxWidth: 150),
                //     child: IconWithLabel(
                //       iconWidget: Text("x"),
                //       labelWidget: Text(
                //         "标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1",
                //         maxLines: 1,
                //         style: TextStyle(
                //           color: colorScheme.onSecondary,
                //         ),
                //       ),
                //       reversed: true,
                //     ),
                //   );
                // }).toList();

                // [
                //   Container(
                //     margin: EdgeInsets.only(right: 5),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(5),
                //       color: colorScheme.secondary,
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withValues(alpha: 0.2),
                //           offset: Offset(2, 2),
                //           blurRadius: 4,
                //         ),
                //         BoxShadow(
                //           color: Colors.white.withValues(alpha: 0.3),
                //           offset: Offset(-2, -2),
                //           blurRadius: 4,
                //         )
                //       ],
                //       // color: Colors.amber,
                //     ),
                //     constraints: BoxConstraints(maxWidth: 150),
                //     child: IconWithLabel(
                //       iconWidget: Text("x"),
                //       labelWidget: Text(
                //         "标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1",
                //         maxLines: 1,
                //         style: TextStyle(
                //           color: colorScheme.onSecondary,
                //         ),
                //       ),
                //       reversed: true,
                //     ),
                //   ),
                //   Container(
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(5),

                //       // gradient: LinearGradient(
                //       //   begin: Alignment.topLeft,
                //       //   end: Alignment.bottomRight,
                //       //   colors: [
                //       //     Colors.amber.shade300,
                //       //     Colors.amber.shade400,
                //       //   ],
                //       // ),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withValues(alpha: 0.2),
                //           offset: Offset(2, 2),
                //           blurRadius: 4,
                //         ),
                //         BoxShadow(
                //           color: Colors.white.withValues(alpha: 0.3),
                //           offset: Offset(-2, -2),
                //           blurRadius: 4,
                //         )
                //       ],
                //       color: colorScheme.primary,
                //     ),
                //     constraints: BoxConstraints(maxWidth: 150),
                //     child: IconWithLabel(
                //       iconWidget: Text("x"),
                //       labelWidget: Text(
                //         "标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1标签1",
                //         maxLines: 1,
                //       ),
                //       reversed: true,
                //     ),
                //   ),
                //   CustomButton(
                //     onTap: () {
                //       newTab();
                //     },
                //     icon: Img.image("add.png"),
                //     hoverText: "打开新标签",
                //   ).animated
                // ],
                ),
          ),
        ),
        Expanded(
          child: IndexedStack(
              index: _currentIndex,
              children: tabs.map((tab) {
                return OnlinePage(
                    // key: tab,
                    );
              }).toList()

              // [
              //   OnlinePage(),
              //   OnlinePage(),
              //   OnlinePage(),
              // ],
              ),
        ),
      ],
    );
  }
}
