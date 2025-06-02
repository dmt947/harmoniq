import 'package:flutter/material.dart';
import 'package:harmoniq/models/MusicProject.dart';

class AddProjectPage extends StatefulWidget {
  final void Function(MusicProject project) onSave;

  const AddProjectPage({super.key, required this.onSave});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _authorController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final project = MusicProject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        author: _authorController.text.trim(),
      );
      widget.onSave(project);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Proyecto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del proyecto',
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Escribe un nombre'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Escribe un autor'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
