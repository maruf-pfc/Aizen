import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:Aizen/core/error/failures.dart';
import 'package:Aizen/features/todo/domain/entities/task.dart';
import 'package:Aizen/features/todo/domain/entities/nlp_parsed_result.dart';
import 'package:Aizen/features/todo/domain/usecases/get_tasks.dart';
import 'package:Aizen/features/todo/domain/usecases/save_task.dart';
import 'package:Aizen/features/todo/domain/usecases/delete_task.dart';
import 'package:Aizen/features/todo/domain/usecases/parse_nlp_input.dart';
import 'package:Aizen/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:Aizen/features/todo/presentation/bloc/todo_event.dart';
import 'package:Aizen/features/todo/presentation/bloc/todo_state.dart';

class MockGetTasks extends Mock implements GetTasks {}
class MockSaveTask extends Mock implements SaveTask {}
class MockDeleteTask extends Mock implements DeleteTask {}
class MockParseNlpInput extends Mock implements ParseNlpInput {}

void main() {
  late MockGetTasks mockGetTasks;
  late MockSaveTask mockSaveTask;
  late MockDeleteTask mockDeleteTask;
  late MockParseNlpInput mockParseNlpInput;
  late TodoBloc bloc;

  final tTask = Task(
    id: '1',
    title: 'Test Task',
    isCompleted: false,
    priority: 4,
    createdAt: DateTime(2026, 6, 21),
  );

  final tTasksList = [tTask];

  setUp(() {
    mockGetTasks = MockGetTasks();
    mockSaveTask = MockSaveTask();
    mockDeleteTask = MockDeleteTask();
    mockParseNlpInput = MockParseNlpInput();

    bloc = TodoBloc(
      getTasks: mockGetTasks,
      saveTask: mockSaveTask,
      deleteTask: mockDeleteTask,
      parseNlpInput: mockParseNlpInput,
    );

    registerFallbackValue(tTask);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be initial', () {
    expect(bloc.state.status, TodoStatus.initial);
    expect(bloc.state.tasks, isEmpty);
    expect(bloc.state.sortOrder, SortOrder.priority);
  });

  blocTest<TodoBloc, TodoState>(
    'should emit [loading, success] with sorted tasks when load is successful',
    build: () {
      when(() => mockGetTasks()).thenAnswer((_) async => (null, tTasksList));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadTodosEvent()),
    expect: () => [
      const TodoState(status: TodoStatus.loading),
      TodoState(status: TodoStatus.success, tasks: tTasksList),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'should emit [loading, failure] when loading tasks fails',
    build: () {
      when(() => mockGetTasks()).thenAnswer(
        (_) async => (const PlatformFailure('Database Error'), null),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadTodosEvent()),
    expect: () => [
      const TodoState(status: TodoStatus.loading),
      const TodoState(
        status: TodoStatus.failure,
        errorMessage: 'Database Error',
      ),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'should parse input and call saveTask when AddTodoEvent is triggered',
    build: () {
      when(() => mockParseNlpInput(any())).thenAnswer(
        (_) async => (null, const NlpParsedResult(title: 'New Parsed Task', priority: 1)),
      );
      when(() => mockSaveTask(any())).thenAnswer((_) async => (null, null));
      when(() => mockGetTasks()).thenAnswer((_) async => (null, <Task>[]));
      return bloc;
    },
    act: (bloc) => bloc.add(const AddTodoEvent('New Task !!1')),
    verify: (bloc) {
      verify(() => mockParseNlpInput('New Task !!1')).called(1);
      verify(() => mockSaveTask(any())).called(1);
    },
  );
}
