import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart';
import 'package:routemaster/routemaster.dart';

import '../model/error.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ErrorModel authState = ref.watch(authRepoProvider);
    ref.listen<ErrorModel>(authRepoProvider, (previous, next) {
      final user = next.data;
      if (user is User) {
        ref.read(authStatusProvider.notifier).state = AuthStatus.loggedIn;
        Routemaster.of(context).replace('/');
      }
    });
    return Scaffold(
      body: Center(
        child: () {
          if (authState.error != null) {
            return Text(
              "Error: ${authState.error}",
              style: const TextStyle(color: Colors.red),
            );
          }

          if (GoogleSignIn.instance.supportsAuthenticate()) {
            return ElevatedButton(
              onPressed: () async {
                try {
                  await GoogleSignIn.instance.authenticate();
                } catch (e) {
                  debugPrint('❌ Error while authentiating. ');
                }
              },
              child: const Text('SIGN IN'),
            );
          } else {
            if (kIsWeb) {
              return renderButton(
                configuration: GSIButtonConfiguration(
                  shape: GSIButtonShape.pill,
                  type: GSIButtonType.standard,
                  text: GSIButtonText.signinWith,
                  size: GSIButtonSize.large,
                ),
              );
            }
          }
        }(),
      ),
    );
  }
}
