part of 'connectivity_cubit.dart';

abstract class ConnectivityState {}

class ConnectivityInitial extends ConnectivityState {}
class ConnectivityConnected extends ConnectivityState {}
class ConnectivityDisconnected extends ConnectivityState {}

// class ConnectivityOnline extends ConnectivityState {}
// class ConnectivityOffline extends ConnectivityState {}