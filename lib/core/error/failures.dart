import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();
}

class ServerFailure extends Failure {
  final String message;

  const ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ConnectionFailure extends Failure {
  @override
  List<Object> get props => [];
}

class LocationFailure extends Failure {
  final String message;

  const LocationFailure(this.message);

  @override
  List<Object> get props => [message];
}
