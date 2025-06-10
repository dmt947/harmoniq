import 'dart:async';
import 'package:flutter/material.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:harmoniq/services/player_service.dart';
import 'package:harmoniq/theme/harmoniq_colors.dart';
import 'package:harmoniq/utils/midi_instruments.dart';
import 'package:harmoniq/widgets/note_tile.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Interacion mode enum
enum NoteInteractionMode {
  none, // Inactive mode
  move, // Move note mode
  resize, // Resize note mode
}

class MidiEditorTab extends StatefulWidget {
  final MusicProject project;
  final double zoomLevel;
  final ValueChanged<double> onZoomChanged;

  const MidiEditorTab({
    super.key,
    required this.project,
    required this.zoomLevel,
    required this.onZoomChanged,
  });

  @override
  State<MidiEditorTab> createState() => _MidiEditorTabState();
}

class _MidiEditorTabState extends State<MidiEditorTab> {
  static const double _baseBeatWidth = 40.0;
  static const double _baseNoteHeight = 24.0;

  double get beatWidth => _baseBeatWidth * widget.zoomLevel;
  double get noteHeight => _baseNoteHeight * widget.zoomLevel;

  static const int totalBeats = 32;
  static const int minPitch = 36; // C2
  static const int maxPitch = 84; // C6
  static int get totalNotes => maxPitch - minPitch + 1;

  final PlayerService _playerService = PlayerService();

  double _initialZoomLevel = 2.0;

  late final LinkedScrollControllerGroup _verticalGroup;
  late final ScrollController _noteLabelsScrollController;
  late final ScrollController _noteCanvasVerticalScrollController;
  late final ScrollController _noteCanvasHorizontalScrollController;

  NoteEvent? _currentlyInteractingNote;
  NoteInteractionMode _currentMode = NoteInteractionMode.none;

  Track get _currentTrack => widget.project.track;

  @override
  void initState() {
    super.initState();
    _verticalGroup = LinkedScrollControllerGroup();
    _noteLabelsScrollController = _verticalGroup.addAndGet();
    _noteCanvasVerticalScrollController = _verticalGroup.addAndGet();
    _noteCanvasHorizontalScrollController = ScrollController();

    _initialZoomLevel = widget.zoomLevel;
  }

  @override
  void didUpdateWidget(covariant MidiEditorTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.zoomLevel != oldWidget.zoomLevel) {
      _initialZoomLevel = widget.zoomLevel;
    }
  }

  @override
  void dispose() {
    _noteLabelsScrollController.dispose();
    _noteCanvasVerticalScrollController.dispose();
    _noteCanvasHorizontalScrollController.dispose();
    super.dispose();
  }

  final GlobalKey _canvasKey = GlobalKey();

  bool _isOverlapping(NoteEvent newNote, List<NoteEvent> existingNotes) {
    final newNoteEnd = newNote.startBeat + newNote.duration;

    for (final existingNote in existingNotes) {
      if (newNote.pitch != existingNote.pitch) {
        continue;
      }
      final existingNoteEnd = existingNote.startBeat + existingNote.duration;
      bool overlapsTime =
          (newNote.startBeat < existingNoteEnd &&
              newNoteEnd > existingNote.startBeat);

      if (overlapsTime) {
        return true;
      }
    }
    return false;
  }

  void _addNoteAtPosition(Offset localPositionOfCanvas) {
    if (_currentMode != NoteInteractionMode.none) return;

    // Snap to add notes at the beggining of a beat (1.0)
    final double startBeatRaw = (localPositionOfCanvas.dx / beatWidth);
    final int snappedStartBeatInt = startBeatRaw.floor();

    final pitch = (maxPitch - (localPositionOfCanvas.dy ~/ noteHeight)).clamp(
      minPitch,
      maxPitch,
    );

    final proposedNote = NoteEvent(
      pitch: pitch,
      startBeat: snappedStartBeatInt.toDouble(),
      duration: 1.0,
    );

    if (_isOverlapping(proposedNote, _currentTrack.notes)) {
      // Not adding a note
      _showToast(context, AppLocalizations.of(context)!.noteOverlapError);
      return;
    }

    setState(() {
      // Add if there is no overlap
      _currentTrack.notes.add(proposedNote);
    });
  }

  Future<void> _playTrack() async {
    if (_playerService.isPlayingNotifier.value) {
      _playerService.stop();
    } else {
      _playerService.playTrack(project: widget.project);
    }
  }

  void _handleNoteUpdated(NoteEvent oldNote, NoteEvent newNote) {
    setState(() {
      final oldNoteIndex = _currentTrack.notes.indexOf(oldNote);

      if (oldNoteIndex != -1) {
        // Create a temporal note list without the one that is selected
        final List<NoteEvent> notesWithoutOld = List.from(_currentTrack.notes);
        notesWithoutOld.removeAt(oldNoteIndex);

        // Check for overlap
        if (_isOverlapping(newNote, notesWithoutOld)) {
          _showToast(context, AppLocalizations.of(context)!.noteOverlapError);
          // On overlap, redo changes
        } else {
          // If there is no overlap, apply changes
          _currentTrack.notes[oldNoteIndex] = newNote;
        }
      } else {
        _showToast(context, AppLocalizations.of(context)!.unknownGenericError);
      }
    });
  }

  void _handleNoteDeleted(NoteEvent noteToDelete) {
    setState(() {
      _currentTrack.notes.remove(noteToDelete);
    });
  }

  void _handleShowOptionsMenu(NoteEvent note, BuildContext tileContext) {
    showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                leading: Icon(
                  Icons.delete,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(AppLocalizations.of(context)!.deleteNote),
                onTap: () {
                  Navigator.pop(context, 'delete');
                },
              ),
              ListTile(
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                leading: Icon(
                  Icons.open_with,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(AppLocalizations.of(context)!.moveNote),
                onTap: () {
                  Navigator.pop(context, 'move');
                },
              ),
              ListTile(
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                leading: Icon(
                  Icons.horizontal_rule,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(AppLocalizations.of(context)!.changeDuration),
                onTap: () {
                  Navigator.pop(context, 'resize');
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value == 'delete') {
        _handleNoteDeleted(note);
      } else if (value == 'move') {
        setState(() {
          _currentlyInteractingNote = note;
          _currentMode = NoteInteractionMode.move;
        });
        _showToast(tileContext, AppLocalizations.of(context)!.dragNoteBody);
      } else if (value == 'resize') {
        setState(() {
          _currentlyInteractingNote = note;
          _currentMode = NoteInteractionMode.resize;
        });
        _showToast(tileContext, AppLocalizations.of(context)!.dragNoteHandle);
      }
    });
  }

  void _handleNoteModeEnded() {
    setState(() {
      _currentlyInteractingNote = null;
      _currentMode = NoteInteractionMode.none;
    });
  }

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 50.0,
            left: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2)).then((_) {
      overlayEntry.remove();
    });
  }

  String _getDisplayZoomPercentage() {
    final percentage = 50 + (widget.zoomLevel - 1.0) * 50;
    return '${percentage.round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final ScrollPhysics canvasVerticalPhysics =
        _currentMode != NoteInteractionMode.none
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics();

    final ScrollPhysics canvasHorizontalPhysics =
        _currentMode != NoteInteractionMode.none
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics();

    return Column(
      children: [
        _buildTopControls(),
        _buildZoomSlider(),
        _buildEditorCanvas(canvasVerticalPhysics, canvasHorizontalPhysics),
      ],
    );
  }

  // Builds play/stop controls
  Widget _buildTopControls() {
    return Container(
      color: Theme.of(context).highlightColor,
      child: Row(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _playerService.isPlayingNotifier,
            builder: (context, isPlaying, child) {
              return IconButton(
                icon: Icon(
                  isPlaying ? Icons.stop : Icons.play_arrow,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: _playTrack,
              );
            },
          ),
          Expanded(
            child: Text(
              _currentTrack.name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<int>(
              value: _currentTrack.instrumentPreset,
              dropdownColor: Theme.of(context).highlightColor,
              icon: Icon(
                Icons.music_note,
                color: Theme.of(context).primaryColor,
              ),
              underline: Container(
                height: 1,
                color: Theme.of(context).primaryColor,
              ),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentTrack.instrumentPreset = newValue;
                  });
                  _showToast(
                    context,
                    AppLocalizations.of(context)!.changedInstrument(
                      MidiInstruments.instruments[newValue].toString(),
                    ),
                  );
                }
              },
              items:
                  MidiInstruments.instruments.entries.map<
                    DropdownMenuItem<int>
                  >((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Builds zoom slider
  Widget _buildZoomSlider() {
    return Container(
      color: Theme.of(context).highlightColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: widget.zoomLevel,
              min: 1.0,
              max: 3.0,
              divisions: 8,
              label: _getDisplayZoomPercentage(),
              onChanged: (newZoom) {
                widget.onZoomChanged(newZoom);
              },
            ),
          ),
          Text(
            _getDisplayZoomPercentage(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  // Builds main area of the editor, the canvas
  Widget _buildEditorCanvas(
    ScrollPhysics verticalPhysics,
    ScrollPhysics horizontalPhysics,
  ) {
    return Expanded(
      child: Row(
        children: [
          _buildNoteLabelsSection(),
          _buildNoteCanvasSection(verticalPhysics, horizontalPhysics),
        ],
      ),
    );
  }

  // Builds note labels section (C,D,E,F, etc)
  Widget _buildNoteLabelsSection() {
    return SizedBox(
      width: 60,
      child: Scrollbar(
        controller: _noteLabelsScrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _noteLabelsScrollController,
          itemCount: totalNotes,
          itemExtent: noteHeight,
          itemBuilder: (context, index) {
            final pitch = maxPitch - index;
            return Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).hoverColor),
                ),
              ),
              child: Text(
                _pitchToLabel(pitch),
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            );
          },
        ),
      ),
    );
  }

  // Builds section where the notes are painted
  Widget _buildNoteCanvasSection(
    ScrollPhysics verticalPhysics,
    ScrollPhysics horizontalPhysics,
  ) {
    return Expanded(
      child: Scrollbar(
        controller: _noteCanvasVerticalScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _noteCanvasVerticalScrollController,
          scrollDirection: Axis.vertical,
          physics: verticalPhysics,
          child: Scrollbar(
            controller: _noteCanvasHorizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _noteCanvasHorizontalScrollController,
              scrollDirection: Axis.horizontal,
              physics: horizontalPhysics,
              child: GestureDetector(
                onScaleStart:
                    _currentMode == NoteInteractionMode.none
                        ? (details) {
                          _initialZoomLevel = widget.zoomLevel;
                        }
                        : null,
                onScaleUpdate:
                    _currentMode == NoteInteractionMode.none
                        ? (details) {
                          final newZoom = (_initialZoomLevel * details.scale)
                              .clamp(1.0, 3.0);
                          widget.onZoomChanged(newZoom);
                        }
                        : null,
                onTapUp:
                    _currentMode == NoteInteractionMode.none
                        ? (details) {
                          _addNoteAtPosition(details.localPosition);
                        }
                        : null,
                child: SizedBox(
                  key: _canvasKey,
                  width: beatWidth * totalBeats,
                  height: noteHeight * totalNotes,
                  child: Stack(
                    children: [
                      _buildGrid(),
                      ..._currentTrack.notes.map((note) {
                        return NoteTile(
                          key: ValueKey(note),
                          note: note,
                          beatWidth: beatWidth,
                          noteHeight: noteHeight,
                          minPitch: minPitch,
                          maxPitch: maxPitch,
                          onNoteUpdated: _handleNoteUpdated,
                          onNoteDeleted: _handleNoteDeleted,
                          onShowOptionsMenu: _handleShowOptionsMenu,
                          onModeEnded: _handleNoteModeEnded,
                          currentMode: _currentMode,
                          currentlyInteractingNote: _currentlyInteractingNote,
                          trackMinimumSubdivision:
                              _currentTrack.minimumSubdivision,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _pitchToLabel(int pitch) {
    const notes = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B',
    ];
    final note = notes[pitch % 12];
    final octave = (pitch ~/ 12) - 1;
    return '$note$octave';
  }

  Widget _buildGrid() {
    return CustomPaint(
      size: Size(beatWidth * totalBeats, noteHeight * totalNotes),
      painter: _GridPainter(beatWidth: beatWidth, noteHeight: noteHeight),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double beatWidth;
  final double noteHeight;

  _GridPainter({required this.beatWidth, required this.noteHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = HarmoniqColors.lightSurface
          ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += beatWidth) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += noteHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final _GridPainter oldPainter = oldDelegate as _GridPainter;
    return oldPainter.beatWidth != beatWidth ||
        oldPainter.noteHeight != noteHeight;
  }
}
