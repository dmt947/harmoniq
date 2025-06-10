import 'package:flutter/material.dart';
import 'package:harmoniq/models/music_project.dart';

class ProjectCard extends StatelessWidget {
  final MusicProject project;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onPlay;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onLongPress,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).colorScheme.primary,
                  size: 46,
                ),
                onPressed: onPlay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
