import 'package:flutter/material.dart';
import 'package:harmoniq/models/MusicProject.dart';

class ProjectSettingsTab extends StatelessWidget {
  final MusicProject project;

  const ProjectSettingsTab({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Pendiente...'));
  }
}
