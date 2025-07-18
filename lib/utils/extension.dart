import 'package:flutter/material.dart';
import 'package:sharebox/models/device.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/widgets/image.dart';

extension DeviceTypeExtension on DeviceType {
  get icon {
    return iconWithSize(Size(40, 40));
  }

  Widget iconWithSize(Size size) {
    return Img.device(iconName, size: size);
  }

  get iconName {
    var iconName = "unknow";
    switch (this) {
      case DeviceType.mobile:
        iconName = "iphone";
        break;
      case DeviceType.desktop:
        iconName = "desktop";
        break;
      case DeviceType.web:
        iconName = "browser";
        break;
      default:
        iconName = "unknown";
    }
    return iconName;
  }
}

extension MyFileTypeExtension on MyFileType {
  Widget icon({Size? size = const Size(20, 20), Color? color}) {
    return Img.image("${name}_file.png", size: size, color: color);
  }
}
