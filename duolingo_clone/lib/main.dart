import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAeRMGW01_j3ivRGppZBHYhZjWQ1pXQS5E',
          authDomain: 'lingo-fb923.firebaseapp.com',
          projectId: 'lingo-fb923',
          storageBucket: 'lingo-fb923.appspot.com',
          messagingSenderId: '100572088569',
          appId: '1:100572088569:web:45c2f32c2c6f1f05dd3f2d',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    // Si Firebase no se inicializa (ej. sin credenciales en Web),
    // la app arranca igual en modo demo sin autenticación.
  }

  ServiceLocator.init();
  runApp(const DuolingoCloneApp());
}
