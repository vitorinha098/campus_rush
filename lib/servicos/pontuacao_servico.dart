import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/pontuacao_modelo.dart';

class PontuacaoServico {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _colecao = 'scores';

  /// Grava uma nova pontuação e devolve `true` se for um novo recorde pessoal
  Future<bool> guardarPontuacao({
    required String userId,
    required String username,
    required int score,
    required int levelReached,
  }) async {
    final melhorAnterior = await obterMelhorPontuacaoUtilizador(userId);
    final novoRecorde = score > melhorAnterior;

    final novaPontuacao = PontuacaoModelo(
      id: '',
      userId: userId,
      username: username,
      score: score,
      levelReached: levelReached,
      timestamp: DateTime.now(),
    );

    await _firestore.collection(_colecao).add(novaPontuacao.toMap());
    return novoRecorde;
  }

  /// Obtém o Top 10 global ordenado da maior para a menor pontuação
  Stream<List<PontuacaoModelo>> streamTop10() {
    return _firestore
        .collection(_colecao)
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PontuacaoModelo.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Obtém todas as pontuações ordenadas (para calcular a posição relativa do jogador)
  Future<int?> obterPosicaoGlobal(String userId) async {
    final query = await _firestore
        .collection(_colecao)
        .orderBy('score', descending: true)
        .get();

    // Agrupa pela melhor pontuação de cada jogador único
    final melhoresPorJogador = <String, int>{};
    for (final doc in query.docs) {
      final data = doc.data();
      final uid = data['userId'] as String? ?? '';
      final pts = data['score'] as int? ?? 0;
      if (!melhoresPorJogador.containsKey(uid) || pts > melhoresPorJogador[uid]!) {
        melhoresPorJogador[uid] = pts;
      }
    }

    final rankingOrdenado = melhoresPorJogador.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final index = rankingOrdenado.indexWhere((e) => e.key == userId);
    return index == -1 ? null : index + 1;
  }

  /// Histórico de partidas de um utilizador específico
  Stream<List<PontuacaoModelo>> streamHistoricoUtilizador(String userId) {
    return _firestore
        .collection(_colecao)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PontuacaoModelo.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Melhor pontuação atual do jogador
  Future<int> obterMelhorPontuacaoUtilizador(String userId) async {
    final query = await _firestore
        .collection(_colecao)
        .where('userId', isEqualTo: userId)
        .orderBy('score', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return 0;
    return query.docs.first.data()['score'] as int? ?? 0;
  }
}