import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todobox/data/models/todo_model.dart';
import 'package:todobox/data/repositories/todo_repository.dart';
import 'package:uuid/uuid.dart';

class MockBox<T> extends Mock implements Box<T> {}

void main() {
  setUpAllRegistrations();

  late TodoRepository repository;
  late MockBox<TodoModel> mockBox;

  setUp(() {
    mockBox = MockBox<TodoModel>();
    repository = TodoRepository(mockBox);
    
    // Mock Hive box
    when(() => mockBox.values).thenReturn([]);
  });

  TodoModel createTodo(String title, {String? id, bool completed = false}) {
    return TodoModel(
      id: id ?? const Uuid().v4(),
      title: title,
      isCompleted: completed,
    );
  }


  test('getAllTodos returns list of todos', () {
    final todos = [
      createTodo('Test Todo 1', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec'),
      createTodo('Test Todo Updated', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec'),
    ];

    when(() => mockBox.values).thenReturn(todos);

    final result = repository.getAllTodos();

    expect(result.isRight(), true);
    result.fold(
      (l) => fail('Should be right'),
      (todos) {
        expect(todos.length, 2);
        expect(todos[0].title, 'Test Todo 1');
      },
    );
  });

  test('addTodo adds a new todo', () {
    final todo = createTodo('New Todo', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec');

    when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

    final result = repository.addTodo(todo);

    expect(result.isRight(), true);
    result.fold(
      (l) => fail('Should be right'),
      (addedTodo) {
        expect(addedTodo.title, 'New Todo');
      },
    );
  });

  test('updateTodo updates an existing todo', () {
    final originalTodo = createTodo('Orignal Todo', id: 'c1556755-22c6-4bd9-8e58-beaaadcd3aec');
    final updatedTodo = originalTodo.copyWith(isCompleted: true);

    when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

    final result = repository.updateTodo(updatedTodo);

    expect(result.isRight(), true);
    result.fold(
      (l) => fail('Should be right'),
      (todo) {
        expect(todo.isCompleted, true);
      },
    );
  });

  test('deleteTodo removes a todo', () {
    final todo = TodoModel(title: 'Todo to Delete');

    when(() => mockBox.delete(any())).thenAnswer((_) async => {});

    final result = repository.deleteTodo(todo.id);

    expect(result.isRight(), true);
    result.fold(
      (l) => fail('Should be right'),
      (deleted) {
        expect(deleted, true);
      },
    );
  });
}

void setUpAllRegistrations() {
  registerFallbackValue(TodoModel(title: 'Fallback Todo'));
}