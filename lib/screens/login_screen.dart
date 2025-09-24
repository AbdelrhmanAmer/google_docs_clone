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
    final ErrorModel authState = ref.watch(authRepoProvider); // ErrorModel<User?>

    return Scaffold(
      body: Center(
        child: () {
          // لو في Error
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
                  onPressed: () async => GoogleSignIn.instance.signOut(),
                  child: const Text("Sign out"),
                ),
              ],
            );
          }

          // Default → Render Sign in Button
          return renderButton(
            configuration: GSIButtonConfiguration(
              type: GSIButtonType.standard,
              theme: GSIButtonTheme.outline,
              text: GSIButtonText.signinWith,
              size: GSIButtonSize.large,
              shape: GSIButtonShape.pill,
            ),
            
          );
        }(),
      ),
    );
  }
}
