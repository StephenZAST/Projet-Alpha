import 'package:flutter/material.dart';

import 'app.dart';

/// 🚀 Point d'entrée - Alpha Delivery App
/// 
/// Initialise l'application avec tous les services nécessaires
/// et lance l'interface mobile-first pour les livreurs.
void main() async {
  try {
    // Initialise l'application
    await AppInitializer.initialize();
    
    // Configure la gestion d'erreurs
    AppErrorHandler.initialize();
    
    // Configure les performances
    AppPerformanceConfig.configure();
    
    // Lance l'application
    runApp(const DeliveryApp());
    
  } catch (e, stackTrace) {
    debugPrint('❌ Erreur fatale lors du démarrage: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // En cas d'erreur critique, on lance quand même l'app
    // avec une configuration minimale
    runApp(const DeliveryAppFallback());
  }
}

/// 🆘 Application de secours en cas d'erreur d'initialisation
class DeliveryAppFallback extends StatelessWidget {
  const DeliveryAppFallback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpha Delivery - Erreur',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const ErrorScreen(),
    );
  }
}

/// 🚨 Écran d'erreur de démarrage
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Erreur de démarrage',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'L\'application n\'a pas pu démarrer correctement.\n'
                'Veuillez redémarrer l\'application.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Tentative de redémarrage
                  main();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Redémarrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
