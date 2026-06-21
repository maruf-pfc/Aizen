import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_fonts/google_fonts.dart';

import 'features/stopwatch/data/datasources/stopwatch_local_data_source.dart';
import 'features/stopwatch/data/repositories/stopwatch_repository_impl.dart';
import 'features/stopwatch/domain/usecases/clear_stopwatch_data.dart';
import 'features/stopwatch/domain/usecases/get_laps.dart';
import 'features/stopwatch/domain/usecases/get_stopwatch_state.dart';
import 'features/stopwatch/domain/usecases/save_laps.dart';
import 'features/stopwatch/domain/usecases/save_stopwatch_state.dart';
import 'features/stopwatch/presentation/bloc/stopwatch_bloc.dart';
import 'features/stopwatch/presentation/pages/stopwatch_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  // Data sources
  final localDataSource = StopwatchLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );

  // Repositories
  final repository = StopwatchRepositoryImpl(
    localDataSource: localDataSource,
  );

  // Use cases
  final getStopwatchState = GetStopwatchState(repository);
  final saveStopwatchState = SaveStopwatchState(repository);
  final getLaps = GetLaps(repository);
  final saveLaps = SaveLaps(repository);
  final clearStopwatchData = ClearStopwatchData(repository);

  runApp(
    MyApp(
      getStopwatchState: getStopwatchState,
      saveStopwatchState: saveStopwatchState,
      getLaps: getLaps,
      saveLaps: saveLaps,
      clearStopwatchData: clearStopwatchData,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetStopwatchState getStopwatchState;
  final SaveStopwatchState saveStopwatchState;
  final GetLaps getLaps;
  final SaveLaps saveLaps;
  final ClearStopwatchData clearStopwatchData;

  const MyApp({
    super.key,
    required this.getStopwatchState,
    required this.saveStopwatchState,
    required this.getLaps,
    required this.saveLaps,
    required this.clearStopwatchData,
  });

  @override
  Widget build(BuildContext context) {
    final baseDarkTheme = ThemeData.dark(useMaterial3: true);
    return MaterialApp(
      title: 'Aizen',
      debugShowCheckedModeBanner: false,
      theme: baseDarkTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C4DFF),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF0C0C0C),
        ),
        textTheme: GoogleFonts.lexendTextTheme(baseDarkTheme.textTheme),
      ),
      home: BlocProvider(
        create: (context) => StopwatchBloc(
          getStopwatchState: getStopwatchState,
          saveStopwatchState: saveStopwatchState,
          getLaps: getLaps,
          saveLaps: saveLaps,
          clearStopwatchData: clearStopwatchData,
        ),
        child: const StopwatchPage(),
      ),
    );
  }
}
