import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Native Google Sign-In → Firebase idToken → BE `/api/auth/google`.
class GoogleSignInService {
  GoogleSignInService() : _google = _buildGoogleSignIn();

  final GoogleSignIn _google;

  static GoogleSignIn _buildGoogleSignIn() {
    final serverClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim() ?? '';
    return GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
  }

  Future<String?> signInAndGetIdToken() async {
    if ((dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim() ?? '').isEmpty) {
      throw StateError(
        'Thiếu GOOGLE_WEB_CLIENT_ID trong mobile/.env (Web client ID từ Firebase).',
      );
    }
    final account = await _google.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      debugPrint('GoogleSignIn: idToken null — thêm SHA-1 debug keystore vào Firebase Android app.');
      throw StateError(
        'Không lấy được token Google. Kiểm tra SHA-1 + google-services trên Firebase.',
      );
    }
    return idToken;
  }

  Future<void> signOutSilently() async {
    try {
      await _google.signOut();
    } catch (_) {
      /* ignore */
    }
  }
}
