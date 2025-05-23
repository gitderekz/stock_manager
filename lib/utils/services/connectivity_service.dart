// lib/utils/services/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService(this._connectivity);

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<List<ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }
}



// import 'package:connectivity_plus/connectivity_plus.dart';
//
// class ConnectivityService {
//   final Connectivity _connectivity = Connectivity();
//
//   Future<bool> isConnected() async {
//     final result = await _connectivity.checkConnectivity();
//     return result != ConnectivityResult.none;
//   }
//
//   Stream<List<ConnectivityResult>> get connectivityStream {
//     return _connectivity.onConnectivityChanged;
//   }
// }