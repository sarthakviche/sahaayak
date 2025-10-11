import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'main.dart'; // For AuthStateWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // --- Video Initialization and Navigation ---
    _videoController = VideoPlayerController.asset('assets/videos/intro_video.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown and play the video
        setState(() {});
        _videoController.setVolume(0); // Mute the video
        _videoController.play();

        // ✅ NEW: Navigate AFTER the video finishes playing
        // We add a listener that triggers navigation when the video is complete.
        _videoController.addListener(() {
          // Check if the video has finished
          if (_videoController.value.position == _videoController.value.duration) {
            _navigateToNextScreen();
          }
        });
      });
  }

  void _navigateToNextScreen() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        // Use a fade transition for a smoother screen change
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AuthStateWrapper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A black background is standard for video splash screens
      backgroundColor: Colors.black,
      body: Center(
        // Show a loading indicator while the video is initializing
        child: _videoController.value.isInitialized
            // Once initialized, show the full-screen video
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}