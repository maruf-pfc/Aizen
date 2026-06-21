import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/stopwatch_bloc.dart';
import '../bloc/stopwatch_event.dart';
import '../bloc/stopwatch_state.dart';
import '../widgets/control_buttons.dart';
import '../widgets/lap_list_panel.dart';
import '../widgets/stopwatch_timer_display.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  @override
  void initState() {
    super.initState();
    context.read<StopwatchBloc>().add(const LoadStopwatchDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // AMOLED Pure Black
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 20),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Row(
          children: [
            Icon(
              Icons.timer_outlined,
              color: Color(0xFF7C4DFF),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'AIZEN STOPWATCH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<StopwatchBloc, StopwatchState>(
            builder: (context, state) {
              if (state.laps.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: Text(
                      '${state.laps.length} LAPS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<StopwatchBloc, StopwatchState>(
          listener: (context, state) {
            if (state.status == StopwatchStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFFF5252),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == StopwatchStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C4DFF)),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                if (isWide) {
                  return _buildWideLayout(state);
                } else {
                  return _buildNarrowLayout(state);
                }
              },
            );
          },
        ),
      ),
    );
  }

  // Mobile layout
  Widget _buildNarrowLayout(StopwatchState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timer card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: state.isRunning
                    ? const Color(0xFF7C4DFF).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: state.isRunning
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.05),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Column(
              children: [
                StopwatchTimerDisplay(
                  baseElapsedTime: state.elapsedTime,
                  startTime: state.startTime,
                  isRunning: state.isRunning,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -1,
                  ),
                  milliTextStyle: TextStyle(
                    color: state.isRunning
                        ? const Color(0xFF7C4DFF)
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                ControlButtons(
                  status: state.status,
                  onStart: () => context.read<StopwatchBloc>().add(const StartStopwatchEvent()),
                  onPause: () => context.read<StopwatchBloc>().add(const PauseStopwatchEvent()),
                  onReset: () => context.read<StopwatchBloc>().add(const ResetStopwatchEvent()),
                  onLap: () => context.read<StopwatchBloc>().add(const AddLapEvent()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Laps list
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LapListPanel(laps: state.laps),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tablet/Desktop layout
  Widget _buildWideLayout(StopwatchState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Timer panel
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: state.isRunning
                      ? const Color(0xFF7C4DFF).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: state.isRunning
                    ? [
                        BoxShadow(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.05),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  StopwatchTimerDisplay(
                    baseElapsedTime: state.elapsedTime,
                    startTime: state.startTime,
                    isRunning: state.isRunning,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -1.5,
                    ),
                    milliTextStyle: TextStyle(
                      color: state.isRunning
                          ? const Color(0xFF7C4DFF)
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  ControlButtons(
                    status: state.status,
                    onStart: () => context.read<StopwatchBloc>().add(const StartStopwatchEvent()),
                    onPause: () => context.read<StopwatchBloc>().add(const PauseStopwatchEvent()),
                    onReset: () => context.read<StopwatchBloc>().add(const ResetStopwatchEvent()),
                    onLap: () => context.read<StopwatchBloc>().add(const AddLapEvent()),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right side: Laps table
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LapListPanel(laps: state.laps),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
