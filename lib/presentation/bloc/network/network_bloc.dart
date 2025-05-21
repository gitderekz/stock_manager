import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final Connectivity _connectivity;
  StreamSubscription? _connectivitySubscription;

  NetworkBloc(this._connectivity) : super(NetworkInitial()) {
    on<NetworkObserve>(_observe);
    on<NetworkNotify>(_notifyStatus);
  }

  Future<void> _observe(NetworkObserve event, Emitter<NetworkState> emit) async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        add(NetworkNotify(isConnected: false));
      } else {
        add(NetworkNotify(isConnected: true));
      }
    });

    // Check initial state
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      emit(NetworkFailure());
    } else {
      emit(NetworkSuccess());
    }
  }

  void _notifyStatus(NetworkNotify event, Emitter<NetworkState> emit) {
    event.isConnected ? emit(NetworkSuccess()) : emit(NetworkFailure());
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}



// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// part 'network_event.dart';
// part 'network_state.dart';
//
// class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
//   final Connectivity _connectivity = Connectivity();
//   StreamSubscription? _connectivitySubscription;
//
//   NetworkBloc() : super(NetworkInitial()) {
//     on<NetworkObserve>(_observe);
//     on<NetworkNotify>(_notifyStatus);
//
//     add(NetworkObserve());
//   }
//
//   Future<void> _observe(event, emit) async {
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
//       if (result == ConnectivityResult.none) {
//         add(NetworkNotify(isConnected: false));
//       } else {
//         add(NetworkNotify(isConnected: true));
//       }
//     });
//   }
//
//   void _notifyStatus(NetworkNotify event, emit) {
//     event.isConnected ? emit(NetworkSuccess()) : emit(NetworkFailure());
//   }
//
//   @override
//   Future<void> close() {
//     _connectivitySubscription?.cancel();
//     return super.close();
//   }
// }