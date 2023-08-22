import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:weather/weather.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<List<Weather>> getData() async {
  String? cityName = 'Red Deer, CA';
  WeatherFactory wf = WeatherFactory("ce8eb3004b0dcfd8664bd52d8f1eae78");
  List<Weather> forecast = await wf.fiveDayForecastByCityName(cityName);
  return forecast;
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> tasks = <String>[];
  final List<bool> checkboxes = List.generate(8, (index) => false);

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 80,
              child: Image.asset('assets/rdplogo.png'),
            ),
            Text('Daily Planner',
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 32,
                ))
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: TableCalendar(
                    calendarFormat: _calendarFormat,
                    headerVisible: false,
                    focusedDay: _focusedDay,
                    firstDay: DateTime(2022),
                    lastDay: DateTime(2030),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = _selectedDay;
                        _focusedDay = _focusedDay;
                      });
                    }),
              ),
            ),
            Center(
              child: FutureBuilder<List<Weather>>(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    List<Weather> forecast = snapshot.data!;

                    // Extracting weather, temperature, and wind information
                    Weather firstWeather = forecast[0];
                    String city = "Red Deer, CA";
                    String? weatherCondition = firstWeather.weatherMain;
                    double? temperature = firstWeather.temperature?.celsius;
                    double? windSpeed = firstWeather.windSpeed;

                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to the left
                      children: [
                        Text('$city',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Weather Condition: $weatherCondition'),
                        Text('Temperature: $temperature °C'),
                        Text('Wind Speed: $windSpeed m/s'),
                      ],
                    );
                  } else {
                    return Text('No data available');
                  }
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: checkboxes[index]
                          ? Colors.green.withOpacity(0.7)
                          : Colors.blue.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          !checkboxes[index]
                              ? Icons.manage_history
                              : Icons.playlist_add_check_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 18),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
