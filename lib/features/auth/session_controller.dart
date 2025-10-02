import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/user.dart';
import 'auth_repository.dart';

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);

class SessionState {
  final bool isLoggedIn;
  final UserModel? user;
  const SessionState({required this.isLoggedIn, this.user});

  SessionState copyWith({bool? isLoggedIn, UserModel? user}) =>
      SessionState(isLoggedIn: isLoggedIn ?? this.isLoggedIn, user: user ?? this.user);
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    // Start unauthenticated; UI triggers restore on first frame.
    return const SessionState(isLoggedIn: false, user: null);
  }

  Future<void> restore() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.me();
    if (user != null) state = SessionState(isLoggedIn: true, user: user);
  }

  Future<void> setLoggedIn(UserModel user) async {
    state = SessionState(isLoggedIn: true, user: user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const SessionState(isLoggedIn: false, user: null);
  }
}


