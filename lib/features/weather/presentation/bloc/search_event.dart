import 'package:equatable/equatable.dart';

/// Base class for all search-related events.
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the user types a city name to search for.
class SearchCities extends SearchEvent {
  final String query;

  const SearchCities(this.query);

  @override
  List<Object> get props => [query];
}

/// Triggered when the user clears the search input.
class ClearSearch extends SearchEvent {
  const ClearSearch();
}
