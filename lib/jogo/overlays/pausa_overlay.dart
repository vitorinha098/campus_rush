import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../campus_rush_game.dart';

class PausaOverlay extends StatelessWidget {
  final CampusRushGame game;

  const PausaOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pause_circle_filled, size: 56, color: Color(0xFF38BDF8)),
                  const SizedBox(height: 12),
                  const Text(
                    'Jogo em Pausa',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pontuação atual: ${game.pontuacao} pts',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                      onPressed: () => game.retomarJogo(),
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text('Retomar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        game.resumeEngine();
                        context.go('/menu');
                      },
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Sair para o Menu'),
                    ),
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