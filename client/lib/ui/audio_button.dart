import 'package:flutter/material.dart';

class AudioButton extends StatelessWidget {
  // 인자 선언
  final String label;
  final VoidCallback onPressed;
  const AudioButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
