import 'package:flutter_midi_pro/flutter_midi_pro.dart';
import 'package:harmoniq/models/music_project.dart';

// Uses flutter_midi_pro
class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  final MidiPro _synth = MidiPro();
  bool isInitialized = false;
  int? _sfId;

  Future<void> init() async {
    if (isInitialized) {
      return;
    }
    try {
      _sfId = await _synth.loadSoundfont(
        path: 'assets/sf2/alex_gm.sf2',
        bank: 0,
        program: 0,
      );
      if (_sfId != null) {
        isInitialized = true;
      } else {
        isInitialized = false;
      }
    } catch (e) {
      isInitialized = false;
      _sfId = null;
    }
  }

  /// Plays a MIDI note.
  /// [key]: MIDI Pitch (eg: 60 = C4).
  /// [velocity]: Note volume (0-127).
  /// [channel]: MIDI channel (0-15).
  void playNote({required int key, int velocity = 127, int channel = 0}) {
    if (!isInitialized || _sfId == null) {
      return;
    }
    _synth.playNote(
      key: key,
      velocity: velocity,
      channel: channel,
      sfId: _sfId!,
    );
  }

  /// Stops an specific MIDI note
  /// [key]: MIDI Pitch of the note to stop.
  /// [channel]: MIDI channel.
  void stopNote({required int key, int channel = 0}) {
    if (!isInitialized || _sfId == null) {
      return;
    }
    _synth.stopNote(key: key, channel: channel, sfId: _sfId!);
  }

  /// Stops all notes
  void stopAllNotes(List<NoteEvent> notes) {
    if (!isInitialized || _sfId == null) {
      return;
    }
    for (NoteEvent note in notes) {
      _synth.stopNote(key: note.pitch, sfId: _sfId!);
    }
  }

  void dispose() {
    _synth.dispose();
    isInitialized = false;
    _sfId = null;
  }

  Future<void> changeInstrument({required int program, int channel = 0}) async {
    if (!isInitialized || _sfId == null) {
      return;
    }
    try {
      await _synth.selectInstrument(
        sfId: _sfId!,
        program: program,
        bank: 0,
        channel: channel,
      );
    } catch (e) {}
  }
}
