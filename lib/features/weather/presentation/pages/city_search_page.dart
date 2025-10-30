import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import 'package:weather_app/features/weather/presentation/bloc/search_event.dart';
import 'package:weather_app/features/weather/presentation/bloc/search_state.dart';
import '../../../../core/dependency_injection/injection_container.dart' as di;
import '../../domain/entities/location_entity.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';

class CitySearchPage extends StatefulWidget {
  const CitySearchPage({super.key});

  @override
  State<CitySearchPage> createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<SearchBloc>()),
        BlocProvider(create: (context) => di.sl<WeatherBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2d5016),
          title: const Text(
            'Search City',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2d5016), Color(0xFF1a3409)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildSearchField(),
              Expanded(child: _buildSearchResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter city name...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                context.read<SearchBloc>().add(SearchCities(value));
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                _searchController.clear();
                context.read<SearchBloc>().add(const ClearSearch());
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocListener<WeatherBloc, WeatherState>(
      listener: (context, state) {
        if (state is WeatherLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Loaded weather for ${state.currentWeather.cityName}',
              ),
            ),
          );
          Navigator.pop(context);
        } else if (state is WeatherError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return _buildMessage('Search for any city');
          } else if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchLoaded) {
            return _buildResultsList(context, state.locations);
          } else if (state is SearchEmpty) {
            return _buildMessage('No cities found');
          } else if (state is SearchError) {
            return _buildMessage(state.message, isError: true);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildMessage(String text, {bool isError = false}) {
    return Center(
      child: Text(
        text,
        style: TextStyle(color: isError ? Colors.red : Colors.white),
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    List<LocationEntity> locations,
  ) {
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF1a3409),
          child: ListTile(
            leading: const Icon(Icons.location_city, color: Colors.white),
            title: Text(
              location.name,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              location.state != null
                  ? '${location.state}, ${location.country}'
                  : location.country,
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              context.read<WeatherBloc>().add(
                GetWeatherForCoordinates(location.latitude, location.longitude),
              );
            },
          ),
        );
      },
    );
  }
}
