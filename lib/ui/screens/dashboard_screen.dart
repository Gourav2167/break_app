import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:have_a_break/core/services/usage_provider.dart';
import 'package:have_a_break/core/models/usage_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hidden initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usageActionsProvider).startTracking();
    });

    final usageAsync = ref.watch(usageTrackerProvider);
    
    // Smooth loading: Use the previous state if current is loading to avoid flickering
    final logs = usageAsync.value ?? [];
    final totalSeconds = logs.fold<int>(0, (sum, log) => sum + log.durationSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(ref: ref),
                    const SizedBox(height: 80),
                    _TotalTime(totalSeconds: totalSeconds),
                    const SizedBox(height: 16),
                    Center(child: _BreakTip(totalSeconds: totalSeconds)),
                    const SizedBox(height: 64),
                    const _Subheader(title: 'APP USAGE'),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _AppItem(log: logs[index]),
                  childCount: logs.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final WidgetRef ref;
  const _Header({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'be present.',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w200,
                letterSpacing: -1.0,
                color: Colors.white70,
              ),
            ),
            Text(
              'have_a_break',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white38,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => ref.read(usageActionsProvider).requestPermission(),
          icon: const Icon(Icons.settings_outlined, color: Colors.white24, size: 20),
        ),
      ],
    );
  }
}

class _TotalTime extends StatelessWidget {
  final int totalSeconds;
  const _TotalTime({required this.totalSeconds});

  @override
  Widget build(BuildContext context) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;

    return Center(
      child: Column(
        children: [
          Text(
            "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}",
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w100,
              letterSpacing: -3.0,
              color: Colors.white,
            ),
          ),
          const Text(
            'TOTAL TIME TODAY',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2.0,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppItem extends StatelessWidget {
  final UsageModel log;
  const _AppItem({required this.log});

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.apps_outlined, size: 20, color: Colors.white12),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  log.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.white24),
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(log.durationSeconds),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white54,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakTip extends StatelessWidget {
  final int totalSeconds;
  const _BreakTip({required this.totalSeconds});

  @override
  Widget build(BuildContext context) {
    final minutes = totalSeconds / 60;
    String tip = "You're doing great.";
    if (minutes > 60) tip = "Take a short walk.";
    if (minutes > 120) tip = "Look away from screens.";
    if (minutes > 300) tip = "Digital detox highly recommended.";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tip,
        style: const TextStyle(fontSize: 11, color: Colors.white38, fontStyle: FontStyle.italic),
      ),
    );
  }
}

class _Subheader extends StatelessWidget {
  final String title;
  const _Subheader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 2.0,
        color: Colors.white24,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
