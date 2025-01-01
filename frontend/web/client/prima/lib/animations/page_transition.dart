import 'package:flutter/material.dart';

class CustomPageTransition extends PageRouteBuilder {
  final Widget child;

  CustomPageTransition({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOutCubic;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

class SlidePageView extends StatelessWidget {
  final PageController controller;
  final List<Widget> children;
  final ValueChanged<int>? onPageChanged;

  const SlidePageView({
    super.key,
    required this.controller,
    required this.children,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: children.length,
      physics: const BouncingScrollPhysics(),
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            double value = 1.0;
            if (controller.position.haveDimensions) {
              value = (controller.page! - index).abs();
              value = (1 - (value.clamp(0.0, 1.0))).toDouble();
            }
            return Transform.scale(
              scale: 0.9 + (value * 0.1),
              child: Opacity(
                opacity: 0.5 + (value * 0.5),
                child: child,
              ),
            );
          },
          child: children[index],
        );
      },
    );
  }
}
