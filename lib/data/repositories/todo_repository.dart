import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';
import '../../services/hive_service.dart';

class TodoRepository {
  final Box<TodoModel> _box;

  TodoRepository([Box<TodoModel>? box]) : _box = box ?? HiveService.todoBox;

  Either<String, List<TodoModel>> getAllTodos() {
    try {
      final todos = _box.values.toList();
      return Right(todos);
    } catch (e) {
      return Left('Failed to fetch todos: ${e.toString()}');
    }
  }

  Either<String, TodoModel> addTodo(TodoModel todo) {
    try {
      _box.put(todo.id, todo);
      return Right(todo);
    } catch (e) {
      return Left('Failed to add todo: ${e.toString()}');
    }
  }

  Either<String, TodoModel> updateTodo(TodoModel todo) {
    try {
      _box.put(todo.id, todo);
      return Right(todo);
    } catch (e) {
      return Left('Failed to update todo: ${e.toString()}');
    }
  }

  Either<String, bool> deleteTodo(String id) {
    try {
      _box.delete(id);
      return const Right(true);
    } catch (e) {
      return Left('Failed to delete todo: ${e.toString()}');
    }
  }
}
