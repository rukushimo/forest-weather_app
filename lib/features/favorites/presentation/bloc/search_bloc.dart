import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/features/weather/data/datasources/weather_remote_data_source.dart';
import '../../../weather/presentation/bloc/search_event.dart';
import '../../../weather/presentation/bloc/search_state.dart';

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
    log('🔍 SearchBloc: Received search query: "${event.query}"');

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (event.query.isEmpty) {
      log('⚠️ SearchBloc: Empty query, showing initial state');
      emit(const SearchInitial());
      return;
    }

    if (event.query.length < 2) {
      log(
        '⚠️ SearchBloc: Query too short (${event.query.length} chars), need at least 2',
      );
      return;
    }

    // Debounce - wait 500ms before searching
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      log('⏰ SearchBloc: Debounce timer fired, starting search...');
      emit(const SearchLoading());

      try {
        log('📞 SearchBloc: Calling searchLocations("${event.query}")...');
        final locations = await remoteDataSource.searchLocations(event.query);

        log('✅ SearchBloc: Got ${locations.length} locations');

        if (locations.isEmpty) {
          log('⚠️ SearchBloc: No locations found, emitting SearchEmpty');
          emit(const SearchEmpty());
        } else {
          log(
            '✅ SearchBloc: Emitting SearchLoaded with ${locations.length} locations',
          );
          for (var loc in locations) {
            log(
              '   📍 ${loc.name}, ${loc.country} (${loc.latitude}, ${loc.longitude})',
            );
          }
          emit(SearchLoaded(locations));
        }
      } catch (e, stackTrace) {
        log('❌ SearchBloc: Error occurred - $e');
        log('📚 StackTrace: $stackTrace');
        emit(SearchError('Failed to search: $e'));
      }
    });
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    log('🧹 SearchBloc: Clearing search');
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
