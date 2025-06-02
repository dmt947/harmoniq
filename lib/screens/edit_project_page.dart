import 'package:flutter/material.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:harmoniq/screens/tabs/ai_features_tab.dart';
import 'package:harmoniq/screens/tabs/midi_editor_tab.dart';
import 'package:harmoniq/screens/tabs/project_settings_tab.dart';


class EditProjectPage extends StatefulWidget {
  final MusicProject project;

  const EditProjectPage({required this.project, super.key});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit)),
            Tab(icon: Icon(Icons.chat)),
            Tab(icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MidiEditorTab(project: widget.project),
          AIFeatures(),
          ProjectSettingsTab(project: widget.project),
        ],
      ),
    );
  }
}
