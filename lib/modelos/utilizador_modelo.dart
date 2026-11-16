class UtilizadorModelo {
  final String uid;
  final String email;
  final String username;
  final String role; // 'player' ou 'admin'
  final String? photoUrl;
  final bool isBlocked;
  final DateTime createdAt;

  UtilizadorModelo({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    this.photoUrl,
    required this.isBlocked,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() => {
    'email': email,
    'username': username,
    'role': role,
    'photoUrl': photoUrl,
    'isBlocked': isBlocked,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UtilizadorModelo.fromMap(String uid, Map<String, dynamic> map) {
    return UtilizadorModelo(
      uid: uid,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? 'player',
      photoUrl: map['photoUrl'],
      isBlocked: map['isBlocked'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}