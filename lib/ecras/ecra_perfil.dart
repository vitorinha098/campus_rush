import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../modelos/pontuacao_modelo.dart';
import '../servicos/pontuacao_servico.dart';

class EcraPerfil extends StatefulWidget {
  const EcraPerfil({super.key});

  @override
  State<EcraPerfil> createState() => _EcraPerfilState();
}

class _EcraPerfilState extends State<EcraPerfil> {
  final ImagePicker _picker = ImagePicker();
  final PontuacaoServico _pontuacaoServico = PontuacaoServico();
  Uint8List? _imagemBytes;
  bool _aAtualizarFoto = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  Future<void> _alterarFoto(ImageSource origem) async {
    try {
      final XFile? ficheiro = await _picker.pickImage(
        source: origem,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 70,
      );

      if (ficheiro == null) return;

      setState(() => _aAtualizarFoto = true);
      final bytes = await ficheiro.readAsBytes();
      final base64String = base64Encode(bytes);

      if (_user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .update({'photoUrl': base64String});
      }

      if (mounted) {
        setState(() {
          _imagemBytes = bytes;
          _aAtualizarFoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _aAtualizarFoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  void _mostrarOpcoesImagem() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tirar Fotografia (Câmara)'),
              onTap: () {
                Navigator.pop(ctx);
                _alterarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da Galeria'),
              onTap: () {
                Navigator.pop(ctx);
                _alterarFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
      ),
      body: uid.isEmpty
          ? const Center(child: Text('Inicia sessão para veres o teu perfil.'))
          : Column(
        children: [
          const SizedBox(height: 20),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              final dados =
              snapshot.data?.data() as Map<String, dynamic>?;
              final username = dados?['username'] ?? 'Estudante';
              final email = dados?['email'] ?? _user?.email ?? '';
              final photoBase64 = dados?['photoUrl'] as String?;

              Uint8List? avatarAtual = _imagemBytes;
              if (avatarAtual == null &&
                  photoBase64 != null &&
                  photoBase64.isNotEmpty) {
                try {
                  avatarAtual = base64Decode(photoBase64);
                } catch (_) {}
              }

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: const Color(0xFF1E293B),
                        backgroundImage: avatarAtual != null
                            ? MemoryImage(avatarAtual)
                            : null,
                        child: avatarAtual == null
                            ? const Icon(Icons.person,
                            size: 52, color: Colors.white70)
                            : null,
                      ),
                      FloatingActionButton.small(
                        onPressed:
                        _aAtualizarFoto ? null : _mostrarOpcoesImagem,
                        backgroundColor: const Color(0xFF0284C7),
                        child: _aAtualizarFoto
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    username,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Histórico de Partidas',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PontuacaoModelo>>(
              stream: _pontuacaoServico.streamHistoricoUtilizador(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final partidas = snapshot.data ?? [];
                if (partidas.isEmpty) {
                  return const Center(
                    child: Text('Ainda não jogaste nenhuma partida.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: partidas.length,
                  itemBuilder: (context, index) {
                    final p = partidas[index];
                    final dataFormatada =
                        '${p.timestamp.day.toString().padLeft(2, '0')}/${p.timestamp.month.toString().padLeft(2, '0')}/${p.timestamp.year}';

                    return Card(
                      color: const Color(0xFF1E293B),
                      child: ListTile(
                        leading: const Icon(Icons.sports_esports,
                            color: Color(0xFF38BDF8)),
                        title: Text('${p.score} Pontos'),
                        subtitle: Text(
                            'Fase ${p.levelReached} • $dataFormatada'),
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
}