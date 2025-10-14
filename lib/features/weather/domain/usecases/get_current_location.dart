import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/usecases/usecase.dart';

class GetCurrentLocation implements UseCase<LocationData, NoParams> {
  final LocationService locationService;

  GetCurrentLocation(this.locationService);

  @override
  Future<Either<Failure, LocationData>> call(NoParams params) async {
    return await locationService.getCurrentLocation();
  }
}
