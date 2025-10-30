import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/weather_remote_data_source.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final WeatherRemoteDataSource remoteDataSource;
  Timer? _debounceTimer;

  SearchBloc({required this.remoteDataSource}) : super(const SearchInitial()) {
    on<SearchCities>(_onSearchCities);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchCities(
    SearchCities event,
    Emitter<SearchState> emit,
  ) async {
    _debounceTimer?.cancel();

    final query = event.query.trim();

    // Reset the state if query is empty
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    // Skip very short queries to avoid unnecessary API calls
    if (query.length < 2) return;

    // Debounce to prevent rapid repeated searches
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      emit(const SearchLoading());

      try {
        final locations = await remoteDataSource.searchLocations(query);

        if (locations.isEmpty) {
          emit(const SearchEmpty());
        } else {
          emit(SearchLoaded(locations));
        }
      } catch (e, stackTrace) {
        log('Search error: $e', stackTrace: stackTrace);
        emit(SearchError('Failed to search: $e'));
      }
    });
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
