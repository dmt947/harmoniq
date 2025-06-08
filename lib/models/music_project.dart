import 'package:uuid/uuid.dart';

class NoteEvent {
  final int pitch;
  final double startBeat;
  final double duration;
  final int velocity;

  NoteEvent({
    required this.pitch,
    required this.startBeat,
    required this.duration,
    this.velocity = 100,
  });

  NoteEvent copyWith({
    int? pitch,
    double? startBeat,
    double? duration,
    int? velocity,
  }) {
    return NoteEvent(
      pitch: pitch ?? this.pitch,
      startBeat: startBeat ?? this.startBeat,
      duration: duration ?? this.duration,
      velocity: velocity ?? this.velocity,
    );
  }
}

class Track {
  final String id;
  String name;
  List<NoteEvent> notes;
  double minimumSubdivision;

  Track({
    required this.id,
    required this.name,
    required this.notes,
    this.minimumSubdivision = 0.25,
  });

  factory Track.empty({String? name, double? minimumSubdivision}) {
    return Track(
      id: const Uuid().v4(),
      name: name ?? 'Pista Principal',
      notes: [],
      minimumSubdivision: minimumSubdivision ?? 0.25,
    );
  }
}

class MusicProject {
  final String id;
  String name;
  Track track;
  double tempo;
  String genre;

  MusicProject({
    required this.id,
    required this.name,
    Track? track,
    this.tempo = 120.0,
    this.genre = 'Pop',
  }) : track = track ?? Track.empty(name: 'Pista Principal');
}
