import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/weather_utils.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({
    super.key,
    required this.iconCode,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: WeatherUtils.getWeatherIconUrl(iconCode),
      width: size,
      height: size,
      placeholder: (context, url) => SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.cloud,
        size: size,
        color: Colors.grey,
      ),
    );
  }
}