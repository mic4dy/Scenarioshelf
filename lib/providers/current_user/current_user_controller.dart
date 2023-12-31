import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:scenarioshelf/repositories/firebase/analytics/analytics_repository.dart';
import 'package:scenarioshelf/repositories/firebase/auth/auth_repository.dart';
import 'package:scenarioshelf/repositories/firebase/crashlytics/crashlytics_repository.dart';
import 'package:scenarioshelf/utils/exceptions/signing_exception.dart';
import 'package:scenarioshelf/utils/logger.dart';

part 'current_user_controller.g.dart';

@Riverpod(keepAlive: true)
class CurrentUserController extends _$CurrentUserController {
  late final AuthAPI _authRepository;

  @override
  FutureOr<User?> build() {
    _authRepository = ref.read(authRepositoryProvider);

    return _authRepository.getCurrentUser();
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final User user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = AsyncValue.data(user);
      await ref.read(analyticsRepositoryProvider).logSignUp(signUpMethod: 'signUpWithEmailAndPassword');
    } on FirebaseAuthException catch (error, stack) {
      logger.e(
        'Failed to execute UserViewModel.signUpWithEmailAndPassword',
        error: error,
        stackTrace: stack,
      );
      await ref.read(crashlyticsRepositoryProvider).recordError(error, stack);
      if (error.code == 'weak-password') {
        state = AsyncValue.error(
          const SigningException(
            message: 'Password is weak (FirebaseAuthException)',
            display: 'パスワードが脆弱です',
          ),
          stack,
        );
      } else if (error.code == 'email-already-in-use') {
        state = AsyncValue.error(
          const SigningException(
            message: 'Email is already in use (FirebaseAuthException)',
            display: '既に登録されたメールアドレスです',
          ),
          stack,
        );
      } else {
        state = AsyncValue.error(
          SigningException(
            message: error.toString(),
            display: '登録に失敗しました',
          ),
          stack,
        );
      }
    } on Exception catch (error, stack) {
      logger.e(
        'Failed to execute UserViewModel.signUpWithEmailAndPassword',
        error: error,
        stackTrace: stack,
      );
      await ref.read(crashlyticsRepositoryProvider).recordError(error, stack);
      state = AsyncValue.error(
        SigningException(
          message: error.toString(),
          display: '原因不明のエラーが発生しました',
        ),
        stack,
      );
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final User user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = AsyncValue.data(user);
      await ref.read(analyticsRepositoryProvider).logLogin(loginMethod: 'signInWithEmailAndPassword');
    } on FirebaseAuthException catch (error, stack) {
      logger.e(
        'Failed to execute UserViewModel.signInWithEmailAndPassword',
        error: error,
        stackTrace: stack,
      );
      await ref.read(crashlyticsRepositoryProvider).recordError(error, stack);
      if (error.code == 'user-not-found') {
        state = AsyncValue.error(
          const SigningException(
            message: 'User is not found (FirebaseAuthException)',
            display: 'メールアドレスかパスワード正しくありません',
          ),
          stack,
        );
      } else if (error.code == 'wrong-password') {
        state = AsyncValue.error(
          const SigningException(
            message: 'Wrong password (FirebaseAuthException)',
            display: 'メールアドレスかパスワード正しくありません',
          ),
          stack,
        );
      } else {
        state = AsyncValue.error(
          SigningException(
            message: error.toString(),
            display: 'ログインに失敗しました',
          ),
          stack,
        );
      }
    } on Exception catch (error, stack) {
      logger.e(
        'Failed to execute UserViewModel.signInWithEmailAndPassword',
        error: error,
        stackTrace: stack,
      );
      await ref.read(crashlyticsRepositoryProvider).recordError(error, stack);
      state = AsyncValue.error(
        SigningException(
          message: error.toString(),
          display: '原因不明のエラーが発生しました',
        ),
        stack,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final User user = await _authRepository.signInWithGoogle();

      state = AsyncValue.data(user);
      await ref.read(analyticsRepositoryProvider).logLogin(loginMethod: 'signInWithGoogle');
    } on Exception catch (error, stack) {
      logger.e(
        'Failed to execute UserViewModel.signInWithGoogle',
        error: error,
        stackTrace: stack,
      );
      await ref.read(crashlyticsRepositoryProvider).recordError(error, stack);
      state = AsyncValue.error(
        const SigningException(
          message: 'Google sign-in failed (FirebaseAuthException)',
          display: 'ログインに失敗しました',
        ),
        stack,
      );
    }
  }
}
