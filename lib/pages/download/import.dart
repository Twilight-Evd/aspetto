import 'package:bunny/models/record.dart';
import 'package:bunny/pages/download/function.dart';
import 'package:bunny/repositories/parsers/src/helper.dart';
import 'package:bunny/widgets/dashed.dart';
import 'package:flutter/material.dart';
import 'package:sharebox/widgets/hover.dart';
import 'package:sharebox/widgets/icon_label.dart';
import 'package:sharebox/widgets/image.dart';

class DownloadImportView extends StatelessWidget {
  final Function? onClose;
  const DownloadImportView({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    List<MediaPlatform> platforms = ParserHelper().getMediaPlatforms();

    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth;
        // 确保宽度在 minWidth 和 maxWidth 范围内变化
        if (constraints.maxWidth > 1200) {
          containerWidth = 1100;
        } else if (constraints.maxWidth < 1200) {
          containerWidth = 860;
        } else {
          containerWidth = constraints.maxWidth;
        }
        return AnimatedContainer(
          width: containerWidth,
          duration: Duration(milliseconds: 300), // 动画持续时间
          curve: Curves.linear, // 动画曲线
          child: Column(
            children: [
              CustomPaint(
                size: Size(containerWidth, 270), // 设定自定义绘制区域的大小
                painter: DashedBorderPainter(
                    color: colorScheme.secondary, radius: 15),
                child: HoveringWidget(
                  onTap: () async {
                    await showDownloadDialog(context);
                    onClose?.call();
                  },
                  borderRadius: BorderRadius.circular(15),
                  // colorNormal: Skin.gray200,
                  colorHover: colorScheme.tertiary.withValues(alpha: 0.5),
                  child: SizedBox(
                    height: 270,
                    width: containerWidth,
                    child: IconWithLabel(
                      space: 20,
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      iconWidget: Img.image("download.png",
                          color: colorScheme.onTertiary, size: Size(80, 80)),
                      text: "复制连接地址，点击这里开始下载",
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: colorScheme.onTertiary),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GridView.count(
                mainAxisSpacing: 15,
                crossAxisSpacing: 30,
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 2.8, // 调整宽高比以改变高度
                children: platforms.map((item) {
                  return HoveringWidget(
                    colorHover: Theme.of(context)
                        .colorScheme
                        .tertiary
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.tertiary,
                          width: 1,
                        ),
                      ),
                      child: IconWithLabel(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        iconWidget: Img.image(item.icon, size: Size(30, 30)),
                        text: item.name,
                        space: 0,
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: colorScheme.onPrimary),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
