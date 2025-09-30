import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart';

import '../model/error.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';


class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ErrorModel authState = ref.watch(authRepoProvider);

    return Scaffold(
      body: Center(
        child: () {
          if (authState.error != null) {
            return Text(
              "Error: ${authState.error}",
              style: const TextStyle(color: Colors.red),
            );
          }

          final user = authState.data;
          if (user is User) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Hello, ${user.name}"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async =>
                      ref.read(authRepoProvider.notifier).signOut(),
                  child: const Text("Sign out"),
                ),
              ],
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
          }
          else{
            if (kIsWeb) {
              return renderButton(
                configuration: GSIButtonConfiguration(
                  shape: GSIButtonShape.rectangular,
                  type: GSIButtonType.icon,
                  size: GSIButtonSize.large,
                  text: GSIButtonText.signinWith,
                  theme: GSIButtonTheme.filledBlue,
                  
                )
              );
            }
          }
        }(),
      ),
    );
  }
}
