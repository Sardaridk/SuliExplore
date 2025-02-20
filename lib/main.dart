import 'package:flutter/material.dart';
import 'animated_splash_screen.dart'; // Import the animated splash screen
import 'home_screen.dart';
import 'map_screen.dart';
import 'favorites_screen.dart';
import 'weather_screen.dart';
import 'digital_assistant_screen.dart';
import 'UserProfile/profile.dart';

void main() {
  runApp(const TourismApp());
}

class TourismApp extends StatefulWidget {
  const TourismApp({super.key});

  @override
  _TourismAppState createState() => _TourismAppState();
}

class _TourismAppState extends State<TourismApp> {
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.light;

  List<Widget> get _screens => [
        const HomeScreen(),
        const MapScreen(),
        const UserProfileScreen(
          name: '',
          email: '',
          profilePicture: '',
        ),
        WeatherScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF757575)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: AnimatedSplashScreen(),
      routes: {
        '/main': (context) => Scaffold(
              appBar: AppBar(
                title: const Text("Suli Explore"),
              ),

              //krdnaway drawer
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/wallpaper.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        _themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      title: const Text('Theme Mode'),
                      onTap: () {
                        _toggleTheme();
                        Navigator.pop(context); // daxstni drawer
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.assistant),
                      title: Text('Digital Assistant'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              title: 'Ask About Sulaymaniyah',
                              titleStyle: TextStyle(),
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.favorite),
                      title: Text('Favorite Places'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              body: _screens[_selectedIndex],

              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.place), label: 'Map'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Profile'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.cloud_circle_sharp), label: 'Weather'),
                ],
                selectedItemColor: Colors.teal,
                unselectedItemColor: const Color.fromARGB(255, 88, 129, 124),
              ),
            ),
      },
    );
  }
}
