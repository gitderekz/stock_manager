// In connectivity_cubit.dart, use this version instead:
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription? _subscription;

  ConnectivityCubit(this._connectivity) : super(ConnectivityInitial()) {
    _init();
  }

  Future<void> _init() async {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        emit(ConnectivityDisconnected());
      } else {
        emit(ConnectivityConnected());
      }
    });

    // Check initial state
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      emit(ConnectivityDisconnected());
    } else {
      emit(ConnectivityConnected());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}




// import 'dart:async';
//
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// abstract class ConnectivityState {}
//
// class ConnectivityOnline extends ConnectivityState {}
//
// class ConnectivityOffline extends ConnectivityState {}
//
// class ConnectivityCubit extends Cubit<ConnectivityState> {
//   final Connectivity connectivity;
//   late StreamSubscription connectivitySubscription;
//
//   ConnectivityCubit(this.connectivity) : super(ConnectivityOnline()) {
//     connectivitySubscription = connectivity.onConnectivityChanged.listen((result) {
//       if (result == ConnectivityResult.none) {
//         emit(ConnectivityOffline());
//       } else {
//         emit(ConnectivityOnline());
//       }
//     });
//   }
//
//   @override
//   Future<void> close() {
//     connectivitySubscription.cancel();
//     return super.close();
//   }
// }
// // *************************


// import 'dart:async';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// part 'connectivity_state.dart';
//
// class ConnectivityCubit extends Cubit<ConnectivityState> {
//   final Connectivity _connectivity;
//   StreamSubscription? _subscription;
//
//   ConnectivityCubit(this._connectivity) : super(ConnectivityInitial()) {
//     _init();
//   }
//
//   Future<void> _init() async {
//     _subscription = _connectivity.onConnectivityChanged.listen((result) {
//       if (result == ConnectivityResult.none) {
//         emit(ConnectivityDisconnected());
//       } else {
//         emit(ConnectivityConnected());
//       }
//     });
//
//     // Check initial state
//     final result = await _connectivity.checkConnectivity();
//     if (result == ConnectivityResult.none) {
//       emit(ConnectivityDisconnected());
//     } else {
//       emit(ConnectivityConnected());
//     }
//   }
//
//   @override
//   Future<void> close() {
//     _subscription?.cancel();
//     return super.close();
//   }
// }
// // **********************************


// import 'dart:async';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// part 'connectivity_state.dart';
//
// class ConnectivityCubit extends Cubit<ConnectivityState> {
//   final Connectivity _connectivity;
//   StreamSubscription? _subscription;
//
//   ConnectivityCubit(this._connectivity) : super(ConnectivityInitial()) {
//     _init();
//   }
//
//   Future<void> _init() async {
//     _subscription = _connectivity.onConnectivityChanged.listen((result) {
//       if (result == ConnectivityResult.none) {
//         emit(ConnectivityDisconnected());
//       } else {
//         emit(ConnectivityConnected());
//       }
//     });
//
//     // Check initial state
//     final result = await _connectivity.checkConnectivity();
//     if (result == ConnectivityResult.none) {
//       emit(ConnectivityDisconnected());
//     } else {
//       emit(ConnectivityConnected());
//     }
//   }
//
//   @override
//   Future<void> close() {
//     _subscription?.cancel();
//     return super.close();
//   }
// }