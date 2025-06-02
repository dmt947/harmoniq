import 'package:flutter/material.dart';
import 'package:harmoniq/models/music_project.dart';

class MidiEditorTab extends StatelessWidget {
  final MusicProject project;

  const MidiEditorTab({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Pendiente...'));
  }
}
