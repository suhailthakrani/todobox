// Helper method to register object creation

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todobox/data/models/todo_model.dart';
import 'package:todobox/data/repositories/todo_repository.dart';
import 'package:todobox/presentation/blocs/todo/todo_bloc.dart';
import 'package:todobox/presentation/blocs/todo/todo_event.dart';
import 'package:todobox/presentation/blocs/todo/todo_state.dart';
import 'package:uuid/uuid.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  setUpAllRegistrations();

  late TodoRepository mockRepository;
  late TodoBloc todoBloc;

  // Create some sample todos with consistent creation
  TodoModel createTodo(String title, {String? id, bool completed = false}) {
    return TodoModel(
      id: id ?? const Uuid().v4(),
      title: title,
      isCompleted: completed,
    );
  }

  setUp(() {
    mockRepository = MockTodoRepository();
    todoBloc = TodoBloc(repository: mockRepository);
  });

  tearDown(() {
    todoBloc.close();
  });

  test('initial state is TodoInitial', () {
    expect(todoBloc.state, isA<TodoInitial>());
  });

  blocTest<TodoBloc, TodoState>(
  'emits TodoLoaded when LoadTodos is added and repository returns todos',
  build: () {
    final todos = [
      createTodo('Test Todo 1', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec'),
      createTodo('Test Todo 2', id: 'd69b7465-0554-4893-b612-bee214bb233c'),
    ];
    when(() => mockRepository.getAllTodos()).thenReturn(Right(todos));
    return todoBloc;
  },
  act: (bloc) => bloc.add(LoadTodos()),
  expect: () => [
    isA<TodoLoading>(),
    TodoLoaded([
      createTodo('Test Todo 1', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec'),
      createTodo('Test Todo 2', id: 'd69b7465-0554-4893-b612-bee214bb233c'),
    ]),
  ],
);


  blocTest<TodoBloc, TodoState>(
    'emits TodoError when LoadTodos fails',
    build: () {
      when(() => mockRepository.getAllTodos())
          .thenReturn(const Left('Error loading todos'));
      return todoBloc;
    },
    act: (bloc) => bloc.add(LoadTodos()),
    expect: () => [
      isA<TodoLoading>(),
      const TodoError('Error loading todos'),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'emits updated TodoLoaded when AddTodo is successful',
    build: () {
      final initialTodos = [
        createTodo('Test Todo 1', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec'),
      ];
      final newTodo = createTodo('Test Todo Updated', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec');

      when(() => mockRepository.getAllTodos()).thenReturn(Right(initialTodos));

      when(() => mockRepository.addTodo(any())).thenReturn(Right(newTodo));

      return todoBloc;
    },
    seed: () => TodoLoaded([createTodo('Test Todo 1', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec')]),
    act: (bloc) => bloc.add(AddTodo(createTodo('Test Todo Updated', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec'))),
    expect: () => [
      TodoLoaded([
        createTodo('Test Todo 1', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec'),
        createTodo('Test Todo Updated', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec'),
      ]),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'emits TodoError when AddTodo fails',
    build: () {
      createTodo('New Todo');

      when(() => mockRepository.addTodo(any()))
          .thenReturn(const Left('Failed to add todo'));

      return todoBloc;
    },
    seed: () => const TodoLoaded([]),
    act: (bloc) => bloc.add(AddTodo(createTodo('New Todo'))),
    expect: () => [
      const TodoError('Failed to add todo'),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'emits updated TodoLoaded when UpdateTodo is successful',
    build: () {
      // final existingTodo = createTodo('Existing Todo', id: '31556755-22c6-4bd9-8e58-beaaadcd3aec');
      final updatedTodo = createTodo('Existing Todo', id: '31556755-22c6-4bd9-8e58-beaaadcd3aec', completed: true);

      when(() => mockRepository.updateTodo(any()))
          .thenReturn(Right(updatedTodo));

      return todoBloc;
    },
    seed: () => TodoLoaded([createTodo('Existing Todo', id: '31556755-22c6-4bd9-8e58-beaaadcd3aec')]),
    act: (bloc) =>
        bloc.add(UpdateTodo(createTodo('Existing Todo', id: '31556755-22c6-4bd9-8e58-beaaadcd3aec', completed: true))),
    expect: () => [
      TodoLoaded([
        createTodo('Existing Todo', id: '31556755-22c6-4bd9-8e58-beaaadcd3aec', completed: true),
      ]),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'emits updated TodoLoaded when DeleteTodo is successful',
    build: () {
      // Create a todo with a specific, known ID
      createTodo('Todo to Delete', id: '31556755-22c6-4bd9-8e58-beaaadcd3aec');

      when(() => mockRepository.deleteTodo('31556755-22c6-4bd9-8e58-beaaadcd3aec'))
          .thenReturn(const Right(true));

      return todoBloc;
    },
    seed: () =>
        TodoLoaded([createTodo('Todo to Delete', id: '31556755-22c6-4bd9-8e58-beaaadcd3aec')]),
    act: (bloc) => bloc.add(const DeleteTodo('31556755-22c6-4bd9-8e58-beaaadcd3aec')),
    expect: () => [
      const TodoLoaded([]),
    ],
  );
}

void setUpAllRegistrations() {
  registerFallbackValue(TodoModel(title: 'Fallback Todo'));
}
