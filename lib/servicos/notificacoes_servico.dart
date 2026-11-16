import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificacoesServico {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Pede permissão ao utilizador (Android 13+ / Web) e obtém o token FCM
  Future<String?> inicializar() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Subscreve ao tópico global para receber anúncios do Admin
      await _messaging.subscribeToTopic('anuncios_globais');
      return await _messaging.getToken();
    }
    return null;
  }

  /// Feedback visual imediato na app quando o jogador bate o recorde pessoal
  void notificarNovoRecorde(BuildContext context, int novaPontuacao) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Novo Recorde Pessoal: $novaPontuacao créditos!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}