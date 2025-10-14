import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
// ignore: unused_import
import 'package:permission_handler/permission_handler.dart';
import '../error/failures.dart';

class LocationData {
  final double latitude;
  final double longitude;

  LocationData({required this.latitude, required this.longitude});
}

abstract class LocationService {
  Future<Either<Failure, LocationData>> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
  Future<bool> hasLocationPermission();
  Future<bool> requestLocationPermission();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<Either<Failure, LocationData>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
          LocationFailure(
            'Location services are disabled. Please enable location services.',
          ),
        );
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(
            LocationFailure(
              'Location permissions are denied. Please grant location permissions.',
            ),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(
          LocationFailure(
            'Location permissions are permanently denied. Please enable them in app settings.',
          ),
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      return Right(
        LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      return Left(LocationFailure('Failed to get location: $e'));
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
