import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/usage_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.remove_red_eye_outlined, size: 80, color: Colors.white24),
              const SizedBox(height: 48),
              const Text(
                'Observe your habits.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'have_a_break needs permission to track which apps are keeping you busy. This data stays on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white38,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 64),
              GestureDetector(
                onTap: () async {
                  await ref.read(usageActionsProvider).requestPermission();
                  // In a real app, check if permission is granted before navigating
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'GRANT ACCESS',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2.0,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  // Skip or navigate back
                },
                child: const Text(
                  'maybe later',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
