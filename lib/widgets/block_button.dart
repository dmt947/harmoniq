import 'package:flutter/material.dart';

class Blockbutton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const Blockbutton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: MediaQuery.of(context).size.width * 0.8, child: ElevatedButton(onPressed: onPressed, child: child),);
  }
}
