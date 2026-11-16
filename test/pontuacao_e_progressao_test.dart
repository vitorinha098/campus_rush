import 'package:campus_rush/jogo/campus_rush_game.dart';
import 'package:campus_rush/modelos/configuracao_jogo_modelo.dart';
import 'package:campus_rush/modelos/pontuacao_modelo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testes Unitários - Pontuação e Progressão (Elemento 2)', () {
    // Teste 1: Serialização e desserialização do PontuacaoModelo
    test('PontuacaoModelo converte corretamente de e para Map', () {
      final dataTeste = DateTime(2026, 5, 20, 14, 30);
      final modeloOriginal = PontuacaoModelo(
        id: 'score_01',
        userId: 'user_123',
        username: 'Vitoria',
        score: 450,
        levelReached: 2,
        timestamp: dataTeste,
      );

      final mapa = modeloOriginal.toMap();
      final modeloReconstruido = PontuacaoModelo.fromMap('score_01', mapa);

      expect(modeloReconstruido.userId, 'user_123');
      expect(modeloReconstruido.username, 'Vitoria');
      expect(modeloReconstruido.score, 450);
      expect(modeloReconstruido.levelReached, 2);
    });

    // Teste 2: Progressão automática das 3 fases e aumento de velocidade
    test('CampusRushGame avança para Fase 2 (+35% vel) e Fase 3 (+70% vel)', () {
      final config = ConfiguracaoJogoModelo(
        initialLives: 3,
        baseSpeed: 200.0,
        spawnRate: 1.2,
      );

      final game = CampusRushGame(
        config: config,
        aoTerminarJogo: (_, __) {},
      );

      // Estado inicial (Fase 1 - Pátio)
      expect(game.faseAtual, 1);
      expect(game.velocidadeAtual, 200.0);

      // Ao atingir 250 pontos -> Fase 2 (Corredores: +35% velocidade)
      game.adicionarCreditos(250);
      expect(game.faseAtual, 2);
      expect(game.velocidadeAtual, closeTo(270.0, 0.01));

      // Ao atingir 600 pontos -> Fase 3 (Anfiteatro: +70% velocidade)
      game.adicionarCreditos(350);
      expect(game.faseAtual, 3);
      expect(game.velocidadeAtual, closeTo(340.0, 0.01));
    });

    // Teste 3: Perda de vidas e disparo do callback de Game Over
    test('CampusRushGame termina partida quando as vidas chegam a zero', () {
      int pontuacaoFinalRecebida = -1;
      int faseFinalRecebida = -1;

      final game = CampusRushGame(
        config: ConfiguracaoJogoModelo(initialLives: 2, baseSpeed: 200.0, spawnRate: 1.0),
        aoTerminarJogo: (pts, fase) {
          pontuacaoFinalRecebida = pts;
          faseFinalRecebida = fase;
        },
      );

      game.vidas = 2;
      game.adicionarCreditos(120);

      // Primeira colisão: sobrevive com 1 vida
      game.registarDano();
      expect(game.vidas, 1);
      expect(game.jogoTerminado, isFalse);

      // Segunda colisão: 0 vidas -> Game Over
      game.registarDano();
      expect(game.vidas, 0);
      expect(game.jogoTerminado, isTrue);
      expect(pontuacaoFinalRecebida, 120);
      expect(faseFinalRecebida, 1);
    });
  });
}