import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../modelos/configuracao_jogo_modelo.dart';

class CampusRushGame extends FlameGame with TapCallbacks {
  final ConfiguracaoJogoModelo config;
  final void Function(int pontuacaoFinal, int faseAlcancada) aoTerminarJogo;

  // Estado da partida
  int pontuacao = 0;
  int vidas = 3;
  int faseAtual = 1; // 1: Pátio | 2: Corredores (+35%) | 3: Anfiteatro (Max)
  double velocidadeAtual = 200.0;
  double _acumuladorTempo = 0.0;
  bool jogoTerminado = false;

  // Placeholder temporário do jogador (será substituído pela classe Estudante do Elemento 1)
  late RectangleComponent _jogadorPlaceholder;
  int _faixaAtual = 1; // 0: Esquerda, 1: Centro, 2: Direita

  CampusRushGame({
    required this.config,
    required this.aoTerminarJogo,
  });

  @override
  Color backgroundColor() => _corFundoPorFase();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    vidas = config.initialLives;
    velocidadeAtual = config.baseSpeed;

    // Jogador temporário centrado na parte inferior do ecrã
    _jogadorPlaceholder = RectangleComponent(
      size: Vector2(48, 64),
      paint: Paint()..color = const Color(0xFF38BDF8),
      anchor: Anchor.center,
    );
    _atualizarPosicaoPlaceholder();
    add(_jogadorPlaceholder);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _atualizarPosicaoPlaceholder();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (jogoTerminado) return;

    // Incrementa pontuação com base na sobrevivência e velocidade
    _acumuladorTempo += dt;
    if (_acumuladorTempo >= 0.1) {
      pontuacao += (1 * faseAtual);
      _acumuladorTempo = 0.0;
      _verificarProgressaoFase();
    }
  }

  /// Controla as 3 fases de dificuldade definidas na proposta
  void _verificarProgressaoFase() {
    if (pontuacao >= 600 && faseAtual < 3) {
      faseAtual = 3; // Fase 3: Anfiteatro (velocidade máxima +70%)
      velocidadeAtual = config.baseSpeed * 1.70;
    } else if (pontuacao >= 250 && faseAtual < 2) {
      faseAtual = 2; // Fase 2: Corredores (+35% velocidade)
      velocidadeAtual = config.baseSpeed * 1.35;
    }
  }

  Color _corFundoPorFase() {
    switch (faseAtual) {
      case 2:
        return const Color(0xFF1E293B); // Corredores
      case 3:
        return const Color(0xFF31102F); // Anfiteatro
      default:
        return const Color(0xFF0F172A); // Pátio
    }
  }

  /// Permite testar o movimento por toque enquanto a classe Estudante não é ligada
  @override
  void onTapDown(TapDownEvent event) {
    if (jogoTerminado) return;
    final metadeEcra = size.x / 2;
    if (event.localPosition.x < metadeEcra && _faixaAtual > 0) {
      _faixaAtual--;
    } else if (event.localPosition.x >= metadeEcra && _faixaAtual < 2) {
      _faixaAtual++;
    }
    _atualizarPosicaoPlaceholder();
  }

  void _atualizarPosicaoPlaceholder() {
    final larguraFaixa = size.x / 3;
    final posX = (larguraFaixa * _faixaAtual) + (larguraFaixa / 2);
    _jogadorPlaceholder.position = Vector2(posX, size.y - 100);
  }

  /// Método público para o Elemento 3 chamar quando houver colisão com obstáculo
  void registarDano() {
    if (jogoTerminado) return;
    vidas--;
    if (vidas <= 0) {
      terminarPartida();
    }
  }

  /// Método público para o Elemento 3 chamar ao apanhar créditos académicos
  void adicionarCreditos(int valor) {
    if (jogoTerminado) return;
    pontuacao += valor;
    _verificarProgressaoFase();
  }

  void pausarJogo() {
    pauseEngine();
    if (hasLayout) overlays.add('PausaOverlay');
  }

  void retomarJogo() {
    if (hasLayout) overlays.remove('PausaOverlay');
    resumeEngine();
  }

  void terminarPartida() {
    jogoTerminado = true;
    pauseEngine();
    if (hasLayout) overlays.add('GameOverOverlay');
    aoTerminarJogo(pontuacao, faseAtual);
  }

  void reiniciarPartida() {
    if (hasLayout) {
      overlays.remove('GameOverOverlay');
      overlays.remove('PausaOverlay');
    }
    pontuacao = 0;
    vidas = config.initialLives;
    faseAtual = 1;
    velocidadeAtual = config.baseSpeed;
    _acumuladorTempo = 0.0;
    _faixaAtual = 1;
    jogoTerminado = false;
    _atualizarPosicaoPlaceholder();
    resumeEngine();
  }
}