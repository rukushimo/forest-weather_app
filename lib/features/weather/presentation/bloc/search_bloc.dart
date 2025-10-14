// lib/features/weather/presentation/bloc/search_bloc.dart
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
    log('🔍 SearchBloc created and working!');

    _debounceTimer?.cancel();

    if (event.query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    if (event.query.length < 2) {
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      emit(const SearchLoading());

      try {
        log('📞 Calling searchLocations...');
        final locations = await remoteDataSource.searchLocations(event.query);

        if (locations.isEmpty) {
          emit(const SearchEmpty());
        } else {
          log('✅ Found ${locations.length} cities');
          emit(SearchLoaded(locations));
        }
      } catch (e) {
        log('❌ Search error: $e');
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
