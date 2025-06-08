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
  
  double _globalZoomLevel = 2.0; 

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

  void _updateGlobalZoom(double newZoom) {
    setState(() {
      _globalZoomLevel = newZoom;
    });
  }

  void _onProjectChanged() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Editor MIDI'), 
            Tab(icon: Icon(Icons.chat), text: 'IA'),     
            Tab(icon: Icon(Icons.settings), text: 'Ajustes'), 
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MidiEditorTab(
            project: widget.project,
            zoomLevel: _globalZoomLevel,
            onZoomChanged: _updateGlobalZoom,
          ),
          AiFeaturesTab(
            project: widget.project,
            onProjectChanged: _onProjectChanged,
          ),
          ProjectSettingsTab(
            project: widget.project,
            onProjectChanged: _onProjectChanged,
          ),
        ],
      ),
    );
  }
}
