import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmoniq/models/MusicProject.dart';
import 'package:harmoniq/screens/AddProjectPage.dart';
import 'package:harmoniq/screens/EditProjectPage.dart';
import 'package:harmoniq/widgets/ProjectCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<MusicProject> _projects = [
    MusicProject(id: '1', name: 'Proyecto 1', author: 'Autor A')
  ];

  void _playProject(MusicProject project) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reproduciendo "${project.name}"'),
            SizedBox(height: 8),
            LinearProgressIndicator(), // Barra de progreso simple
          ],
        ),
      ),
    );
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
                  Navigator.pop(context);
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
      MaterialPageRoute(builder: (_) => EditProjectPage(project: project,)),
    );
  }

  void _openAddProjectDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProjectPage(onSave: _addProject)),
    );
  }

  void _addProject(MusicProject project) {
    setState(() {
      _projects.add(project);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Proyectos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROYECTOS',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
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
