class ConfiguracaoJogoModelo {
  final int initialLives;
  final double baseSpeed;
  final double spawnRate;

  ConfiguracaoJogoModelo({
    required this.initialLives,
    required this.baseSpeed,
    required this.spawnRate,
  });

  Map<String, dynamic> toMap() => {
    'initialLives': initialLives,
    'baseSpeed': baseSpeed,
    'spawnRate': spawnRate,
  };

  factory ConfiguracaoJogoModelo.fromMap(Map<String, dynamic> map) {
    return ConfiguracaoJogoModelo(
      initialLives: map['initialLives'] ?? 3,
      baseSpeed: (map['baseSpeed'] as num?)?.toDouble() ?? 200.0,
      spawnRate: (map['spawnRate'] as num?)?.toDouble() ?? 1.2,
    );
  }
}