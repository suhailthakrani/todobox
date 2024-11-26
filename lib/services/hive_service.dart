import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../data/models/todo_model.dart';

// class HiveService {
//   static Future<void> initialize() async {
//     await Hive.initFlutter();
//     Hive.registerAdapter(TodoModelAdapter());
//     await Hive.openBox<TodoModel>(AppConstants.todoBoxName);
//   }

//   static Box<TodoModel> get todoBox => 
//       Hive.box<TodoModel>(AppConstants.todoBoxName);
// }

class HiveService {
  static Box<TodoModel>? _todoBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoModelAdapter());
    _todoBox = await Hive.openBox<TodoModel>(AppConstants.todoBoxName);
  }

  static Box<TodoModel> get todoBox {
    if (_todoBox == null) {
      throw HiveError('Box not initialized. Did you call HiveService.initialize()?');
    }
    return _todoBox!;
  }
}
