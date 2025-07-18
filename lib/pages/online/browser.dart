import 'dart:collection';

import 'package:bunny/router.dart';
import 'package:bunny/services/service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/widgets/widget.dart';
import 'package:url_launcher/url_launcher.dart';

InAppWebViewSettings settings = InAppWebViewSettings(
  transparentBackground: true,
  isInspectable: kDebugMode,
  mediaPlaybackRequiresUserGesture: false,
  allowsInlineMediaPlayback: true,
  iframeAllow: "camera; microphone",
  iframeAllowFullscreen: true,
);

class OnlinePage extends StatefulWidget {
  const OnlinePage({super.key});

  @override
  State createState() => _OnlinePageState();
}

class _OnlinePageState extends State<OnlinePage> {
  // final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  CookieManager cookieManager = CookieManager.instance();
  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    logger.d(">>>>>>>>>>>>>>>>>>> init ${widget.key}");
    router.routerDelegate.addListener(() {
      final name = GoRouter.of(context).state?.name;
      if (name != null && name == "browser") {
        logger.d(webViewController);
        logger.d(urlController.text);
        if (webViewController == null) {
          setState(() {});
        }
      } else {
        logger.d("?????????? $webViewController");
        // webViewController?.dispose();
      }
      // logger.d(">>>>>>>>>>>>> ${GoRouter.of(context).state?.name}");
    });

    // contextMenu = ContextMenu(
    //     menuItems: [
    //       ContextMenuItem(
    //           id: 1,
    //           title: "Special",
    //           action: () async {
    //             print("Menu item Special clicked!");
    //             print(await webViewController?.getSelectedText());
    //             await webViewController?.clearFocus();
    //           })
    //     ],
    //     settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
    //     onCreateContextMenu: (hitTestResult) async {
    //       print("onCreateContextMenu");
    //       print(hitTestResult.extra);
    //       print(await webViewController?.getSelectedText());
    //     },
    //     onHideContextMenu: () {
    //       print("onHideContextMenu");
    //     },
    //     onContextMenuActionItemClicked: (contextMenuItemClicked) async {
    //       var id = contextMenuItemClicked.id;
    //       print("onContextMenuActionItemClicked: " +
    //           id.toString() +
    //           " " +
    //           contextMenuItemClicked.title);
    //     });

    // pullToRefreshController = kIsWeb ||
    //         ![TargetPlatform.iOS, TargetPlatform.android]
    //             .contains(defaultTargetPlatform)
    //     ? null
    //     : PullToRefreshController(
    //         settings: PullToRefreshSettings(
    //           color: Colors.blue,
    //         ),
    //         onRefresh: () async {
    //           if (defaultTargetPlatform == TargetPlatform.android) {
    //             webViewController?.reload();
    //           } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    //             webViewController?.loadUrl(
    //                 urlRequest:
    //                     URLRequest(url: await webViewController?.getUrl()));
    //           }
    //         },
    //       );
  }

  @override
  void dispose() {
    super.dispose();
    urlController.dispose();
    webViewController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // color: Color(0xFFb1e7e1).withValues(alpha: .7),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              CustomButton(
                onTap: () {
                  webViewController?.goBack();
                },
                icon: Img.image("left.png"),
              ).animated,
              CustomButton(
                onTap: () {
                  webViewController?.goForward();
                },
                icon: Img.image("right.png"),
              ).animated,
              CustomButton(
                onTap: () {
                  webViewController?.reload();
                },
                icon: Img.image("refresh.png"),
              ).animated,
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomFormTextField(
                  radius: Radius.circular(3),
                  controller: urlController,
                  onSubmitted: (value) {
                    logger.d(webViewController);
                    var url = WebUri(value);
                    if (url.scheme.isEmpty) {
                      url = WebUri((!kIsWeb ? "https://www.google.com/search?q=" : "https://www.bing.com/search?q=") + value);
                    }
                    logger.d("?>???? ${webViewController} $value");
                    webViewController?.loadUrl(urlRequest: URLRequest(url: url));
                  },
                ),
              ),
              CustomButton(
                icon: Img.image("download2.png", size: Size(30, 30)),
              ).animated
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: InAppWebView(
                  key: widget.key,
                  webViewEnvironment: Services.webViewEnvironment,
                  initialUrlRequest: URLRequest(url: WebUri('https://douyin.com/')),
                  // initialUrlRequest:
                  // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
                  // initialFile: "assets/index.html",
                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                  initialSettings: settings,
                  // contextMenu: contextMenu,
                  // pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) async {
                    logger.d("created......");
                    logger.d(controller.getTitle());
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) async {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(resources: request.resources, action: PermissionResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    // pullToRefreshController?.endRefreshing();
                    logger.d(controller.getTitle());
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onReceivedError: (controller, request, error) {
                    // pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) async {
                    if (progress == 100) {
                      // pullToRefreshController?.endRefreshing();

                      // List<Cookie> cookies = await cookieManager.getCookies(url: WebUri(url));
                      // logger.d("cookies is : $cookies");
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    logger.d(consoleMessage);
                  },
                ),
              ),
              if (progress > 0 && progress < 1.0)
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                )
            ],
          ),
        ),
      ],
    );
  }
}
