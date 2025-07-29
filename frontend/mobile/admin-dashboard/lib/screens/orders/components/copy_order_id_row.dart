import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';

class CopyOrderIdRow extends StatefulWidget {
  final String orderId;
  const CopyOrderIdRow({Key? key, required this.orderId}) : super(key: key);
  @override
  State<CopyOrderIdRow> createState() => CopyOrderIdRowState();
}

class CopyOrderIdRowState extends State<CopyOrderIdRow> {
  bool copied = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('ID : ${widget.orderId}'),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: copied
              ? IconButton(
                  key: ValueKey('check'),
                  icon: Icon(Icons.check, size: 20, color: Colors.green),
                  tooltip: 'Copié !',
                  onPressed: null,
                )
              : IconButton(
                  key: ValueKey('copy'),
                  icon: Icon(Icons.copy, size: 18, color: AppColors.primary),
                  tooltip: 'Copier l\'ID',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.orderId));
                    setState(() {
                      copied = true;
                    });
                    Future.delayed(Duration(milliseconds: 1200), () {
                      if (mounted) {
                        setState(() {
                          copied = false;
                        });
                      }
                    });
                  },
                ),
        ),
      ],
    );
  }
}
