import 'dart:ui';

import 'package:flutter/material.dart';

class Backdrop extends StatelessWidget {
  final Widget child;

  const Backdrop({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Stack(
            // fit: StackFit.expand,
            children: [
              // 纯色背景
              Container(
                color: Colors.blue, // 设置背景颜色
              ),

              // 高斯模糊效果
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.white.withValues(alpha: 0), // 设置透明度
                ),
              ),
              Center(
                child: child,
              )
              // 前景内容
              // Center(
              //   child: Container(
              //     padding: const EdgeInsets.all(20),
              //     decoration: BoxDecoration(
              //       color: Colors.white.withValues(alpha:0.7),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: const Text(
              //       'Gaussian Blur Background',
              //       style: TextStyle(fontSize: 24),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
