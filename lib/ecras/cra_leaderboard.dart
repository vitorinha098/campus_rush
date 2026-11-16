import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modelos/pontuacao_modelo.dart';
import '../servicos/pontuacao_servico.dart';

class EcraLeaderboard extends StatefulWidget {
  const EcraLeaderboard({super.key});

  @override
  State<EcraLeaderboard> createState() => _EcraLeaderboardState();
}

class _EcraLeaderboardState extends State<EcraLeaderboard> {
  final PontuacaoServico _pontuacaoServico = PontuacaoServico();
  int? _posicaoPessoal;

  String get _uidAtual => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _carregarPosicao();
  }

  Future<void> _carregarPosicao() async {
    if (_uidAtual.isEmpty) return;
    final pos = await _pontuacaoServico.obterPosicaoGlobal(_uidAtual);
    if (mounted) {
      setState(() => _posicaoPessoal = pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard Global'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Cartão com a posição relativa do jogador
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF38BDF8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'A Tua Posição Global:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  _posicaoPessoal != null ? '#$_posicaoPessoal' : 'Sem registo',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
          ),

          // Lista em tempo real do Top 10
          Expanded(
            child: StreamBuilder<List<PontuacaoModelo>>(
              stream: _pontuacaoServico.streamTop10(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
                }

                final lista = snapshot.data ?? [];
                if (lista.isEmpty) {
                  return const Center(
                    child: Text('Ainda não existem pontuações registadas.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    final isProprio = item.userId == _uidAtual && _uidAtual.isNotEmpty;
                    final posicao = index + 1;

                    return Card(
                      color: isProprio
                          ? const Color(0xFF0284C7).withValues(alpha: 0.3)
                          : const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isProprio ? const Color(0xFF38BDF8) : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _corMedalha(posicao),
                          child: Text(
                            '$posicao',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        title: Text(
                          item.username,
                          style: TextStyle(
                            fontWeight: isProprio ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text('Fase alcançada: ${item.levelReached}'),
                        trailing: Text(
                          '${item.score} pts',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _corMedalha(int posicao) {
    switch (posicao) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade300;
      case 3:
        return Colors.brown.shade300;
      default:
        return const Color(0xFF38BDF8);
    }
  }
}