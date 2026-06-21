import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';

// Stopwatch feature imports
import 'features/stopwatch/data/datasources/stopwatch_local_data_source.dart';
import 'features/stopwatch/data/repositories/stopwatch_repository_impl.dart';
import 'features/stopwatch/domain/usecases/clear_stopwatch_data.dart';
import 'features/stopwatch/domain/usecases/get_laps.dart';
import 'features/stopwatch/domain/usecases/get_stopwatch_state.dart';
import 'features/stopwatch/domain/usecases/save_laps.dart';
import 'features/stopwatch/domain/usecases/save_stopwatch_state.dart';
import 'features/stopwatch/presentation/bloc/stopwatch_bloc.dart';

// Device Info feature imports
import 'features/device_info/data/datasources/device_info_local_data_source.dart';
import 'features/device_info/data/repositories/device_info_repository_impl.dart';
import 'features/device_info/domain/usecases/get_hardware_info.dart';
import 'features/device_info/domain/usecases/get_storage_info.dart';
import 'features/device_info/domain/usecases/stream_battery_info.dart';
import 'features/device_info/presentation/bloc/device_info_bloc.dart';

// Todo feature imports
import 'features/todo/data/datasources/todo_local_data_source.dart';
import 'features/todo/data/services/nlp_parser_service.dart';
import 'features/todo/data/repositories/todo_repository_impl.dart';
import 'features/todo/domain/usecases/get_tasks.dart';
import 'features/todo/domain/usecases/save_task.dart';
import 'features/todo/domain/usecases/delete_task.dart';
import 'features/todo/domain/usecases/parse_nlp_input.dart';
import 'features/todo/presentation/bloc/todo_bloc.dart';

// Dashboard import
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Shared dependencies
  final sharedPreferences = await SharedPreferences.getInstance();

  // Device Info Plugins
  final deviceInfoPlugin = DeviceInfoPlugin();
  final battery = Battery();

  // Stopwatch feature wiring
  final stopwatchLocalDataSource = StopwatchLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );
  final stopwatchRepository = StopwatchRepositoryImpl(
    localDataSource: stopwatchLocalDataSource,
  );
  final getStopwatchState = GetStopwatchState(stopwatchRepository);
  final saveStopwatchState = SaveStopwatchState(stopwatchRepository);
  final getLaps = GetLaps(stopwatchRepository);
  final saveLaps = SaveLaps(stopwatchRepository);
  final clearStopwatchData = ClearStopwatchData(stopwatchRepository);

  // Device Info feature wiring
  final deviceInfoLocalDataSource = DeviceInfoLocalDataSourceImpl(
    deviceInfoPlugin: deviceInfoPlugin,
    battery: battery,
  );
  final deviceInfoRepository = DeviceInfoRepositoryImpl(
    localDataSource: deviceInfoLocalDataSource,
  );
  final getHardwareInfo = GetHardwareInfo(deviceInfoRepository);
  final getStorageInfo = GetStorageInfo(deviceInfoRepository);
  final streamBatteryInfo = StreamBatteryInfo(deviceInfoRepository);

  // Todo feature wiring
  final todoLocalDataSource = TodoLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );
  final todoRepository = TodoRepositoryImpl(
    localDataSource: todoLocalDataSource,
    nlpParserService: const NlpParserService(),
  );
  final getTasks = GetTasks(todoRepository);
  final saveTask = SaveTask(todoRepository);
  final deleteTask = DeleteTask(todoRepository);
  final parseNlpInput = ParseNlpInput(todoRepository);

  runApp(
    MyApp(
      getStopwatchState: getStopwatchState,
      saveStopwatchState: saveStopwatchState,
      getLaps: getLaps,
      saveLaps: saveLaps,
      clearStopwatchData: clearStopwatchData,
      getHardwareInfo: getHardwareInfo,
      getStorageInfo: getStorageInfo,
      streamBatteryInfo: streamBatteryInfo,
      getTasks: getTasks,
      saveTask: saveTask,
      deleteTask: deleteTask,
      parseNlpInput: parseNlpInput,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetStopwatchState getStopwatchState;
  final SaveStopwatchState saveStopwatchState;
  final GetLaps getLaps;
  final SaveLaps saveLaps;
  final ClearStopwatchData clearStopwatchData;

  final GetHardwareInfo getHardwareInfo;
  final GetStorageInfo getStorageInfo;
  final StreamBatteryInfo streamBatteryInfo;

  final GetTasks getTasks;
  final SaveTask saveTask;
  final DeleteTask deleteTask;
  final ParseNlpInput parseNlpInput;

  const MyApp({
    super.key,
    required this.getStopwatchState,
    required this.saveStopwatchState,
    required this.getLaps,
    required this.saveLaps,
    required this.clearStopwatchData,
    required this.getHardwareInfo,
    required this.getStorageInfo,
    required this.streamBatteryInfo,
    required this.getTasks,
    required this.saveTask,
    required this.deleteTask,
    required this.parseNlpInput,
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<StopwatchBloc>(
            create: (context) => StopwatchBloc(
              getStopwatchState: getStopwatchState,
              saveStopwatchState: saveStopwatchState,
              getLaps: getLaps,
              saveLaps: saveLaps,
              clearStopwatchData: clearStopwatchData,
            ),
          ),
          BlocProvider<DeviceInfoBloc>(
            create: (context) => DeviceInfoBloc(
              getHardwareInfo: getHardwareInfo,
              getStorageInfo: getStorageInfo,
              streamBatteryInfo: streamBatteryInfo,
            ),
          ),
          BlocProvider<TodoBloc>(
            create: (context) => TodoBloc(
              getTasks: getTasks,
              saveTask: saveTask,
              deleteTask: deleteTask,
              parseNlpInput: parseNlpInput,
            ),
          ),
        ],
        child: const DashboardPage(),
      ),
    );
  }
}
