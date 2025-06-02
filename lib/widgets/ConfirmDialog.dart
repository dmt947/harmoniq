import 'package:flutter/material.dart';

class ConfirmDialog extends AlertDialog {
  final String confirmTitle;
  final String confirmContent;
  final String cancelLabel;
  final String acceptLabel;
  final VoidCallback onCancel;
  final VoidCallback onAccept;

  const ConfirmDialog({
    required this.confirmTitle,
    required this.confirmContent,
    required this.cancelLabel,
    required this.acceptLabel,
    required this.onCancel,
    required this.onAccept,
  });
}
