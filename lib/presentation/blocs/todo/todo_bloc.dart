

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/todo_model.dart';
import '../../../data/repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;

  TodoBloc({required this.repository}) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
  }

  void _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) {
    emit(TodoLoading());
    final result = repository.getAllTodos();
    result.fold(
      (failure) => emit(TodoError(failure)),
      (todos) => emit(TodoLoaded(todos)),
    );
  }

  void _onAddTodo(AddTodo event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final result = repository.addTodo(event.todo);
      result.fold(
        (failure) => emit(TodoError(failure)),
        (todo) {
          final updatedTodos = List<TodoModel>.from((state as TodoLoaded).todos)..add(todo);
          emit(TodoLoaded(updatedTodos));
        },
      );
    }
  }

  void _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final result = repository.updateTodo(event.todo);
      result.fold(
        (failure) => emit(TodoError(failure)),
        (todo) {
          final updatedTodos = (state as TodoLoaded).todos.map((t) => 
            t.id == todo.id ? todo : t
          ).toList();
          emit(TodoLoaded(updatedTodos));
        },
      );
    }
  }

  void _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final result = repository.deleteTodo(event.id);
      result.fold(
        (failure) => emit(TodoError(failure)),
        (_) {
          final updatedTodos = (state as TodoLoaded).todos
            .where((todo) => todo.id != event.id)
            .toList();
          emit(TodoLoaded(updatedTodos));
        },
      );
    }
  }
}
