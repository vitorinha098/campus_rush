import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../jogo/campus_rush_game.dart';
import '../jogo/overlays/fim_de_jogo_overlay.dart';
import '../jogo/overlays/pausa_overlay.dart';
import '../modelos/configuracao_jogo_modelo.dart';
import '../servicos/notificacoes_servico.dart';
import '../servicos/pontuacao_servico.dart';

class EcraJogoContentor extends StatefulWidget {
  const EcraJogoContentor({super.key});

  @override
  State<EcraJogoContentor> createState() => _EcraJogoContentorState();
}

class _EcraJogoContentorState extends State<EcraJogoContentor> {
  final PontuacaoServico _pontuacaoServico = PontuacaoServico();
  final NotificacoesServico _notificacoesServico = NotificacoesServico();
  late CampusRushGame _game;
  bool _novoRecorde = false;

  @override
  void initState() {
    super.initState();
    _game = CampusRushGame(
      config: ConfiguracaoJogoModelo(initialLives: 3, baseSpeed: 200.0, spawnRate: 1.2),
      aoTerminarJogo: _processarFimDeJogo,
    );
  }

  Future<void> _processarFimDeJogo(int pontuacaoFinal, int faseAlcancada) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Obtém o username atual do Firestore
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final username = doc.data()?['username'] as String? ?? user.email ?? 'Estudante';

    final bateuRecorde = await _pontuacaoServico.guardarPontuacao(
      userId: user.uid,
      username: username,
      score: pontuacaoFinal,
      levelReached: faseAlcancada,
    );

    if (mounted) {
      setState(() => _novoRecorde = bateuRecorde);
      if (bateuRecorde) {
        _notificacoesServico.notificarNovoRecorde(context, pontuacaoFinal);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<CampusRushGame>(
            game: _game,
            overlayBuilderMap: {
              'PausaOverlay': (context, game) => PausaOverlay(game: game),
              'GameOverOverlay': (context, game) => FimDeJogoOverlay(
                game: game,
                novoRecorde: _novoRecorde,
              ),
            },
          ),
          // Barra superior temporária para testar pausa e simular dano
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filled(
                    onPressed: () => _game.pausarJogo(),
                    icon: const Icon(Icons.pause),
                    tooltip: 'Pausar',
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () => _game.registarDano(),
                    child: const Text('Simular Colisão (-1 Vida)', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}