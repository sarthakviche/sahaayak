import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page.dart';
import 'home_page.dart';
import 'chat_page.dart';
import 'resources_page.dart';
import 'splash_screen.dart'; // Import the new splash screen
import 'support_network_page.dart';
import 'counselors_screen.dart';
import 'calm.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fzwectrxxjcumhfefipe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ6d2VjdHJ4eGpjdW1oZmVmaXBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1MjQ0ODAsImV4cCI6MjA3NDEwMDQ4MH0.MOduQWH-FQ6FzeViSICVApOu4vDCEaWLYrAIH33elwk',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahayaak',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF0F5E6),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // The app now starts with the splash screen
    );
  }
}

class AuthStateWrapper extends StatefulWidget {
  const AuthStateWrapper({super.key});

  @override
  State<AuthStateWrapper> createState() => _AuthStateWrapperState();
}

class _AuthStateWrapperState extends State<AuthStateWrapper> {
  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (mounted) {
        if (event == AuthChangeEvent.signedIn) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AppShell()),
          );
        } else if (event == AuthChangeEvent.signedOut) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthPage()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (supabase.auth.currentSession != null) {
      return const AppShell();
    }
    return const AuthPage();
  }
}

// App Shell with Bottom Navigation Bar
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const ChatPage(),
    const ResourcesPage(), // This now links to the actual ResourcesPage
    const CounselorsScreen(),
    const SupportNetworkPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF5A8E3F),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: _onItemTapped,
      ),
    );
  }
}
