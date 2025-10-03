import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import '../constants.dart';
import '../model/error.dart';
import '../model/user.dart';
import '../repository/local_storage_repository.dart';

final authRepoProvider = StateNotifierProvider<AuthNotifier, ErrorModel<User?>>(
  (ref) => AuthNotifier(
    client: Client(),
    ref: ref,
    localStorageRepository: LocalStorageRepository(),
  ),
);

final userProvider = StateProvider<User?>((ref) => null);

class AuthNotifier extends StateNotifier<ErrorModel<User?>> {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final Ref _ref;
  final LocalStorageRepository _localStorageRepository;

  AuthNotifier({
    required Client client,
    required Ref ref,
    required LocalStorageRepository localStorageRepository,
  }) : _googleSignIn = GoogleSignIn.instance,
       _client = client,
       _ref = ref,
       _localStorageRepository = localStorageRepository,
       super(ErrorModel(error: null, data: null)) {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    unawaited(
      signIn
          .initialize(
            clientId: kIsWeb
                ? '745356186162-2f4didn0h53b0vltf5od1f6d0sttn290.apps.googleusercontent.com'
                : null,
            serverClientId: kIsWeb
                ? null
                : '745356186162-2f4didn0h53b0vltf5od1f6d0sttn290.apps.googleusercontent.com',
          )
          .then((_) {
            debugPrint("✅ GoogleSignIn initialized successfully");

            signIn.authenticationEvents
                .listen(_handleAuthenticationEvent)
                .onError(_handleAuthenticationError);

            // signIn.attemptLightweightAuthentication();
          })
          .catchError((e) {
            debugPrint("❌ GoogleSignIn.initialize failed: $e");
          }),
    );
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    debugPrint("📢 Received auth event: $event");

    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (user == null) {
      debugPrint("⚠️ No user returned in event: $event");
      return;
    }

    debugPrint("👤 User signed in: ${user.displayName} (${user.email})");

    try {
      final newUser = User(
        id: '',
        name: user.displayName ?? '',
        email: user.email,
        token: '',
        profilePic: user.photoUrl ?? '',
      );

      final res = await _client.post(
        Uri.parse('$host/api/signup'),
        body: jsonEncode(newUser.toJson()),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
      );

      debugPrint("📡 Signup response: ${res.statusCode} -> ${res.body}");

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final updatedUser = newUser.copyWith(
          id: body['user']['_id'],
          token: body['token'],
        );

        _localStorageRepository.setToken(updatedUser.token);
        _ref.read(userProvider.notifier).state = updatedUser;
        state = ErrorModel(error: null, data: updatedUser);
        debugPrint('✅ User saved successfully: ${updatedUser.toJson()}');
      } else {
        debugPrint('❌ Signup failed: ${res.body}');
      }
    } catch (e, st) {
      debugPrint('🔥 Exception during signup: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    debugPrint("❌ Auth error: $e");

    state = ErrorModel(
      error: e is GoogleSignInException
          ? _errorMessageFromSignInException(e)
          : 'Unknown error: $e',
      data: null,
    );
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }

  Future<void> signOut() async {
    _localStorageRepository.setToken('');
    await _googleSignIn.signOut();
    _ref.read(userProvider.notifier).state = null;
    state = ErrorModel(error: null, data: null);
  }

  Future<ErrorModel<User?>> getUserData() async {
    ErrorModel<User?> errorModel = ErrorModel(
      error: 'An unexpected error occurred',
      data: null,
    );

    try {
      String? token = await _localStorageRepository.getToken();
      if (token != null) {
        final res = await _client.get(
          Uri.parse('$host/'),
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
            'x-auth-token': token,
          },
        );

        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          final newUser = User.fromJson(body['user']).copyWith(token: token);

          errorModel = ErrorModel(error: null, data: newUser);
          _ref.read(userProvider.notifier).state = newUser;
          state = errorModel;
        }
      }
    } catch (e) {
      errorModel = ErrorModel(error: e.toString(), data: null);
    }
    return errorModel;
  }
}
