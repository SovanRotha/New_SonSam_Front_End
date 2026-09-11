import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static const String serverClientId =
      '974263316033-k0eihmpcmkh4n57siehkvt0hk4itva5f.apps.googleusercontent.com';

  final GoogleSignIn signIn = GoogleSignIn.instance;

  Future<void>? initialization;

  Future<void> ensureInitialized() {
    return initialization ??= signIn.initialize(serverClientId: serverClientId);
  }

  Future<String?> authenticate() async {
    try {
      // print('1. Initializing Google Sign-In');

      await ensureInitialized();

      // print('2. Google Sign-In initialized');

      final GoogleSignInAccount account = await signIn.authenticate();

      // print('3. Google account selected');

      final GoogleSignInAuthentication authentication = account.authentication;

      // print('4. ID token: ${authentication.idToken}');

      return authentication.idToken;
    } catch (e) {
      // print('GOOGLE SIGN-IN ERROR: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await ensureInitialized();
    await signIn.signOut();
  }
}
