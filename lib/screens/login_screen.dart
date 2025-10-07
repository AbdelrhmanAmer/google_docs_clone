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
    final screenSize = MediaQuery.of(context).size;

    ref.listen<ErrorModel>(authRepoProvider, (previous, next) {
      final user = next.data;
      if (user is User) {
        ref.read(authStatusProvider.notifier).state = AuthStatus.loggedIn;
        Routemaster.of(context).replace('/');
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isWide ? 450 : constraints.maxWidth * 0.9,
                padding: const EdgeInsets.symmetric(
                  vertical: 60,
                  horizontal: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Google Docs style logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/docs-logo.png',
                          height: screenSize.width < 600 ? 40 : 60,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Google Docs Clone',
                          style: TextStyle(
                            fontSize: screenSize.width < 600 ? 21 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    const Text(
                      'Welcome to your workspace',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 50),

                    if (authState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Error: ${authState.error}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    if (GoogleSignIn.instance.supportsAuthenticate())
                      ElevatedButton.icon(
                        icon: Image.asset(
                          'assets/images/google.png',
                          height: 24,
                        ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          backgroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await GoogleSignIn.instance.authenticate();
                          } catch (e) {
                            debugPrint('❌ Error while authenticating.');
                          }
                        },
                      )

                    else if (kIsWeb)
                      renderButton(
                        configuration: GSIButtonConfiguration(
                          shape: GSIButtonShape.pill,
                          type: GSIButtonType.standard,
                          text: GSIButtonText.signinWith,
                          size: GSIButtonSize.large,
                        ),
                      ),
                    const SizedBox(height: 40),
                    Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
