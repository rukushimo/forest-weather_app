import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../error/failures.dart';

// Location data class to store lat and long
class LocationData {
  double latitude;
  double longitude;

  LocationData({required this.latitude, required this.longitude});
}

// abstract class for location service
abstract class LocationService {
  Future<Either<Failure, LocationData>> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
  Future<bool> hasLocationPermission();
  Future<bool> requestLocationPermission();
}

// implementation of location service
class LocationServiceImpl implements LocationService {
  // get current location method
  @override
  Future<Either<Failure, LocationData>> getCurrentLocation() async {
    try {
      // first check if location is enabled on device
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
          LocationFailure(
            'Location services are disabled. Please enable location services.',
          ),
        );
      }

      // now check if we have permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // ask for permission
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return const Left(
            LocationFailure(
              'Location permissions are denied. Please grant location permissions.',
            ),
          );
        }
      }

      // check if permission is denied forever
      if (permission == LocationPermission.deniedForever) {
        return const Left(
          LocationFailure(
            'Location permissions are permanently denied. Please enable them in app settings.',
          ),
        );
      }

      // if everything is okay, get the position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // create location data object
      LocationData data = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return Right(data);
    } catch (e) {
      // if something goes wrong return error
      return Left(LocationFailure('Failed to get location: $e'));
    }
  }

  // check if location service is enabled
  @override
  Future<bool> isLocationServiceEnabled() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    return enabled;
  }

  // check if app has location permission
  @override
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  // request location permission from user
  @override
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }

    return false;
  }
}
