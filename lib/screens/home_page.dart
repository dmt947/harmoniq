import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:harmoniq/screens/edit_project_page.dart';
import 'package:harmoniq/screens/user_profile_screen.dart';
import 'package:harmoniq/services/player_service.dart';
import 'package:harmoniq/widgets/project_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<MusicProject> _projects = [
    MusicProject(
      id: '1',
      name: 'Proyecto de Ejemplo',
      tempo: 120.0,
      genre: 'Pop',
    ),
  ];

  final PlayerService _playerService = PlayerService();

  void _playProject(MusicProject project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          'Iniciando simulación de reproducción de "${project.name}"',
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
              'Eliminar proyecto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Text('¿Seguro que quieres eliminar "${project.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _projects.remove(project));
                  Navigator.pop(context); // Closes dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proyecto "${project.name}" eliminado.'),
                    ),
                  );
                },
                child: Text(
                  'Eliminar',
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProjectPage(project: project)),
    );
  }

  // Opens add project dialog
  Future<void> _openAddProjectDialog() async {
    final MusicProject? newProject = await showDialog<MusicProject>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _NewProjectDialogContent(
          onProjectCreated: (projectName) {
            // Creates project
            final project = _createProjectInstance(projectName);
            Navigator.of(
              dialogContext,
              // Closes dialog and returns the project
            ).pop(project);
          },
          onCancel: () {
            Navigator.of(
              dialogContext,
              // Closes dialog without project
            ).pop(null);
          },
        );
      },
    );

    if (newProject != null) {
      setState(() {
        // Adds project
        _projects.add(newProject);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Opens new project
        _openProject(newProject);
      });
    }
  }

  MusicProject _createProjectInstance(String projectName) {
    return MusicProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: projectName,
      tempo: 120.0,
      genre: 'Pop',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hola, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Usuario'}',
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                backgroundImage:
                    FirebaseAuth.instance.currentUser?.photoURL != null
                        ? NetworkImage(
                          FirebaseAuth.instance.currentUser!.photoURL!,
                        )
                        : null,
                child:
                    FirebaseAuth.instance.currentUser?.photoURL == null
                        ? const Icon(Icons.person)
                        : null,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TUS PROYECTOS',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _projects.isEmpty
                      ? Center(
                        child: Text(
                          'No hay proyectos aún. ¡Crea uno!',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                      : ListView.builder(
                        itemCount: _projects.length,
                        itemBuilder: (context, index) {
                          final project = _projects[index];
                          return ProjectCard(
                            project: project,
                            onTap: () => _openProject(project),
                            onLongPress: () => _deleteProject(project),
                            onPlay: () => _playProject(project),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Add project dialog content widget
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
        const SnackBar(
          content: Text('El nombre del proyecto no puede estar vacío.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).highlightColor,
      title: Text(
        'Nuevo Proyecto',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Nombre del Proyecto',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (_) => _handleCreateProject(),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(
            'Cancelar',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        TextButton(
          onPressed: _handleCreateProject,
          child: Text('Crear', style: Theme.of(context).textTheme.labelMedium),
        ),
      ],
    );
  }
}
