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
  int faseAtual = 1; // 1: Pátio | 2: Corredores (+35%) | 3: Anfiteatro (+70%)
  double velocidadeAtual = 200.0;
  double _acumuladorTempo = 0.0;
  double _deslocamentoChao = 0.0;
  bool jogoTerminado = false;

  // Componentes visuais da tua parte (Cenário dinâmico + Skin NPC temporária)
  late _CenarioCampusComponent _cenario;
  late _EstudanteSkinComponent _jogadorSkin;
  int _faixaAtual = 1; // 0: Esquerda, 1: Centro, 2: Direita

  CampusRushGame({
    required this.config,
    required this.aoTerminarJogo,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    vidas = config.initialLives;
    velocidadeAtual = config.baseSpeed;

    // 1. Fundo dinâmico que muda nas 3 fases e mostra a velocidade das faixas
    _cenario = _CenarioCampusComponent(this);
    add(_cenario);

    // 2. Skin visual do estudante (mochila, cabeça, camisola)
    _jogadorSkin = _EstudanteSkinComponent();
    _atualizarPosicaoJogador();
    add(_jogadorSkin);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _atualizarPosicaoJogador();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (jogoTerminado) return;

    // Move as linhas da pista conforme a velocidade atual (mostra o aumento de dificuldade!)
    _deslocamentoChao = (_deslocamentoChao + velocidadeAtual * dt) % 80;

    // Incrementa pontuação com base na sobrevivência e fase
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

  /// Permite mover o estudante entre as 3 faixas ao tocar no ecrã
  @override
  void onTapDown(TapDownEvent event) {
    if (jogoTerminado) return;
    final metadeEcra = size.x / 2;
    if (event.localPosition.x < metadeEcra && _faixaAtual > 0) {
      _faixaAtual--;
    } else if (event.localPosition.x >= metadeEcra && _faixaAtual < 2) {
      _faixaAtual++;
    }
    _atualizarPosicaoJogador();
  }

  void _atualizarPosicaoJogador() {
    final larguraFaixa = size.x / 3;
    final posX = (larguraFaixa * _faixaAtual) + (larguraFaixa / 2);
    _jogadorSkin.position = Vector2(posX, size.y - 110);
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
    _atualizarPosicaoJogador();
    resumeEngine();
  }
}

/// Fundo dinâmico com 3 temas visuais (Pátio, Corredores, Anfiteatro) e pista animada
class _CenarioCampusComponent extends PositionComponent {
  final CampusRushGame gameRef;

  _CenarioCampusComponent(this.gameRef);

  @override
  void render(Canvas canvas) {
    final w = gameRef.size.x;
    final h = gameRef.size.y;

    // Cores e detalhes específicos para cada uma das 3 fases
    Color corPista;
    Color corBermas;
    Color corLinhas;
    String tituloFase;

    switch (gameRef.faseAtual) {
      case 2: // Fase 2: Corredores interiores
        corPista = const Color(0xFF334155); // Cinzento ardósia
        corBermas = const Color(0xFF0284C7); // Paredes azuis dos corredores
        corLinhas = Colors.white70;
        tituloFase = 'FASE 2: CORREDORES (+35% VEL)';
        break;
      case 3: // Fase 3: Anfiteatro
        corPista = const Color(0xFF4C1D95); // Roxo intenso
        corBermas = const Color(0xFFB45309); // Bancadas madeira/âmbar
        corLinhas = const Color(0xFFFBBF24); // Linhas douradas
        tituloFase = 'FASE 3: ANFITEATRO (VEL. MÁXIMA)';
        break;
      default: // Fase 1: Pátio exterior
        corPista = const Color(0xFF1E293B); // Asfalto escuro
        corBermas = const Color(0xFF15803D); // Relva verde do pátio
        corLinhas = Colors.white38;
        tituloFase = 'FASE 1: PÁTIO';
    }

    // 1. Pista principal
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = corPista);

    // 2. Bermas laterais temáticas (relva / paredes / bancadas)
    const larguraBerma = 24.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, larguraBerma, h), Paint()..color = corBermas);
    canvas.drawRect(Rect.fromLTWH(w - larguraBerma, 0, larguraBerma, h), Paint()..color = corBermas);

    // 3. Linhas tracejadas das 3 faixas em movimento (dá a sensação real de velocidade!)
    final paintLinha = Paint()
      ..color = corLinhas
      ..strokeWidth = 4;

    final larguraFaixa = w / 3;
    for (int i = 1; i <= 2; i++) {
      final x = larguraFaixa * i;
      for (double y = gameRef._deslocamentoChao - 80; y < h; y += 80) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 40), paintLinha);
      }
    }

    // 4. Indicador discreto da fase atual no topo do cenário
    final textPainter = TextPainter(
      text: TextSpan(
        text: tituloFase,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((w - textPainter.width) / 2, 68),
    );
  }
}

/// Skin visual de estudante universitário visto de cima/costas (mochila, casaco, cabeça)
class _EstudanteSkinComponent extends PositionComponent {
  _EstudanteSkinComponent()
      : super(size: Vector2(54, 72), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Sombra no chão
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x / 2, size.y - 6), width: 44, height: 14),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Braços / Ombros (Casaco universitário azul)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 24, size.x - 8, 30),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF0284C7),
    );

    // Mochila nas costas (Laranja/Vermelha)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(11, 28, size.x - 22, 28),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFEA580C),
    );

    // Detalhe fecho da mochila
    canvas.drawLine(
      Offset(15, 36),
      Offset(size.x - 15, 36),
      Paint()
        ..color = Colors.white70
        ..strokeWidth = 2,
    );

    // Cabeça / Cabelo
    canvas.drawCircle(
      Offset(size.x / 2, 16),
      13,
      Paint()..color = const Color(0xFFFDE68A), // Pele
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.x / 2, 16), radius: 13),
      3.14,
      3.14,
      true,
      Paint()..color = const Color(0xFF1E1B4B), // Cabelo escuro
    );
  }
}