import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_docs_clone/screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import '../constants.dart';
import '../model/error.dart';
import '../model/user.dart';

final authRepoProvider = StateNotifierProvider<AuthNotifier, ErrorModel>(
  (ref) => AuthNotifier(
    clientId:
        '745356186162-2f4didn0h53b0vltf5od1f6d0sttn290.apps.googleusercontent.com',
    client: Client(),
    ref: ref,
  ),
);
final userProvider = StateProvider<User?>((ref) => null);

class AuthNotifier extends StateNotifier<ErrorModel> {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final Ref _ref;

  AuthNotifier({
    required String clientId,
    required Client client,
    required Ref ref,
  }) : _googleSignIn = GoogleSignIn.instance,
       _client = client,
       _ref = ref,
       super(ErrorModel(error: null, data: null)) {
    // Needed on web
    _googleSignIn.initialize(clientId: clientId);

    // Listen to events
    _googleSignIn.authenticationEvents.listen((event) async {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        final result = await signInWithGoogle(event.user);
        if (result.error == null && result.data != null) {
          _ref.read(userProvider.notifier).state = result.data as User;
          Get.to(() => const HomeScreen());
        }
        state = result;
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        state = ErrorModel(error: null, data: null);
      }
    });

    _googleSignIn.attemptLightweightAuthentication();
  }

  Future<ErrorModel> signInWithGoogle(GoogleSignInAccount user) async {
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
        body: jsonEncode(newUser.toJson()), // ✅ Map → JSON string
        headers: {"Content-Type": "application/json; charset=UTF-8"},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final updatedUser = newUser.copyWith(
          id: body['user']['_id'],
          token: body['token'],
        );
        return ErrorModel(error: null, data: updatedUser);
      } else {
        return ErrorModel(error: "Signup failed", data: null);
      }
    } catch (e, st) {
      print("SignInWithGoogle error: $e\n$st");
      return ErrorModel(error: e.toString(), data: null);
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _ref.read(userProvider.notifier).state = null;
    state = ErrorModel(error: null, data: null);
  }
}
