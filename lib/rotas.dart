import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ecras/cra_leaderboard.dart';
import 'ecras/ecra_perfil.dart';
import 'ecras/ecra_jogo_contentor.dart';

class EcraPlaceholder extends StatelessWidget {
  final String titulo;
  const EcraPlaceholder({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ecrã: $titulo (Em construção)', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(onPressed: () => context.go('/login'), child: const Text('1. Login')),
                ElevatedButton(onPressed: () => context.go('/registo'), child: const Text('2. Registo')),
                ElevatedButton(onPressed: () => context.go('/recuperar-password'), child: const Text('3. Recuperar')),
                ElevatedButton(onPressed: () => context.go('/menu'), child: const Text('4. Menu')),
                ElevatedButton(onPressed: () => context.go('/perfil'), child: const Text('5. Perfil')),
                ElevatedButton(onPressed: () => context.go('/leaderboard'), child: const Text('6. Leaderboard')),
                ElevatedButton(onPressed: () => context.go('/definicoes'), child: const Text('7. Definições')),
                ElevatedButton(onPressed: () => context.go('/admin/dashboard'), child: const Text('8. Admin Contas')),
                ElevatedButton(onPressed: () => context.go('/admin/jogo'), child: const Text('9. Admin Jogo')),
                ElevatedButton(onPressed: () => context.go('/sobre'), child: const Text('10. Sobre')),
                ElevatedButton(onPressed: () => context.go('/jogar'), child: const Text('▶ JOGAR')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/menu',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const EcraPlaceholder(titulo: '1. Login')),
    GoRoute(path: '/registo', builder: (_, __) => const EcraPlaceholder(titulo: '2. Registo')),
    GoRoute(path: '/recuperar-password', builder: (_, __) => const EcraPlaceholder(titulo: '3. Recuperar Password')),
    GoRoute(path: '/menu', builder: (_, __) => const EcraPlaceholder(titulo: '4. Menu Principal')),
    GoRoute(path: '/perfil', builder: (_, __) => const EcraPerfil()),
    GoRoute(path: '/leaderboard', builder: (_, __) => const EcraLeaderboard()),
    GoRoute(path: '/definicoes', builder: (_, __) => const EcraPlaceholder(titulo: '7. Definições')),
    GoRoute(path: '/admin/dashboard', builder: (_, __) => const EcraPlaceholder(titulo: '8. Admin: Dashboard & Contas')),
    GoRoute(path: '/admin/jogo', builder: (_, __) => const EcraPlaceholder(titulo: '9. Admin: Gestão de Jogo')),
    GoRoute(path: '/sobre', builder: (_, __) => const EcraPlaceholder(titulo: '10. Sobre o Jogo')),
    GoRoute(path: '/jogar', builder: (_, __) => const EcraJogoContentor()),
  ],
);