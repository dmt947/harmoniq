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

  void playTrack({required MusicProject project}) {
    _currentProject = project;

    if (isPlayingNotifier.value) {
      stop();
    }

    if (!_audioService.isInitialized) {
      _audioService.init().then((_) {
        if (_audioService.isInitialized) {
          _startPlayback();
        } else {
          isPlayingNotifier.value = false; 
        }
      });
    } else {
      _startPlayback(); 
    }
  }

  void _startPlayback() {
    isPlayingNotifier.value = true;
    _currentBeat = 0.0;

    final double msPerBeat = 60000.0 / _currentProject!.tempo; 
    
    final double msPerTick = msPerBeat * _currentProject!.track.minimumSubdivision;

    double maxEndBeat = 0.0;
    if (_currentProject!.track.notes.isNotEmpty) {
      for (final note in _currentProject!.track.notes) {
        final noteEnd = note.startBeat + note.duration;
        if (noteEnd > maxEndBeat) {
          maxEndBeat = noteEnd;
        }
      }
    }
    final double effectiveTrackEndBeat = maxEndBeat + _currentProject!.track.minimumSubdivision;

    _playbackTimer = Timer.periodic(
      Duration(milliseconds: msPerTick.round()),
      (timer) {
        if (!isPlayingNotifier.value) {
          timer.cancel();
          return;
        }

        final Track currentTrack = _currentProject!.track;

        final double tolerance = _currentProject!.track.minimumSubdivision / 2.0; 
        
        for (final note in currentTrack.notes) {
          if ((note.startBeat - _currentBeat).abs() < tolerance) {
            _audioService.playNote(key: note.pitch, velocity: note.velocity);
          }
        }
        
        _currentBeat += _currentProject!.track.minimumSubdivision; 
        if (_currentBeat >= effectiveTrackEndBeat) { 
          stop();
        }
      },
    );
  }

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
    if (isPlayingNotifier.value) {
      stop(); 
      playTrack(project: _currentProject!);
    }
  }

  double getCurrentBeat() => _currentBeat;
}
