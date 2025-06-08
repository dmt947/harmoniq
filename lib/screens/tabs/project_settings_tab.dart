import 'package:flutter/material.dart';
import 'package:harmoniq/models/music_project.dart';

class ProjectSettingsTab extends StatefulWidget {
  final MusicProject project;
  final VoidCallback onProjectChanged;

  const ProjectSettingsTab({
    super.key,
    required this.project,
    required this.onProjectChanged,
  });

  @override
  State<ProjectSettingsTab> createState() => _ProjectSettingsTabState();
}

class _ProjectSettingsTabState extends State<ProjectSettingsTab> {
  late TextEditingController _nameController;
  late TextEditingController _tempoController;
  late TextEditingController _timeSignatureController;
  late String _selectedGenre;

  final List<String> _genres = [
    'Pop',
    'Rock',
    'Electrónica',
    'Hip Hop',
    'Clásica',
    'Jazz',
    'Blues',
    'Folk',
    'Metal',
    'R&B',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _tempoController = TextEditingController(
      text: widget.project.tempo.toStringAsFixed(0),
    );
    _timeSignatureController = TextEditingController(text: '4/4');

    _selectedGenre =
        _genres.contains(widget.project.genre)
            ? widget.project.genre
            : _genres.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tempoController.dispose();
    _timeSignatureController.dispose();
    super.dispose();
  }

  void _saveProjectSettings() {
    setState(() {
      // Updates settings
      widget.project.name = _nameController.text.trim();
      widget.project.tempo =
          double.tryParse(_tempoController.text.trim()) ?? 120.0;
      widget.project.genre = _selectedGenre;
    });

    widget.onProjectChanged();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Ajustes del proyecto guardados!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Proyecto',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.project.name = value;
              widget.onProjectChanged();
            },
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Slider(
                  value: double.tryParse(_tempoController.text) ?? 120.0,
                  min: 60.0,
                  max: 240.0,
                  divisions: (240 - 60) ~/ 5,
                  label: '${_tempoController.text} BPM',
                  onChanged: (newTempo) {
                    setState(() {
                      _tempoController.text = newTempo.round().toString();
                    });
                  },
                  onChangeEnd: (newTempo) {
                    setState(() {
                      widget.project.tempo = newTempo;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _tempoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'BPM',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      widget.project.tempo = double.tryParse(value) ?? 120.0;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Género Musical',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGenre,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGenre = newValue!;
                  });
                },
                items:
                    _genres.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _timeSignatureController,
            decoration: const InputDecoration(
              labelText: 'Compases (ej. 4/4)',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ),
          const SizedBox(height: 40),

          ElevatedButton.icon(
            onPressed: _saveProjectSettings,
            icon: const Icon(Icons.save),
            label: const Text('Guardar Ajustes'),
          ),
        ],
      ),
    );
  }
}
