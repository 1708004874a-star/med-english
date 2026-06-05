import '../../core/constants/db_constants.dart';

class NotebookEntry {
  const NotebookEntry({
    required this.id,
    required this.vocabId,
    required this.addedAt,
    this.userNote = '',
    required this.masteryLevel,
  });

  final int id;
  final int vocabId;
  final DateTime addedAt;
  final String userNote;
  final MasteryLevel masteryLevel;

  NotebookEntry copyWith({String? userNote, MasteryLevel? masteryLevel}) {
    return NotebookEntry(
      id: id,
      vocabId: vocabId,
      addedAt: addedAt,
      userNote: userNote ?? this.userNote,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NotebookEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
