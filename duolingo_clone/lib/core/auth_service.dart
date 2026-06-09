import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._() {
    _init();
  }

  static final AuthService instance = AuthService._();

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  bool _googleInitialized = false;

  fb.User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _init() async {
    print('🟡 AUTH SERVICE: Inicializando...');
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.initialize();
        _googleInitialized = true;
        print('✅ AUTH SERVICE: GoogleSignIn inicializado');
      } catch (e, stack) {
        print('❌ AUTH SERVICE: Error al inicializar GoogleSignIn: $e');
        print('   StackTrace: $stack');
      }
    } else {
      print('🟡 AUTH SERVICE: Web detectado, GoogleSignIn no necesario');
    }
  }

  Future<fb.UserCredential> signInWithGoogle() async {
    print('🟡 AUTH SERVICE: signInWithGoogle() llamado');

    if (kIsWeb) {
      try {
        final provider = fb.GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        print('🟡 AUTH SERVICE: Web - ejecutando signInWithPopup...');
        final credential = await _auth.signInWithPopup(provider);
        print('✅ AUTH SERVICE: Web signInWithPopup exitoso: ${credential.user?.uid}');
        return credential;
      } on fb.FirebaseAuthException catch (e, stack) {
        print('❌ ERROR FIREBASE GOOGLE WEB: ${e.message} (code: ${e.code})');
        print('   StackTrace: $stack');
        rethrow;
      } catch (e, stack) {
        print('❌ ERROR FIREBASE GOOGLE WEB: $e');
        print('   StackTrace: $stack');
        rethrow;
      }
    }

    if (!_googleInitialized) {
      print('🟡 AUTH SERVICE: GoogleSignIn no inicializado, inicializando...');
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }

    try {
      print('🟡 AUTH SERVICE: Mobile - ejecutando authenticate()...');
      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;
      print('🟡 AUTH SERVICE: Mobile - authenticate exitoso, idToken=${auth.idToken?.substring(0, 20)}...');
      final credential = fb.GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      print('✅ AUTH SERVICE: Mobile signInWithCredential exitoso: ${result.user?.uid}');
      return result;
    } on fb.FirebaseAuthException catch (e, stack) {
      print('❌ ERROR FIREBASE GOOGLE MOBILE: ${e.message} (code: ${e.code})');
      print('   StackTrace: $stack');
      rethrow;
    } catch (e, stack) {
      print('❌ ERROR GOOGLE SIGN-IN: $e');
      print('   StackTrace: $stack');
      rethrow;
    }
  }

  Future<void> signOut() async {
    print('🟡 AUTH SERVICE: signOut()');
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
      await _auth.signOut();
      print('✅ AUTH SERVICE: signOut exitoso');
    } catch (e, stack) {
      print('❌ AUTH SERVICE: Error en signOut: $e');
      print('   StackTrace: $stack');
    }
  }
}
