import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5EE), // Cream
      appBar: AppBar(
        title: Text(
          'Profile', 
          style: GoogleFonts.outfit(
            color: const Color(0xFF850E35), 
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF850E35))
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                 Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEE6983), width: 2)
                  ),
                   child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Color(0xFFEE6983)),
                   ),
                 ),
                 Container(
                   decoration: BoxDecoration(
                     color: const Color(0xFF850E35),
                     shape: BoxShape.circle,
                     border: Border.all(color: Colors.white, width: 2)
                   ),
                   child: const Padding(
                     padding: EdgeInsets.all(6.0),
                     child: Icon(Icons.edit, size: 14, color: Colors.white),
                   ),
                 )
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "User Name",
              style: GoogleFonts.outfit(
                color: const Color(0xFF850E35), 
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
            Text(
              "user@truetone.com",
              style: GoogleFonts.outfit(color: const Color(0xFF850E35).withOpacity(0.6)),
            ),
            const SizedBox(height: 40),
            
            _buildProfileItem(Icons.settings_outlined, "Settings"),
            _buildProfileItem(Icons.history, "History"),
            _buildProfileItem(Icons.help_outline, "Help & Support"),
            _buildProfileItem(Icons.logout, "Logout", isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         border: Border.all(color: const Color(0xFFFFC4C4)), // Light Pink Border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEE6983).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.withOpacity(0.1) : const Color(0xFF850E35).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(
            icon, 
            color: isDestructive ? Colors.red : const Color(0xFF850E35)
          ),
        ),
        title: Text(
          title, 
          style: GoogleFonts.outfit(
            color: isDestructive ? Colors.red : const Color(0xFF850E35),
            fontWeight: FontWeight.w600,
            fontSize: 16
          )
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: const Color(0xFF850E35).withOpacity(0.3)),
        onTap: () {},
      ),
    );
  }
}
