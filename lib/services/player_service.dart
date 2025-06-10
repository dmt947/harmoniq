import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:harmoniq/models/music_project.dart';
import 'package:harmoniq/services/audio_service.dart';

class PlayerService {
  // Singleton Pattern
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;
  PlayerService._internal();

  Timer? _playbackTimer;
  double _currentBeat = 0.0;
  MusicProject? _currentProject;

  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final AudioService _audioService = AudioService(); 

  /// Starts reproduction
  void playTrack({required MusicProject project}) async { 
    _currentProject = project; 

    if (isPlayingNotifier.value) {
      stop(); 
    }

    
    if (!_audioService.isInitialized) {
      await _audioService.init(); // AWAIT initialization
      if (!_audioService.isInitialized) {
        isPlayingNotifier.value = false; 
        return; 
      }
    }
    
    _startPlayback(); 
  }

  void _startPlayback() async {
    isPlayingNotifier.value = true;
    _currentBeat = 0.0; 
    final Track currentTrack = _currentProject!.track; 

    await _audioService.changeInstrument(
      program: currentTrack.instrumentPreset,
    );

    _audioService.stopAllNotes(currentTrack.notes);


    final double msPerBeat = 60000.0 / _currentProject!.tempo; 
    final double msPerTick = msPerBeat * currentTrack.minimumSubdivision;

    double maxEndBeat = 0.0;
    if (currentTrack.notes.isNotEmpty) {
      for (final note in currentTrack.notes) {
        final noteEnd = note.startBeat + note.duration;
        if (noteEnd > maxEndBeat) {
          maxEndBeat = noteEnd;
        }
      }
    }
    // Margin to make sure that the last notes plays succesfully
    final double effectiveTrackEndBeat = maxEndBeat + currentTrack.minimumSubdivision;

    _playbackTimer = Timer.periodic(
      Duration(milliseconds: msPerTick.round()),
      (timer) {
        if (!isPlayingNotifier.value) {
          timer.cancel(); 
          return;
        }

        final double tolerance = currentTrack.minimumSubdivision / 2.0; 
        
        for (final note in currentTrack.notes) {
          if ((note.startBeat - _currentBeat).abs() < tolerance) {
            _audioService.playNote(key: note.pitch, velocity: note.velocity);

            
            final noteDurationMs = (note.duration * msPerBeat).round();
            
            Future.delayed(Duration(milliseconds: noteDurationMs), () {
                _audioService.stopNote(key: note.pitch);
            });
          }
        }
        
        _currentBeat += currentTrack.minimumSubdivision; 
        
        if (_currentBeat >= effectiveTrackEndBeat) { 
          stop();
        }
      },
    );
  }

  /// Stops and disposes
  void stop() {
    _playbackTimer?.cancel(); 
    isPlayingNotifier.value = false;
    _currentBeat = 0.0; 

    if (_currentProject != null) {
      _audioService.stopAllNotes(_currentProject!.track.notes); 
    } else {
      _audioService.stopAllNotes([]);
    }
  }

  void seekTo(double beat) {
    _currentBeat = beat; 
    if (isPlayingNotifier.value && _currentProject != null) { 
      stop();
      playTrack(project: _currentProject!); 
    }
  }

  double getCurrentBeat() => _currentBeat; 
}
