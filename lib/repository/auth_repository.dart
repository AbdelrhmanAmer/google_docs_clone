import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepoProvider = StateNotifierProvider<AuthNotifier, GoogleSignInAccount?>(
  (ref) => AuthNotifier(
    null,
    clientId:
        '745356186162-2f4didn0h53b0vltf5od1f6d0sttn290.apps.googleusercontent.com',
  ),
);

class AuthNotifier extends StateNotifier<GoogleSignInAccount?> {
  final GoogleSignIn _googleSignIn;

  AuthNotifier(super._state, {required String clientId})
    : _googleSignIn = GoogleSignIn.instance {
    _googleSignIn.initialize(clientId: clientId);
    _googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        state = event.user;
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        state = null;
      }
    });
    _googleSignIn.attemptLightweightAuthentication();
  }
}
