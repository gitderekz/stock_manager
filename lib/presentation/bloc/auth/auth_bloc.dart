import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stock_manager/domain/repositories/auth_repository.dart';
import 'package:stock_manager/domain/entities/user.dart';
import 'package:stock_manager/domain/exceptions/auth_exceptions.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../utils/constants/environment.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    print("AUTH BLOCK..MWANZO.");
    // ✅ Login
    on<LoginRequested>(_onLoginRequested);

    // ✅ Logout
    on<LogoutRequested>(_onLogoutRequested);

    // ✅ App start event (check if user is cached)
    on<AppStarted>((event, emit) async {
      final isAuth = await authRepository.isAuthenticated();
      if (isAuth) {
        final user = await authRepository.getCachedUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });

    // ✅ Direct login from cached user (e.g. auto-login)
    on<LoginSuccess>((event, emit) {
      print("AUTH BLOCK..FANIKIWA.");
      emit(AuthAuthenticated(event.user));
    });
  }

  void connectSocket(String token) {
    IO.Socket socket = IO.io(dotenv.get(Environment.socketUrl), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ Connected to socket');
      socket.emit('authenticate', token);
    });

    socket.onDisconnect((_) => print('❌ Disconnected from socket'));
  }

  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final response = await authRepository.login(
        event.username,
        event.password,
      );

      // ✅ Token is already cached inside repository

      connectSocket(response.token);
      emit(AuthAuthenticated(response.user));

    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Login failed.'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
// ****************************************************



// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:stock_manager/domain/repositories/auth_repository.dart';
// import 'package:stock_manager/domain/entities/user.dart';
// import 'package:stock_manager/domain/exceptions/auth_exceptions.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// import '../../../utils/constants/environment.dart';
//
// part 'auth_event.dart';
// part 'auth_state.dart';
//
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthRepository authRepository;
//
//   void connectSocket(String token) {
//     IO.Socket socket = IO.io('${dotenv.get(Environment.socketUrl)}', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });
//
//     socket.connect();
//
//     socket.onConnect((_) {
//       print('Connected to socket');
//       socket.emit('authenticate', token);
//     });
//
//     socket.onDisconnect((_) => print('Disconnected from socket'));
//   }
//
//   AuthBloc(this.authRepository) : super(AuthInitial()) {
//     on<LoginRequested>(_onLoginRequested);
//     on<LogoutRequested>(_onLogoutRequested);
//   }
//
//   Future<void> _onLoginRequested(
//       LoginRequested event,
//       Emitter<AuthState> emit,
//       ) async {
//     emit(AuthLoading());
//     try {
//       final response = await authRepository.login(
//         event.username,
//         event.password,
//       );
//
//       // Save locally
//       await authRepository.authLocal.cacheUser(response.user, response.token);
//
//       // Connect socket with JWT
//       connectSocket(response.token); // ✅
//
//       // Emit authenticated state
//       emit(AuthAuthenticated(response.user));
//
//
//     } on AuthException catch (e) {
//       emit(AuthError(e.message));
//     } catch (e) {
//       emit(AuthError('Login failed.'));
//     }
//   }
//
//   Future<void> _onLogoutRequested(
//       LogoutRequested event,
//       Emitter<AuthState> emit,
//       ) async {
//     emit(AuthLoading());
//     await authRepository.logout();
//     emit(AuthUnauthenticated());
//   }
//
// }