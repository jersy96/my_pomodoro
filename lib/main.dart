import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My pomodoro',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'My pomodoro'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Pomodoro(),
          ],
        ),
      ),
    );
  }
}

class Pomodoro extends StatefulWidget {
  Pomodoro({Key key}) : super(key: key);

  @override
  _PomodoroState createState() => _PomodoroState();
}

class _PomodoroState extends State<Pomodoro> {
  static final TextStyle _timeTextStyle =
      TextStyle(color: Colors.black, fontSize: 30);

  List<int> _durationOptions;
  String _textFieldValue;
  Duration _tick;
  String _displayTime;
  Timer _currentTimer;
  int _currentDurationIndex;
  Duration _currentCountdown;

  @override
  void initState() {
    setState(() {
      _tick = Duration(milliseconds: 100);
      _displayTime = '00:00';
      _currentDurationIndex = 0;
      _durationOptions = <int>[];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        SizedBox(
          height: 400,
          width: 400,
          child: CircularProgressIndicator(
            value: _calculateProgress(),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lime),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _displayTime,
                  style: _timeTextStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 50,
                  width: 400,
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Escribe los intervalos separados por coma'),
                    onChanged: (text) {
                      _textFieldValue = text;
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text('Iniciar'),
                  shape: StadiumBorder(),
                  onPressed: () => onStartButtonPressed(context),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  void onStartButtonPressed(BuildContext context) {
    _durationOptions = getDurationOptionsFromField();
    startNextTimer();
  }

  void startTimer(Duration duration) {
    DateTime endTime = DateTime.now().add(duration);
    _currentTimer = Timer.periodic(_tick, (Timer timer) {
      setState(() {
        _currentCountdown = endTime.difference(DateTime.now());
        _displayTime = _generateDisplayTime(_currentCountdown);
        if (DateTime.now().isAfter(endTime)) {
          stopTimer();
          startNextTimer();
        }
      });
    });
  }

  void stopTimer() => setState(() {
        _currentTimer.cancel();
      });

  List<int> getDurationOptionsFromField() {
    List<String> durationOptionStrings = _textFieldValue?.split(',');
    return durationOptionStrings?.map(int.parse)?.toList();
  }

  String _generateDisplayTime(Duration time) {
    int minutes = time.inMinutes;
    int seconds = (time.inSeconds - (time.inMinutes * 60));
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  double _calculateProgress() {
    Duration duration = getCurrentDuration();
    if (duration == null) {
      return 1;
    }
    return _currentCountdown.inMilliseconds / duration.inMilliseconds;
  }

  void startNextTimer() {
    _currentDurationIndex =
        (_currentDurationIndex + 1) % _durationOptions.length;
    startTimer(getCurrentDuration());
  }

  Duration getCurrentDuration() {
    if (_durationOptions.isEmpty) {
      return null;
    }
    int durationValue = _durationOptions[_currentDurationIndex];
    return Duration(minutes: durationValue);
  }
}
