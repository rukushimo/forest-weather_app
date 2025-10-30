import 'package:equatable/equatable.dart';
import 'package:weather_app/features/weather/domain/entities/location_entity.dart';

/// Base class for all search states.
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Default state before any search is made.
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Indicates that search results are being loaded.
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Represents successful search results.
class SearchLoaded extends SearchState {
  final List<LocationEntity> locations;

  const SearchLoaded(this.locations);

  @override
  List<Object> get props => [locations];
}

/// Indicates that no results were found for the query.
class SearchEmpty extends SearchState {
  const SearchEmpty();
}

/// Represents an error that occurred during the search.
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}
