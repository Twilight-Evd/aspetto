import 'dart:io';

import 'package:bunny/models/record.dart';
import 'package:bunny/widgets/loading/circle.dart';
import 'package:flutter/material.dart';
import 'package:sharebox/utils/log.dart';
import 'package:sharebox/widgets/animation_widget.dart';
import 'package:sharebox/widgets/image.dart';
import 'package:video_player/video_player.dart';

class MyPlayer extends StatefulWidget {
  final Source source;
  final Size? size;
  final Function? onClose;
  const MyPlayer({
    super.key,
    required this.source,
    this.size,
    this.onClose,
  });
  @override
  State<MyPlayer> createState() => MyPlayerState();
}

class MyPlayerState extends State<MyPlayer> {
  late VideoPlayerController _controller;

  Size? size;
  @override
  void initState() {
    super.initState();
    if (widget.size != null) {
      size = Size(400, 400 / widget.size!.width * widget.size!.height);
    }
    if (widget.source.url!.startsWith("http")) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.source.url!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else {
      _controller = VideoPlayerController.file(File(widget.source.url!));
    }
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  Future<bool> started() async {
    if (_controller.value.isInitialized) {
      return true;
    }
    await _controller.initialize();

    final width = _controller.value.size.width;
    final height = _controller.value.size.height;
    if (size == null) {
      if (width >= height) {
        size = Size.fromWidth(size!.width);
      } else {
        size = Size.fromWidth(size!.height);
      }
    }
    await _controller.play();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    logger.d(widget.source.url);
    return Center(
      child: FutureBuilder<bool>(
        future: started(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return AnimatedSize(
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                // border:
                //     Border.all(color: Theme.of(context).colorScheme.secondary),
                borderRadius: BorderRadius.circular(13),
              ),
              width: size?.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  (snapshot.data ?? false)
                      ? IntrinsicHeight(
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: VideoPlayer(_controller)),
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          width: 200,
                          child: SpinKitCircle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: AnimationWidget(
                      hoverText: "关闭",
                      onCompleted: () {
                        widget.onClose?.call();
                      },
                      child: Img.image("delete.png", color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
