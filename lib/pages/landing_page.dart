import 'package:flutter/material.dart';
import 'login_page.dart';

class LandingPage extends StatelessWidget {
  final Color primary = const Color(0xFF111111);
  final Color secondary = const Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "NOTES",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Minimal. Powerful. Yours.",
              style: TextStyle(color: secondary),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Mulai"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}