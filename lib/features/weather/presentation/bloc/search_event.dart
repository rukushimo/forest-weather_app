import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchCities extends SearchEvent {
  final String query;

  const SearchCities(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}
