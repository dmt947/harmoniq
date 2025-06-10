import 'package:flutter/material.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectSettingsTab extends StatefulWidget {
  final MusicProject project;
  final VoidCallback onProjectChanged;
  final VoidCallback onSave;

  const ProjectSettingsTab({
    super.key,
    required this.project,
    required this.onProjectChanged,
    required this.onSave,
  });

  @override
  State<ProjectSettingsTab> createState() => _ProjectSettingsTabState();
}

class _ProjectSettingsTabState extends State<ProjectSettingsTab> {
  late TextEditingController _nameController;
  late TextEditingController _tempoController;
  late TextEditingController _timeSignatureController;
  late String _selectedGenre;

  final Map<String, double> _subdivisions = {
    '1/1': 1.0,
    '1/2': 0.5,
    '1/3': 1 / 3,
    '1/4': 0.25,
    '1/6': 1 / 6,
    '1/8': 0.125,
    '1/16': 0.0625,
  };
  late String _selectedSubdivisionFraction;

  final List<String> _genres = [
    'Pop',
    'Rock',
    'Hip Hop',
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
    _selectedSubdivisionFraction =
        _subdivisions.entries
            .firstWhere(
              (entry) =>
                  (entry.value - widget.project.track.minimumSubdivision)
                      .abs() <
                  0.0001,
              orElse: () => MapEntry('1/4', 0.25),
            )
            .key;
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
      widget.project.track.minimumSubdivision =
          _subdivisions[_selectedSubdivisionFraction]!;
    });

    widget.onProjectChanged();
    widget.onSave();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.savedSettings)),
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
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.projectName,
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
                  decoration: const InputDecoration(labelText: 'BPM'),
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
            decoration: InputDecoration(
              labelText:
                  AppLocalizations.of(context)!.minSubdivisionPlaceholder,
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSubdivisionFraction,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubdivisionFraction = newValue!;
                    widget.project.track.minimumSubdivision =
                        _subdivisions[newValue]!;
                    widget.onProjectChanged();
                  });
                },
                items:
                    _subdivisions.keys.map<DropdownMenuItem<String>>((
                      String key,
                    ) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(key),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          InputDecorator(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.musicalGenre,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: Theme.of(context).textTheme.bodyLarge,
                dropdownColor: Theme.of(context).highlightColor,
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
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.timeSignature,
            ),
            readOnly: true,
          ),
          const SizedBox(height: 40),

          ElevatedButton.icon(
            onPressed: _saveProjectSettings,
            icon: const Icon(Icons.save),
            label: Text(AppLocalizations.of(context)!.saveSettings),
          ),
        ],
      ),
    );
  }
}
