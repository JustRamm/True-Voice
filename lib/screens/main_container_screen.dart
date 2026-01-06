import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'voice_synthesis_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const VoiceSynthesisScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5EE), // Cream
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF850E35).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: const Color(0xFFEE6983).withOpacity(0.2),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                 if (states.contains(WidgetState.selected)) {
                   return GoogleFonts.outfit(
                     color: const Color(0xFF850E35), 
                     fontSize: 12, 
                     fontWeight: FontWeight.bold
                   );
                 }
                 return GoogleFonts.outfit(
                   color: const Color(0xFF850E35).withOpacity(0.6), 
                   fontSize: 12
                 );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                 if (states.contains(WidgetState.selected)) {
                   return const IconThemeData(color: Color(0xFF850E35)); // Burgundy
                 }
                 return IconThemeData(color: const Color(0xFF850E35).withOpacity(0.5));
              }),
            ),
            child: NavigationBar(
              height: 70,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.graphic_eq),
                  selectedIcon: Icon(Icons.graphic_eq),
                  label: 'Synthesis',
                ),
                NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum),
                  label: 'Messages',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
