import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/todo_model.dart';
import '../blocs/todo/todo_bloc.dart';
import '../blocs/todo/todo_event.dart';

class TodoList extends StatelessWidget {
  final List<TodoModel> todos;

  const TodoList({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.title),
          trailing: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) {
              context.read<TodoBloc>().add(
                UpdateTodo(todo.copyWith(isCompleted: !todo.isCompleted)),
              );
            },
          ),
          onLongPress: () {
            context.read<TodoBloc>().add(DeleteTodo(todo.id));
          },
        );
      },
    );
  }
}
