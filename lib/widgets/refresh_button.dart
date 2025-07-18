import 'package:flutter/material.dart';
import 'package:sharebox/widgets/button.dart';
import 'package:sharebox/widgets/image.dart';

class RefreshButton extends StatefulWidget {
  final Size? size;
  final VoidCallback? onTap;
  const RefreshButton({super.key, this.size, this.onTap});

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomButton(
        child: Img.image("refresh.png", size: widget.size),
        onTap: () {
          widget.onTap?.call();
          _controller.reset();
          _controller.forward(); //
        },
      ),
    );
  }
}
