import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String name;
  final String country;
  final String? state;
  final double latitude;
  final double longitude;

  const LocationEntity({
    required this.name,
    required this.country,
    this.state,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [name, country, state, latitude, longitude];
}
