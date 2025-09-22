import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/repository/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepoProvider);
    
    return Scaffold(
      body: Center(
        child: user == null
            ? renderButton(
                configuration: GSIButtonConfiguration(
                  type: GSIButtonType.standard,
                  theme: GSIButtonTheme.outline,
                  text: GSIButtonText.signinWith,
                  size: GSIButtonSize.large,
                  shape: GSIButtonShape.pill,
                  
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Hello, ${user.displayName}"),
                  ElevatedButton(
                    onPressed: () async => GoogleSignIn.instance.signOut(),
                    child: const Text("Sign out"),
                  ),
                ],
              ),
      ),
    );
  }
}
