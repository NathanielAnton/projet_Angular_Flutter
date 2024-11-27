import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Todo {
  String title;
  String description;
  String status;
  DateTime createdAt;

  Todo({
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todosToDo = [];
  List<Todo> todosInProgress = [];
  List<Todo> todosDone = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedStatus = 'À faire';

  void openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ajouter une nouvelle tâche',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              DropdownButton<String>(
                value: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                items: ['À faire', 'En cours', 'Terminé']
                    .map((status) =>
                        DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                isExpanded: true,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    Todo newTodo = Todo(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      status: _selectedStatus,
                      createdAt: DateTime.now(),
                    );
                    if (_selectedStatus == 'À faire') {
                      todosToDo.add(newTodo);
                    } else if (_selectedStatus == 'En cours') {
                      todosInProgress.add(newTodo);
                    } else {
                      todosDone.add(newTodo);
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text('Créer'),
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteTodo(Todo todo) {
    setState(() {
      if (todo.status == 'À faire') {
        todosToDo.remove(todo);
      } else if (todo.status == 'En cours') {
        todosInProgress.remove(todo);
      } else {
        todosDone.remove(todo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionnaire de Tâches'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => openModal(context),
              child: Text('+ Ajouter une tâche'),
            ),
            SizedBox(height: 20),
            Text('Liste des Tâches',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Expanded(
              child: Row(
                children: [
                  // Section "À faire"
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('À faire',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ...todosToDo.isEmpty
                            ? [
                                Text('Aucune tâche pour le moment.',
                                    style: TextStyle(color: Colors.grey))
                              ]
                            : todosToDo.map((todo) {
                                return Card(
                                  margin: EdgeInsets.only(bottom: 10),
                                  elevation: 4,
                                  child: ListTile(
                                    title: Text(todo.title,
                                        style: TextStyle(color: Colors.blue)),
                                    subtitle: Text(todo.description),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.refresh),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () => deleteTodo(todo),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                      ],
                    ),
                  ),
                  // Section "En cours"
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('En cours',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ...todosInProgress.isEmpty
                            ? [
                                Text('Aucune tâche pour le moment.',
                                    style: TextStyle(color: Colors.grey))
                              ]
                            : todosInProgress.map((todo) {
                                return Card(
                                  margin: EdgeInsets.only(bottom: 10),
                                  elevation: 4,
                                  child: ListTile(
                                    title: Text(todo.title,
                                        style: TextStyle(color: Colors.orange)),
                                    subtitle: Text(todo.description),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.refresh),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () => deleteTodo(todo),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                      ],
                    ),
                  ),
                  // Section "Terminé"
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Terminé',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ...todosDone.isEmpty
                            ? [
                                Text('Aucune tâche pour le moment.',
                                    style: TextStyle(color: Colors.grey))
                              ]
                            : todosDone.map((todo) {
                                return Card(
                                  margin: EdgeInsets.only(bottom: 10),
                                  elevation: 4,
                                  child: ListTile(
                                    title: Text(todo.title,
                                        style: TextStyle(color: Colors.green)),
                                    subtitle: Text(todo.description),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => deleteTodo(todo),
                                    ),
                                  ),
                                );
                              }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
