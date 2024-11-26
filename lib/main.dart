import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todobox/presentation/blocs/todo/todo_event.dart';
import 'presentation/blocs/todo/todo_bloc.dart';
import 'services/hive_service.dart';
import 'data/repositories/todo_repository.dart';
import 'presentation/screens/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();
  
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TodoRepository(),
      child: BlocProvider(
        create: (context) => TodoBloc(
          repository: context.read<TodoRepository>(),
        )..add(LoadTodos()),
        child: MaterialApp(
          title: 'Todo App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const TodoScreen(),
        ),
      ),
    );
  }
}