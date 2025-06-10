import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:harmoniq/services/gemini_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum _AiFeatureMode { none, addLayer, replaceMelody, transformMelody }

class AiFeaturesTab extends StatefulWidget {
  final MusicProject project;
  final VoidCallback onProjectChanged;

  const AiFeaturesTab({
    super.key,
    required this.project,
    required this.onProjectChanged,
  });

  @override
  State<AiFeaturesTab> createState() => _AiFeaturesTabState();
}

class _AiFeaturesTabState extends State<AiFeaturesTab> {
  final TextEditingController _promptController = TextEditingController();
  late List<Map<String, String>> _messages;
  bool _isLoading = false;
  _AiFeatureMode _selectedMode = _AiFeatureMode.none;
  final GeminiService _geminiService = GeminiService();

  static const Map<String, dynamic> _noteResponseSchema = {
    'type': 'ARRAY',
    'items': {
      'type': 'OBJECT',
      'properties': {
        'pitch': {
          'type': 'INTEGER',
          'description': 'MIDI note number (e.g., 60 for C4)',
        },
        'startBeat': {
          'type': 'NUMBER',
          'description':
              'Starting beat of the note, relative to the beginning of the track',
        },
        'duration': {
          'type': 'NUMBER',
          'description': 'Duration of the note in beats',
        },
        'velocity': {
          'type': 'INTEGER',
          'description': 'Velocity of the note (0-127, default 100)',
        },
      },
      'required': ['pitch', 'startBeat', 'duration'],
    },
  };

  @override
  void initState() {
    super.initState();
    _messages = widget.project.chatHistory;
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  List<Map<String, dynamic>> _notesToJson(List<NoteEvent> notes) {
    return notes.map((note) => note.toJson()).toList();
  }

  List<NoteEvent> _jsonToNotes(List<dynamic> jsonList) {
    return jsonList
        .map((jsonNote) => NoteEvent.fromJson(jsonNote as Map<String, dynamic>))
        .toList();
  }

  Future<void> _callGeminiAndProcessResponse({
    required String userPrompt,
    required String promptForAI,
    required _AiFeatureMode mode,
  }) async {
    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _messages.add({'role': 'user', 'text': userPrompt});
      _isLoading = true;
      _promptController.clear();
    });
    widget.project.chatHistory = _messages;
    widget.onProjectChanged();

    try {
      final Map<String, dynamic>? generationConfig =
          (mode != _AiFeatureMode.none)
              ? {
                'responseMimeType': 'application/json',
                'responseSchema': _noteResponseSchema,
              }
              : null;

      final aiContent = await _geminiService.sendMessage(
        chatHistory: [
          {
            'role': 'user',
            'parts': [
              {'text': promptForAI},
            ],
          },
        ],
        generationConfig: generationConfig,
      );

      String aiRawResponseText =
          aiContent['parts'][0]['text'] ?? localizations.noResponseFromAI;
      String chatDisplayMessage = aiRawResponseText;

      List<NoteEvent>? generatedNotes;
      bool notesSuccessfullyParsed = false;

      if (mode != _AiFeatureMode.none) {
        try {
          final List<dynamic> notesJson = jsonDecode(aiRawResponseText);
          generatedNotes = _jsonToNotes(notesJson);
          if (generatedNotes.isNotEmpty) {
            notesSuccessfullyParsed = true;
          }
                } catch (e) {
          _showSnackbar(localizations.generateNotesFailed, isError: true);
        }
      }

      if (notesSuccessfullyParsed) {
        if (mode == _AiFeatureMode.addLayer) {
          chatDisplayMessage = localizations.notesAddedSuccess;
        } else if (mode == _AiFeatureMode.replaceMelody) {
          chatDisplayMessage = localizations.melodyReplacedSuccess;
        } else if (mode == _AiFeatureMode.transformMelody) {
          chatDisplayMessage = localizations.melodyTransformedSuccess;
        }
      } else if (mode != _AiFeatureMode.none &&
          !notesSuccessfullyParsed &&
          aiRawResponseText.isNotEmpty) {
        _showSnackbar(localizations.aiResponded);
      }

      setState(() {
        _messages.add({'role': 'model', 'text': chatDisplayMessage});
      });
      widget.project.chatHistory = _messages;
      widget.onProjectChanged();

      if (notesSuccessfullyParsed) {
        setState(() {
          if (mode == _AiFeatureMode.replaceMelody ||
              mode == _AiFeatureMode.transformMelody) {
            widget.project.track.notes.clear();
          }
          widget.project.track.notes.addAll(generatedNotes!);
        });
        widget.onProjectChanged();
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'model',
          'text': localizations.apiError(e.toString()),
        });
      });
      widget.project.chatHistory = _messages;
      widget.onProjectChanged();
      _showSnackbar(localizations.apiError(e.toString()), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
        _selectedMode = _AiFeatureMode.none;
      });
    }
  }

  Future<void> _handleAiAction() async {
    final localizations = AppLocalizations.of(context)!;
    final userPromptText =
        _promptController.text.trim(); // El texto que el usuario ha escrito

    if (userPromptText.isEmpty && _selectedMode != _AiFeatureMode.none) {
      _showSnackbar(localizations.noInputError, isError: true);
      return;
    }

    String promptForAI = ""; // El prompt que se enviará a Gemini
    final currentNotesJson = jsonEncode(
      _notesToJson(widget.project.track.notes),
    );

    switch (_selectedMode) {
      case _AiFeatureMode.none:
        promptForAI = userPromptText;
        break;
      case _AiFeatureMode.addLayer:
        promptForAI =
            "Mi proyecto tiene un tempo de ${widget.project.tempo} BPM y estas notas: $currentNotesJson. "
            "Por favor, genera una ${userPromptText.toLowerCase()} que complemente esta melodía. "
            "Devuelve solo las notas de la nueva capa como un array JSON de objetos {pitch, startBeat, duration, velocity}. Asegúrate de que las notas estén cuantizadas a la subdivisión mínima de ${widget.project.track.minimumSubdivision}.";
        break;
      case _AiFeatureMode.replaceMelody:
        promptForAI =
            "Mi proyecto tiene un tempo de ${widget.project.tempo} BPM. "
            "Por favor, genera una nueva melodía de ${userPromptText.toLowerCase()}. "
            "Devuelve solo las notas de la nueva melodía como un array JSON de objetos {pitch, startBeat, duration, velocity}. Asegúrate de que las notas estén cuantizadas a la subdivisión mínima de ${widget.project.track.minimumSubdivision}.";
        break;
      case _AiFeatureMode.transformMelody:
        if (widget.project.track.notes.isEmpty) {
          _showSnackbar(localizations.noNotesToTransformError, isError: true);
          setState(() {
            _selectedMode = _AiFeatureMode.none;
          });
          return;
        }
        promptForAI =
            "Mi proyecto tiene un tempo de ${widget.project.tempo} BPM y estas notas: $currentNotesJson. "
            "Por favor, ${userPromptText.toLowerCase()} esta melodía. "
            "Devuelve solo las notas transformadas como un array JSON de objetos {pitch, startBeat, duration, velocity}. Asegúrate de que las notas estén cuantizadas a la subdivisión mínima de ${widget.project.track.minimumSubdivision}.";
        break;
    }

    _callGeminiAndProcessResponse(
      userPrompt: userPromptText,
      promptForAI: promptForAI,
      mode: _selectedMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[_messages.length - 1 - index];
              final isUser = message['role'] == 'user';
              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color:
                        isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    message['text']!,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color:
                          isUser
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ToggleButtons(
              isSelected:
                  _AiFeatureMode.values
                      .map((mode) => mode == _selectedMode)
                      .toList(),
              onPressed:
                  _isLoading
                      ? null
                      : (int index) {
                        setState(() {
                          _selectedMode = _AiFeatureMode.values[index];
                          _promptController.clear();

                          if (_selectedMode == _AiFeatureMode.none) {
                            _messages.clear();
                            widget.project.chatHistory.clear();
                            widget.onProjectChanged();
                          }
                        });
                      },
              borderRadius: BorderRadius.circular(8.0),
              selectedColor: Colors.white,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fillColor: Theme.of(context).colorScheme.primary,
              borderColor: Theme.of(context).primaryColor,
              selectedBorderColor: Theme.of(context).primaryColor,
              children: [
                Tooltip(
                  message: localizations.generalChatHint,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(localizations.generalChatButton),
                  ),
                ),
                Tooltip(
                  message: localizations.addLayerHint,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(localizations.addMelodyButton),
                  ),
                ),
                Tooltip(
                  message: localizations.replaceMelodyHint,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(localizations.replaceMelodyButton),
                  ),
                ),
                Tooltip(
                  message: localizations.transformMelodyHint,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(localizations.transformMelodyButton),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promptController,
                  decoration: InputDecoration(
                    hintText: _getHintText(localizations),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).highlightColor,
                  ),
                  onSubmitted: (_) => _handleAiAction(),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading ? null : _handleAiAction,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getHintText(AppLocalizations localizations) {
    switch (_selectedMode) {
      case _AiFeatureMode.addLayer:
        return localizations.addLayerHint;
      case _AiFeatureMode.replaceMelody:
        return localizations.replaceMelodyHint;
      case _AiFeatureMode.transformMelody:
        return localizations.transformMelodyHint;
      case _AiFeatureMode.none:
        return localizations.aiChatHint;
    }
  }
}
