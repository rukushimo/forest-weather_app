import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class GetWeatherForCurrentLocation extends WeatherEvent {
  const GetWeatherForCurrentLocation();
}

class GetWeatherForCity extends WeatherEvent {
  final String cityName;

  const GetWeatherForCity(this.cityName);

  @override
  List<Object> get props => [cityName];
}

class RefreshWeather extends WeatherEvent {
  const RefreshWeather();
}

class GetWeatherForCoordinates extends WeatherEvent {
  final double latitude;
  final double longitude;

  const GetWeatherForCoordinates(this.latitude, this.longitude);

  @override
  List<Object> get props => [latitude, longitude];
}
