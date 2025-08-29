import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../constants.dart';

class CopyTextIcon extends StatefulWidget {
  final String value;
  final String? tooltip;
  final double iconSize;
  final Color? color;
  const CopyTextIcon({
    Key? key,
    required this.value,
    this.tooltip,
    this.iconSize = 18,
    this.color,
  }) : super(key: key);

  @override
  State<CopyTextIcon> createState() => _CopyTextIconState();
}

class _CopyTextIconState extends State<CopyTextIcon> {
  bool copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    setState(() => copied = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: copied
          ? IconButton(
              key: const ValueKey('check'),
              icon:
                  Icon(Icons.check, size: widget.iconSize, color: Colors.green),
              tooltip: 'Copié !',
              onPressed: null,
            )
          : IconButton(
              key: const ValueKey('copy'),
              icon: Icon(Icons.copy,
                  size: widget.iconSize, color: widget.color ?? AppColors.info),
              tooltip: widget.tooltip ?? 'Copier',
              onPressed: _copy,
            ),
    );
  }
}
