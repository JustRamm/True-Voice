import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5EE), // Cream
      appBar: AppBar(
        title: Text(
          'Messages', 
          style: GoogleFonts.outfit(
            color: const Color(0xFF850E35),
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEE6983).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: Icon(
                Icons.mark_chat_unread_outlined, 
                size: 60, 
                color: const Color(0xFFEE6983).withOpacity(0.5)
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No messages yet',
              style: GoogleFonts.outfit(
                color: const Color(0xFF850E35), 
                fontSize: 20,
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with your cloned voice!',
              style: GoogleFonts.outfit(
                color: const Color(0xFF850E35).withOpacity(0.5), 
                fontSize: 14
              ),
            ),
          ],
        ),
      ),
    );
  }
}
