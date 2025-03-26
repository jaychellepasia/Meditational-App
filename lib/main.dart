import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation App',
      theme: ThemeData(
        fontFamily: 'Arial',
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Replace 'assets/images/haha.png' with the actual path to your login image.
            Image.asset(
              'assets/images/front.png', // Ensure this path is correct
              height: 300,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to PeaceU!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Start Your Journey'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedSession = 0;
  int _progress = 0;
  final int _duration = 5 * 60;
  Timer? _timer;
  final List<String> _completedSessions = [];
  bool _isTimerRunning = false; // Track timer state
  // Method channel for background task
  static const MethodChannel _backgroundChannel =
      MethodChannel('com.example.meditation_app/background_task');

  final List<String> _sessionTitles = [
    'Guided Meditation',
    'Meditation Timer',
    'Progress Tracking',
  ];

  final List<Map<String, dynamic>> _guidedMeditations = [
    {
      'title': 'Mindfulness Meditation',
      'steps': [
        'Find a quiet place',
        'Sit comfortably',
        'Focus on your breath',
        'Observe your thoughts',
        'Stay for 5-10 minutes'
      ],
      'image': 'assets/images/mindfulness.jpg', // Replace with your image asset path
    },
    {
      'title': 'Loving-Kindness Meditation',
      'steps': [
        'Close your eyes',
        'Focus on someone you love',
        'Send them good wishes',
        'Expand to others',
        'Repeat for 5 minutes'
      ],
      'image': 'assets/images/lovingkind.jpg', // Replace with your image asset path
    },
    {
      'title': 'Breath Awareness Meditation',
      'steps': [
        'Find a quiet place and sit comfortably',
        'Close your eyes or keep them softly open',
        'Bring your awareness to the sensation of your breath',
        'Notice the rise and fall of your abdomen or the feeling of air passing through your nostrils',
        'When your mind wanders, gently bring it back to your breath',
        'Practice for 10-15 minutes or longer'
      ],
      'image':
          'assets/images/breathe awareness.jpg', // Replace with your image asset path
    },
    {
      'title': 'Zen Meditation',
      'steps': [
        'Find a quiet place and sit in a comfortable posture',
        'Focus on your breath or a specific koan (a riddle or question)',
        'Maintain a straight spine and relaxed shoulders',
        'Allow thoughts to arise and pass without engaging with them',
        'If using a koan, contemplate it deeply without seeking a logical answer',
        'Practice for a set period, often guided by a timer'
      ],
      'image': 'assets/images/zennnn.jpg', // Replace with your image asset path
    },
    {
      'title': 'Transcendental Meditation',
      'steps': [
        'Receive a personalized mantra from a certified TM teacher',
        'Find a quiet place and sit comfortably',
        'Close your eyes and silently repeat your mantra',
        'Allow the mantra to become increasingly subtle and effortless',
        'Practice for 20 minutes twice a day',
      ],
      'image':
          'assets/images/transcedental.jpg', // Replace with your image asset path
    },
    {
      'title': 'Chakra Meditation',
      'steps': [
        'Find a quiet place and sit comfortably',
        'Bring your awareness to the base of your spine (root chakra)',
        'Visualize the color associated with the chakra (red) and repeat its seed sound (LAM)',
        'Move your awareness up through each chakra, visualizing its color and repeating its seed sound (orange-VAM, yellow-RAM, green-YAM, blue-HAM, indigo-OM, violet-no sound)',
        'Focus on balancing and aligning each chakra',
        'Practice for 15-20 minutes or longer'
      ],
      'image': 'assets/images/chakra.jpg', // Replace with your image asset path
    },
    {
      'title': 'Vipassana Meditation',
      'steps': [
        'Find a quiet place and sit comfortably',
        'Bring your awareness to the sensations of your breath',
        'Observe all bodily sensations, thoughts, and emotions without judgment',
        'Notice the impermanent nature of these experiences',
        'Practice for extended periods, often in retreats with structured guidance',
      ],
      'image': 'assets/images/vipassana.jpg', // Replace with your image asset path
    },
    {
      'title': 'Yoga Nidra',
      'steps': [
        'Lie down on your back in a comfortable position',
        'Listen to a guided meditation that systematically relaxes your body and mind',
        'Set an intention or resolve for your practice',
        'Rotate your awareness through different parts of your body',
        'Visualize images and experiences as directed',
        'Remain in a state of deep relaxation while maintaining awareness',
      ],
      'image': 'assets/images/yogan.jpg', // Replace with your image asset path
    },
    {
      'title': 'Visualization Meditation',
      'steps': [
        'Find a quiet place and sit or lie down comfortably',
        'Close your eyes and take a few deep breaths',
        'Visualize a peaceful or positive scene in your mind',
        'Engage all your senses to make the visualization vivid',
        'Focus on the positive feelings and emotions associated with the visualization',
        'Practice for 10-15 minutes or longer'
      ],
      'image': 'assets/images/scene.jpg', // Replace with your image asset path
    },
  ];

  // Function to start the meditation timer.
  void _startMeditationTimer(String meditationTitle, int duration) {
    _timer?.cancel(); // Cancel any existing timer.
    setState(() {
      _isTimerRunning = true;
      _progress = duration;
    });

    // Start the timer and update the UI.
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_progress > 0) {
        setState(() {
          _progress--;
        });
        // Send progress to background
        try {
          await _backgroundChannel.invokeMethod('updateProgress', {
            'progress': _progress,
            'duration': duration,
          });
        } catch (e) {
          if (kDebugMode) {
            print('Error sending progress: $e');
          }
        }
      } else {
        timer.cancel();
        setState(() {
          _isTimerRunning = false;
        });
        _completedSessions.add('$meditationTitle - ${duration ~/ 60} min');
        // Notify background
        try {
          await _backgroundChannel.invokeMethod('onTimerFinished');
        } catch (e) {
          if (kDebugMode) {
            print('Error notifying timer finished: $e');
          }
        }
      }
    });
    //send data to the backgroundisolate
    _startBackgroundTimer(meditationTitle, duration);
  }

  // Function to start timer in background isolate
  Future<void> _startBackgroundTimer(String meditationTitle, int duration) async {
    try {
      await _backgroundChannel.invokeMethod('startTimer', {
        'meditationTitle': meditationTitle,
        'duration': duration,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error starting background timer: $e');
      }
    }
  }

  void _cancelMeditationTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      setState(() {
        _isTimerRunning = false;
        _progress = 0;
      });
      //stop timer
      _stopBackgroundTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meditation timer cancelled.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _stopBackgroundTimer() async {
    try {
      await _backgroundChannel.invokeMethod('stopTimer');
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping background timer: $e');
      }
    }
  }

  void _showMeditationSteps(Map<String, dynamic> meditation) {
    int selectedDuration = 5;
    if (_isTimerRunning) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cancel Current Meditation?'),
          content: Text(
              'A meditation timer is currently running. Do you want to cancel it and start a new one?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                _cancelMeditationTimer();
                Navigator.pop(context);
                _showMeditationStepsDialog(meditation, selectedDuration);
              },
              child: Text('Yes, Cancel'),
            ),
          ],
        ),
      );
    } else {
      _showMeditationStepsDialog(meditation, selectedDuration);
    }
  }

void _showMeditationStepsDialog(
      Map<String, dynamic> meditation, int initialDuration) {
    int selectedDuration = initialDuration;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(meditation['title']),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Choose duration: '),
                      DropdownButton<int>(
                        value: selectedDuration,
                        onChanged: (value) {
                          setState(() {
                            selectedDuration = value!;
                            print("Selected duration: $selectedDuration");
                          });
                        },
                        items: [1, 2, 5, 10, 15, 20, 25, 30]
                            .map((time) => DropdownMenuItem(
                                  value: time,
                                  child: Text('$time minutes'),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  /*** STYLED STEPS SECTION ***/
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meditation['steps'].map<Widget>((step) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 15.0, bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(fontSize: 16)), // Custom bullet
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  /*** END STYLED STEPS SECTION ***/
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startMeditationTimer(
                        meditation['title'], selectedDuration * 60);
                  },
                  child: Text('Start Meditation'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PeaceU'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Hello!',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('What would you like to do?'),
            SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sessionTitles.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSession = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: _selectedSession == index
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          _sessionTitles[index],
                          style: TextStyle(
                            color: _selectedSession == index
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _selectedSession == 0
                  ? Container(
                      // Set background color for Guided Meditation
                      color: Colors.lightBlue[50], // Light blue background
                      child: ListView.builder(
                        itemCount: _guidedMeditations.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              elevation: 4.0,
                              child: InkWell(
                                onTap: () => _showMeditationSteps(
                                    _guidedMeditations[index]),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                                                          //ADD THIS LINE
                                      child: Image.asset(
                                        _guidedMeditations[index]['image'],
                                        fit: BoxFit.cover,
                                                                                //AND THIS LINE
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        _guidedMeditations[index]['title'],
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : _selectedSession == 1
                      ? Column(
                          children: [
                            // Use a Card for the timer display
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: EdgeInsets.all(20),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Text(
                                      _isTimerRunning
                                          ? 'Time Remaining'
                                          : 'Meditation Timer',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: _isTimerRunning
                                            ? Colors.blue
                                            : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Display time
                                    Text(
                                      _isTimerRunning
                                          ? '${(_progress ~/ 60).toString().padLeft(2, '0')}:${(_progress % 60).toString().padLeft(2, '0')}'
                                          : '00:00',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: _isTimerRunning
                                            ? Colors.redAccent
                                            : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    LinearProgressIndicator(
                                      value: _isTimerRunning
                                          ? _progress / _duration
                                          : 0,
                                      minHeight: 20,
                                      color: Colors.greenAccent,
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isTimerRunning) ...[
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _cancelMeditationTimer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 15),
                                  textStyle: TextStyle(fontSize: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text("Cancel Timer"),
                              ),
                            ],
                          ],
                        )
                      : _selectedSession == 2
                          ? ListView.builder(
                              itemCount: _completedSessions.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(
                                      _completedSessions[index],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    leading: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(),
            ),
          ],
        ),
      ),
    );
  }
}

