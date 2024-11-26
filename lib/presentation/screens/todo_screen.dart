import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/todo/todo_bloc.dart';
import '../blocs/todo/todo_event.dart';
import '../blocs/todo/todo_state.dart';
import '../widgets/todo_list.dart';
import '../widgets/add_todo_dialog.dart';
import '../../data/models/todo_model.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is TodoLoaded) {
            return TodoList(todos: state.todos);
          }
          return const Center(child: Text('Initialize todos'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTodoDialog(
              onAdd: (title) {
                final todo = TodoModel(title: title);
                context.read<TodoBloc>().add(AddTodo(todo));
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}