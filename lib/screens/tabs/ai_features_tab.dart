import 'package:flutter/material.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:harmoniq/services/gemini_service.dart';

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
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final userPrompt = _promptController.text.trim();
    if (userPrompt.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': userPrompt});
      _promptController.clear();
      _isLoading = true;
    });

    try {
      final chatHistory =
          _messages.map((msg) {
            // Map API format: { 'role': 'user/model', 'parts': [{ 'text': '...' }] }
            return {
              'role': msg['role'],
              'parts': [
                {'text': msg['text']},
              ],
            };
          }).toList();

      final aiResponse = await _geminiService.sendMessage(
        chatHistory: chatHistory,
      );

      setState(() {
        _messages.add({'role': 'model', 'text': aiResponse});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'model', 'text': 'Error: ${e.toString()}'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).highlightColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    message['text']!,
                    style: Theme.of(context).textTheme.labelMedium,
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
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promptController,
                  decoration: InputDecoration(
                    hintText: 'Empieza a escribir',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).highlightColor,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading ? null : _sendMessage,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
