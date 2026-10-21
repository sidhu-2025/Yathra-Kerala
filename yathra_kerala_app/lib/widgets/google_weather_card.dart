import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class GoogleWeatherCard extends StatefulWidget {
  final Map<String, dynamic>? initialWeather;
  final String location;
  final VoidCallback? onClose;
  final bool isModal;

  const GoogleWeatherCard({
    super.key,
    this.initialWeather,
    this.location = 'Chalingal, Kasaragod, Kerala',
    this.onClose,
    this.isModal = false,
  });

  @override
  State<GoogleWeatherCard> createState() => _GoogleWeatherCardState();
}

class _GoogleWeatherCardState extends State<GoogleWeatherCard> {
  late Map<String, dynamic> _weather;
  bool _isLoading = false;
  bool _isCelsius = true;
  int _selectedTab = 0; // 0: Temperature, 1: Precipitation, 2: Wind
  int _selectedDayIndex = 0;
  String _currentLocationName = 'Chalingal, Kasaragod, Kerala';

  @override
  void initState() {
    super.initState();
    _currentLocationName = widget.location;
    _weather = widget.initialWeather ?? _defaultWeatherData();
    if (widget.initialWeather == null) {
      _loadWeather();
    }
  }

  Map<String, dynamic> _defaultWeatherData() {
    return {
      'location': _currentLocationName,
      'temperature_celsius': 27.0,
      'weather': 'Overcast',
      'rain_probability': '52%',
      'precipitation_pct': 52,
      'humidity': 95,
      'wind_kmh': 5.0,
      'day_time': 'Sunday, 9:00 pm',
      'hourly': [
        {'label': '10 pm', 'temp': 27, 'precip': 52, 'wind': 5, 'condition': 'Overcast'},
        {'label': '1 am', 'temp': 27, 'precip': 48, 'wind': 5, 'condition': 'Overcast'},
        {'label': '4 am', 'temp': 26, 'precip': 45, 'wind': 4, 'condition': 'Overcast'},
        {'label': '7 am', 'temp': 26, 'precip': 40, 'wind': 6, 'condition': 'Overcast'},
        {'label': '10 am', 'temp': 28, 'precip': 35, 'wind': 7, 'condition': 'Partly Cloudy'},
        {'label': '1 pm', 'temp': 29, 'precip': 30, 'wind': 8, 'condition': 'Partly Cloudy'},
        {'label': '4 pm', 'temp': 29, 'precip': 35, 'wind': 7, 'condition': 'Overcast'},
        {'label': '7 pm', 'temp': 28, 'precip': 45, 'wind': 5, 'condition': 'Overcast'},
      ],
      'daily': [
        {'day': 'Sun', 'code': 3, 'condition': 'Overcast', 'temp_max': 31, 'temp_min': 26},
        {'day': 'Mon', 'code': 3, 'condition': 'Overcast', 'temp_max': 29, 'temp_min': 26},
        {'day': 'Tue', 'code': 2, 'condition': 'Partly Cloudy', 'temp_max': 31, 'temp_min': 27},
        {'day': 'Wed', 'code': 95, 'condition': 'Thunderstorm', 'temp_max': 31, 'temp_min': 27},
        {'day': 'Thu', 'code': 2, 'condition': 'Partly Cloudy', 'temp_max': 30, 'temp_min': 26},
        {'day': 'Fri', 'code': 95, 'condition': 'Thunderstorm', 'temp_max': 29, 'temp_min': 26},
        {'day': 'Sat', 'code': 95, 'condition': 'Thunderstorm', 'temp_max': 29, 'temp_min': 26},
        {'day': 'Sun', 'code': 2, 'condition': 'Partly Cloudy', 'temp_max': 30, 'temp_min': 26},
      ],
      'recommendation': 'Transit operating normally.',
      'api_source': 'Open-Meteo Live API',
    };
  }

  Future<void> _loadWeather({double? lat, double? lng}) async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchWeather(_currentLocationName, lat, lng);
    if (!mounted) return;
    setState(() {
      _weather = data;
      if (data['location'] != null && data['location'].toString().isNotEmpty) {
        _currentLocationName = data['location'];
      }
      _isLoading = false;
    });
  }

  Future<void> _usePreciseLocation() async {
    setState(() => _isLoading = true);
    try {
      final pos = await getDeviceLocation();
      if (pos != null) {
        final lat = (pos['lat'] as num).toDouble();
        final lng = (pos['lng'] as num).toDouble();
        _currentLocationName = 'Chalingal, Kasaragod, Kerala';
        await _loadWeather(lat: lat, lng: lng);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Updated weather using precise GPS: ${lat.toStringAsFixed(3)}°, ${lng.toStringAsFixed(3)}°'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        await _loadWeather(lat: 12.3816, lng: 75.1038);
      }
    } catch (_) {
      await _loadWeather(lat: 12.3816, lng: 75.1038);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _convertTemp(num celsius) {
    if (_isCelsius) {
      return celsius.round();
    } else {
      return ((celsius * 9 / 5) + 32).round();
    }
  }

  Widget _buildWeatherIcon(dynamic codeOrCondition, {double size = 28}) {
    final str = codeOrCondition.toString().toLowerCase();
    if (str.contains('thunder') || str == '95' || str == '96' || str == '99') {
      return Icon(Icons.flash_on, color: Colors.orangeAccent, size: size);
    } else if (str.contains('rain') || str.contains('shower') || str.contains('drizzle')) {
      return Icon(Icons.grain, color: const Color(0xFF8AB4F8), size: size);
    } else if (str.contains('partly') || str == '2') {
      return Icon(Icons.cloud_queue, color: Colors.amberAccent, size: size);
    } else if (str.contains('clear') || str == '0' || str == '1') {
      return Icon(Icons.wb_sunny, color: Colors.amber, size: size);
    } else {
      return Icon(Icons.cloud, color: Colors.grey.shade300, size: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawTemp = (_weather['temperature_celsius'] ?? 28) as num;
    final displayTemp = _convertTemp(rawTemp);
    final condition = _weather['weather'] ?? 'Cloudy';
    final humidity = _weather['humidity'] ?? 82;
    final precipPct = _weather['rain_probability'] ?? '10%';
    final windKmh = _weather['wind_kmh'] ?? 5.0;
    final dayTime = _weather['day_time'] ?? 'Sunday, 9:00 pm';

    final List<dynamic> hourly = _weather['hourly'] ?? [];
    final List<dynamic> daily = _weather['daily'] ?? [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF202124), // Google Dark Slate Background
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Location & Use Precise Location Button ─────────────────
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _currentLocationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // "Use precise location" Pill
              InkWell(
                onTap: _usePreciseLocation,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF5F6368)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isLoading
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF8AB4F8)),
                            )
                          : const Icon(Icons.gps_fixed, color: Color(0xFF8AB4F8), size: 12),
                      const SizedBox(width: 4),
                      const Text(
                        'Precise',
                        style: TextStyle(
                          color: Color(0xFF8AB4F8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onClose,
                )
              else
                const Icon(Icons.more_vert, color: Colors.white70, size: 18),
            ],
          ),

          const SizedBox(height: 16),

          // ── Main Header: Weather Icon & Temperature on Left, Title & Condition on Right ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + Huge Temperature & °C | °F toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2, right: 10),
                    child: _buildWeatherIcon(condition, size: 48),
                  ),
                  Text(
                    '$displayTemp',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isCelsius = true),
                          child: Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _isCelsius ? FontWeight.bold : FontWeight.normal,
                              color: _isCelsius ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                        const Text(' | ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        GestureDetector(
                          onTap: () => setState(() => _isCelsius = false),
                          child: Text(
                            '°F',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: !_isCelsius ? FontWeight.bold : FontWeight.normal,
                              color: !_isCelsius ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Right side: Weather Title, Day/Time, Condition
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Weather',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dayTime,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      condition,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFFDD663)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Stats Row: Precipitation | Humidity | Wind ─────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF303134), // Google Card surface dark
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Precipitation', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(precipPct, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(width: 1, height: 22, color: Colors.white12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Humidity', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text('$humidity%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(width: 1, height: 22, color: Colors.white12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Wind', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text('${windKmh.toStringAsFixed(0)} km/h', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Tabs: Temperature | Precipitation | Wind ────────────────────────
          Row(
            children: [
              _buildTabItem(0, 'Temperature'),
              const SizedBox(width: 16),
              _buildTabItem(1, 'Precipitation'),
              const SizedBox(width: 16),
              _buildTabItem(2, 'Wind'),
            ],
          ),

          const SizedBox(height: 14),

          // ── Interactive 24-Hour Area Graph (Custom Painter) ────────────────
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _GoogleWeatherGraphPainter(
                hourlyData: hourly,
                mode: _selectedTab,
                isCelsius: _isCelsius,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── 7-Day Daily Forecast Row ───────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(daily.length, (idx) {
                final d = daily[idx];
                final isSelected = idx == _selectedDayIndex;
                final tMax = _convertTemp((d['temp_max'] ?? 31) as num);
                final tMin = _convertTemp((d['temp_min'] ?? 26) as num);
                final dayLabel = d['day'] ?? 'Day';

                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF303134) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: Colors.white12) : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayLabel,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade400,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildWeatherIcon(d['condition'] ?? d['code'], size: 26),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '$tMax°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$tMin°',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 10),
          const Divider(color: Color(0xFF3C4043), height: 1),
          const SizedBox(height: 8),

          // ── Footer: Live Meteorological API Source & Transit Status ─────────
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF81C995), // Active green pulse dot
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Live Weather Radar API',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _weather['recommendation'] ?? 'Monsoon-aware routing active',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Color(0xFFFDD663),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade400,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: isSelected ? 30 : 0,
            decoration: BoxDecoration(
              color: const Color(0xFFFDD663), // Google Weather Yellow accent line
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for rendering the exact temperature area graph curve
class _GoogleWeatherGraphPainter extends CustomPainter {
  final List<dynamic> hourlyData;
  final int mode; // 0: Temp, 1: Precip, 2: Wind
  final bool isCelsius;

  _GoogleWeatherGraphPainter({
    required this.hourlyData,
    required this.mode,
    required this.isCelsius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (hourlyData.isEmpty) return;

    final n = hourlyData.length;
    final List<double> values = [];
    final List<String> labels = [];

    for (final item in hourlyData) {
      labels.add(item['label'] ?? '');
      if (mode == 0) {
        final c = (item['temp'] ?? 28) as num;
        values.add(isCelsius ? c.toDouble() : (c * 9 / 5 + 32));
      } else if (mode == 1) {
        final p = (item['precip'] ?? 10) as num;
        values.add(p.toDouble());
      } else {
        final w = (item['wind'] ?? 5) as num;
        values.add(w.toDouble());
      }
    }

    final double minVal = values.reduce(math.min);
    final double maxVal = values.reduce(math.max);
    final double range = math.max(1.0, maxVal - minVal);

    final double graphHeight = size.height - 35; // Leave room for time labels
    final double stepX = size.width / (n > 1 ? (n - 1) : 1);

    final List<Offset> points = [];
    for (int i = 0; i < n; i++) {
      final x = i * stepX;
      final norm = (values[i] - minVal) / range;
      // Padding of 15px from top and bottom of curve
      final y = (graphHeight - 20) - (norm * (graphHeight - 35)) + 12;
      points.add(Offset(x, y));
    }

    // Color definitions
    Color strokeColor;
    Color gradientStart;
    if (mode == 0) {
      strokeColor = const Color(0xFFFDD663); // Warm yellow for temp
      gradientStart = const Color(0x66FDD663);
    } else if (mode == 1) {
      strokeColor = const Color(0xFF8AB4F8); // Blue for precipitation
      gradientStart = const Color(0x668AB4F8);
    } else {
      strokeColor = const Color(0xFF81C995); // Mint green for wind
      gradientStart = const Color(0x6681C995);
    }

    // Area Fill Path
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height - 25);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cpX = (p0.dx + p1.dx) / 2;
      fillPath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(points.last.dx, size.height - 25);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height - 25))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke Curve Path
    final strokePath = Path();
    strokePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cpX = (p0.dx + p1.dx) / 2;
      strokePath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
    }

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawPath(strokePath, strokePaint);

    // Value Labels and Bottom Time Labels
    for (int i = 0; i < n; i++) {
      final pt = points[i];
      final v = values[i].round();
      final valStr = mode == 1 ? '$v%' : (mode == 2 ? '$v' : '$v');

      // Value text above the peak
      final textSpan = TextSpan(
        text: valStr,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(pt.dx - tp.width / 2, pt.dy - 16));

      // Time label on the bottom axis
      final timeSpan = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 10,
        ),
      );
      final timePainter = TextPainter(text: timeSpan, textDirection: TextDirection.ltr);
      timePainter.layout();
      timePainter.paint(canvas, Offset(pt.dx - timePainter.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant _GoogleWeatherGraphPainter oldDelegate) {
    return oldDelegate.hourlyData != hourlyData ||
        oldDelegate.mode != mode ||
        oldDelegate.isCelsius != isCelsius;
  }
}
