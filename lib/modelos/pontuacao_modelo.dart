import 'package:cloud_firestore/cloud_firestore.dart';

class PontuacaoModelo {
  final String id;
  final String userId;
  final String username;
  final int score;
  final int levelReached;
  final DateTime timestamp;

  PontuacaoModelo({
    required this.id,
    required this.userId,
    required this.username,
    required this.score,
    required this.levelReached,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'username': username,
    'score': score,
    'levelReached': levelReached,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory PontuacaoModelo.fromMap(String id, Map<String, dynamic> map) {
    return PontuacaoModelo(
      id: id,
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'Anónimo',
      score: map['score'] ?? 0,
      levelReached: map['levelReached'] ?? 1,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}