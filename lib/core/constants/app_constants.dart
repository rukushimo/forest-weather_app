class AppConstants {
  static const String sunny = 'Clear';
  static const String cloudy = 'Clouds';
  static const String rainy = 'Rain';
  static const String thunderstorm = 'Thunderstorm';
  static const String snow = 'Snow';
  static const String mist = 'Mist';
  static const String fog = 'Fog';
  static const String haze = 'Haze';
  static const String dust = 'Dust';
  static const String sand = 'Sand';
  static const String ash = 'Ash';
  static const String squall = 'Squall';
  static const String tornado = 'Tornado';

  // Background image paths (we'll add these later)
  static const String sunnyBackground = 'assets/images/sunny_bg.jpg';
  static const String cloudyBackground = 'assets/images/cloudy_bg.jpg';
  static const String rainyBackground = 'assets/images/rainy_bg.jpg';
  static const String nightBackground = 'assets/images/night_bg.jpg';
  static const String defaultBackground = 'assets/images/default_bg.jpg';

  // Icon base URL
  static const String iconBaseUrl = 'https://openweathermap.org/img/wn/';

  // App settings
  static const String temperatureUnit = '°C';
  static const String windSpeedUnit = 'm/s';
  static const String pressureUnit = 'hPa';

  // Shared preferences keys
  static const String savedLocationsKey = 'saved_locations';
  static const String lastKnownLocationKey = 'last_known_location';
  static const String temperatureUnitKey = 'temperature_unit';
}
