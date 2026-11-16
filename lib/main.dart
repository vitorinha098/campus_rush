import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'rotas.dart';
import 'servicos/notificacoes_servico.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificacoesServico().inicializar();
  
  runApp(const CampusRushApp());
}

class CampusRushApp extends StatelessWidget {
  const CampusRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Rush',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}