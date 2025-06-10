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

  Map<String, dynamic> toJson() {
    return {
      'pitch': pitch,
      'startBeat': startBeat,
      'duration': duration,
      'velocity': velocity,
    };
  }

  factory NoteEvent.fromJson(Map<String, dynamic> json) {
    return NoteEvent(
      pitch: json['pitch'] as int,
      startBeat: (json['startBeat'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      velocity: json['velocity'] as int? ?? 100,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteEvent &&
        other.pitch == pitch &&
        other.startBeat == startBeat &&
        other.duration == duration &&
        other.velocity == velocity;
  }

  @override
  int get hashCode => Object.hash(pitch, startBeat, duration, velocity);
}

class Track {
  String name;
  List<NoteEvent> notes;
  double minimumSubdivision;
  int instrumentPreset;

  Track({
    required this.name,
    required this.notes,
    this.minimumSubdivision = 0.25,
    this.instrumentPreset = 1,
  });

  factory Track.empty({String? name, double? minimumSubdivision}) {
    return Track(
      name: name ?? '1',
      notes: [],
      minimumSubdivision: minimumSubdivision ?? 0.25,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'notes': notes.map((note) => note.toJson()).toList(),
      'minimumSubdivision': minimumSubdivision,
      'instrumentPreset': instrumentPreset,
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      name: json['name'] as String,
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map(
                (noteJson) =>
                    NoteEvent.fromJson(noteJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      minimumSubdivision:
          (json['minimumSubdivision'] as num?)?.toDouble() ?? 0.25,
      instrumentPreset: json['instrumentPreset'] as int? ?? 0,
    );
  }
}

class MusicProject {
  final String id;
  String name;
  Track track;
  double tempo;
  String genre;
  List<Map<String, String>> chatHistory;

  MusicProject({
    required this.id,
    required this.name,
    required this.tempo,
    required this.genre,
    Track? track,
    List<Map<String, String>>? chatHistory,
  }) : track = track ?? Track.empty(name: '1'),
       chatHistory = chatHistory ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tempo': tempo,
      'genre': genre,
      'track': track.toJson(),
      'chatHistory': chatHistory,
    };
  }

  factory MusicProject.empty({String? name}) {
    return MusicProject(
      id: const Uuid().v4(),
      name: name ?? 'P-harmoniq', tempo: 120, genre: 'Pop',
    );
  }
  factory MusicProject.fromJson(Map<String, dynamic> json) {
    return MusicProject(
      id: json['id'] as String,
      name: json['name'] as String,
      tempo: (json['tempo'] as num).toDouble(),
      genre: json['genre'] as String,
      track: Track.fromJson(json['track'] as Map<String, dynamic>),
      chatHistory:
          (json['chatHistory'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e))
              .toList() ??
          [],
    );
  }
}
