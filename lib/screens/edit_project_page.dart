import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:harmoniq/screens/tabs/ai_features_tab.dart';
import 'package:harmoniq/screens/tabs/midi_editor_tab.dart';
import 'package:harmoniq/screens/tabs/project_settings_tab.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:harmoniq/services/project_service.dart';

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

  final ProjectService _projectService = ProjectService();

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
    setState(() {});
  }

  Future<void> _onSaveProjectConfirmed() async {
    await _saveProjectToFirestore();
  }

  Future<void> _saveProjectToFirestore() async {
    try {
      await _projectService.saveProject(widget.project);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.savedSettings)),
        );
      }
    } on FirebaseAuthException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notAuthenticated),

            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error : $e'),

            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),

        bottom: TabBar(
          controller: _tabController,

          tabs: [
            Tab(
              icon: const Icon(Icons.edit),

              text: AppLocalizations.of(context)!.midiEditorTab,
            ),

            Tab(
              icon: const Icon(Icons.chat),

              text: AppLocalizations.of(context)!.aiFeaturesTab,
            ),

            Tab(
              icon: const Icon(Icons.settings),

              text: AppLocalizations.of(context)!.settingsTab,
            ),
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

            onSave: _onSaveProjectConfirmed,
          ),
        ],
      ),
    );
  }
}
