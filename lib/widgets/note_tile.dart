import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:harmoniq/screens/tabs/midi_editor_tab.dart';

class NoteTile extends StatefulWidget {
  final NoteEvent note;
  final double beatWidth;
  final double noteHeight;
  final int minPitch;
  final int maxPitch;
  final Function(NoteEvent oldNote, NoteEvent newNote) onNoteUpdated;
  final ValueChanged<NoteEvent> onNoteDeleted;
  final Function(NoteEvent, BuildContext) onShowOptionsMenu;
  final VoidCallback onModeEnded;
  final NoteInteractionMode currentMode;
  final NoteEvent? currentlyInteractingNote;
  final double trackMinimumSubdivision;

  const NoteTile({
    required this.note,
    required this.beatWidth,
    required this.noteHeight,
    required this.minPitch,
    required this.maxPitch,
    required this.onNoteUpdated,
    required this.onNoteDeleted,
    required this.onShowOptionsMenu,
    required this.onModeEnded,
    required this.currentMode,
    this.currentlyInteractingNote,
    required this.trackMinimumSubdivision,
    super.key,
  });

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  late NoteEvent _currentNote;
  late NoteEvent _initialNoteState;

  late double _initialPanDxMove;
  late double _initialPanDyMove;
  late double _initialStartBeatMove;
  late int _initialPitchMove;

  late double _initialPanDxResize;
  late double _initialDurationResize;


  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _initialNoteState = widget.note;
  }

  @override
  void didUpdateWidget(covariant NoteTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note != oldWidget.note) {
      _currentNote = widget.note;
    }
  }

  double snapToTrackSubdivision(double value) {
    if (widget.trackMinimumSubdivision == 0) return value;
    return (value / widget.trackMinimumSubdivision).round() * widget.trackMinimumSubdivision;
  }

  int snapToPitch(double yPixels) {
    final totalPitches = widget.maxPitch - widget.minPitch + 1;
    final verticalIndex = (yPixels / widget.noteHeight).round();
    final clampedIndex = verticalIndex.clamp(0, totalPitches - 1);
    return widget.maxPitch - clampedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectedNote = widget.currentlyInteractingNote == widget.note;
    final bool canMove = isSelectedNote && widget.currentMode == NoteInteractionMode.move;
    final bool canResize = isSelectedNote && widget.currentMode == NoteInteractionMode.resize;

    return Positioned(
      left: _currentNote.startBeat * widget.beatWidth,
      top: (widget.maxPitch - _currentNote.pitch) * widget.noteHeight,
      child: GestureDetector(
        onDoubleTap: () {
          widget.onNoteDeleted(widget.note);
        },
        onLongPress: () {
          HapticFeedback.vibrate();
          widget.onShowOptionsMenu(widget.note, context);
        },
        child: GestureDetector(
          onPanStart: canMove ? (details) {
            _initialPanDxMove = details.globalPosition.dx;
            _initialPanDyMove = details.globalPosition.dy;
            _initialStartBeatMove = _currentNote.startBeat;
            _initialPitchMove = _currentNote.pitch;
            _initialNoteState = _currentNote;
          } : null,
          onPanUpdate: canMove ? (details) {
            final dx = details.globalPosition.dx - _initialPanDxMove;
            final dy = details.globalPosition.dy - _initialPanDyMove;

            setState(() {
              final deltaBeats = dx / widget.beatWidth;
              final newStart = snapToTrackSubdivision(_initialStartBeatMove + deltaBeats);

              final newPitchY = (widget.maxPitch - _initialPitchMove) * widget.noteHeight + dy;
              final newPitch = snapToPitch(newPitchY);

              _currentNote = _currentNote.copyWith(
                startBeat: newStart.clamp(0.0, double.infinity),
                pitch: newPitch.clamp(widget.minPitch, widget.maxPitch),
              );
            });
          } : null,
          onPanEnd: canMove ? (details) {
            widget.onNoteUpdated(_initialNoteState, _currentNote);
            widget.onModeEnded();
          } : null,
          child: Stack(
            children: [
              Container(
                width: _currentNote.duration * widget.beatWidth,
                height: widget.noteHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanStart: canResize ? (details) {
                    _initialPanDxResize = details.globalPosition.dx;
                    _initialDurationResize = _currentNote.duration;
                    _initialNoteState = _currentNote;
                  } : null,
                  onPanUpdate: canResize ? (details) {
                    final dx = details.globalPosition.dx - _initialPanDxResize;
                    final deltaBeats = dx / widget.beatWidth;
                    setState(() {
                      final newDuration = _initialDurationResize + deltaBeats;
                      _currentNote = _currentNote.copyWith(
                        duration: snapToTrackSubdivision(newDuration.clamp(widget.trackMinimumSubdivision, double.infinity)), // Usar el snap del track
                      );
                    });
                  } : null,
                  onPanEnd: canResize ? (details) {
                    widget.onNoteUpdated(_initialNoteState, _currentNote);
                    widget.onModeEnded();
                  } : null,
                  child: Container(
                    width: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4.0),
                        bottomRight: Radius.circular(4.0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.drag_handle,
                      size: 16,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
