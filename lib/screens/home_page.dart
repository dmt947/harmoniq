import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:harmoniq/screens/edit_project_page.dart';
import 'package:harmoniq/screens/settings_page.dart';
import 'package:harmoniq/services/player_service.dart';
import 'package:harmoniq/services/project_service.dart';
import 'package:harmoniq/theme/harmoniq_colors.dart';
import 'package:harmoniq/widgets/project_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProjectService _projectService = ProjectService();
  final PlayerService _playerService = PlayerService();

  @override
  void initState() {
    super.initState();
  }

  void _playProject(MusicProject project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          AppLocalizations.of(context)!.playerPlaying(project.name),
        ),
      ),
    );
    _playerService.playTrack(project: project);
  }

  void _deleteProject(MusicProject project) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Theme.of(context).highlightColor,
            title: Text(
              AppLocalizations.of(context)!.deleteProjectConfirmTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Text(
              AppLocalizations.of(
                context,
              )!.deleteProjectConfirmContent(project.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _projectService.deleteProject(project.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.projectDeleted(project.name),
                          ),
                        ),
                      );
                    }
                  } on FirebaseAuthException {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.firebaseUnauthenticatedUserException,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error : $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.delete,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _openProject(MusicProject project) {
    _playerService.stop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProjectPage(project: project)),
    );
  }

  Future<void> _openAddProjectDialog() async {
    final MusicProject? newProject = await showDialog<MusicProject>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _NewProjectDialogContent(
          onProjectCreated: (projectName) {
            final project = _createProjectInstance(projectName);
            Navigator.of(dialogContext).pop(project);
          },
          onCancel: () {
            Navigator.of(dialogContext).pop(null);
          },
        );
      },
    );

    if (newProject != null) {
      try {
        await _projectService.saveProject(newProject);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.projectCreated(newProject.name),
              ),
            ),
          );
          _openProject(newProject);
        }
      } on FirebaseAuthException {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.firebaseUnauthenticatedUserException,
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  MusicProject _createProjectInstance(String projectName) {
    return MusicProject.empty(name: projectName);
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String userName =
        currentUser?.displayName ??
        AppLocalizations.of(context)!.usernamePlaceholder;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.helloUser(userName)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Theme.of(context).scaffoldBackgroundColor.withAlpha(128)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.yourProjects,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: HarmoniqColors.lightSurface)
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<List<MusicProject>>(
                    stream: _projectService.getProjects(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: HarmoniqColors.error),
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.noProjectsYet,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      } else {
                        final projects = snapshot.data!;
                        return ListView.builder(
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return ProjectCard(
                              project: project,
                              onTap: () => _openProject(project),
                              onLongPress: () => _deleteProject(project),
                              onPlay: () => _playProject(project),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NewProjectDialogContent extends StatefulWidget {
  final ValueChanged<String> onProjectCreated;
  final VoidCallback onCancel;

  const _NewProjectDialogContent({
    required this.onProjectCreated,
    required this.onCancel,
  });

  @override
  State<_NewProjectDialogContent> createState() =>
      _NewProjectDialogContentState();
}

class _NewProjectDialogContentState extends State<_NewProjectDialogContent> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleCreateProject() {
    final projectName = _nameController.text.trim();
    if (projectName.isNotEmpty) {
      widget.onProjectCreated(projectName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.projectNameEmptyError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        AppLocalizations.of(context)!.newProjectTitle,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.projectName,
        ),
        autofocus: true,
        onSubmitted: (_) => _handleCreateProject(),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: _handleCreateProject,
          child: Text(
            AppLocalizations.of(context)!.createProject,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
