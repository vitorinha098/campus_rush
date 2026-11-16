import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../campus_rush_game.dart';

class FimDeJogoOverlay extends StatelessWidget {
  final CampusRushGame game;
  final bool novoRecorde;

  const FimDeJogoOverlay({
    super.key,
    required this.game,
    this.novoRecorde = false,
  });

  String _nomeFase(int fase) {
    switch (fase) {
      case 2:
        return 'Corredores';
      case 3:
        return 'Anfiteatro';
      default:
        return 'Pátio';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_outlined, size: 56, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  const Text(
                    'Chegaste Atrasado!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (novoRecorde) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: const Text(
                        'NOVO RECORDE PESSOAL!',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    '${game.pontuacao} pts',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  Text(
                    'Fase alcançada: ${game.faseAtual} (${_nomeFase(game.faseAtual)})',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                      onPressed: () => game.reiniciarPartida(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Jogar Novamente', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        game.resumeEngine();
                        context.go('/leaderboard');
                      },
                      icon: const Icon(Icons.leaderboard),
                      label: const Text('Ver Leaderboard'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      game.resumeEngine();
                      context.go('/menu');
                    },
                    child: const Text('Voltar ao Menu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}