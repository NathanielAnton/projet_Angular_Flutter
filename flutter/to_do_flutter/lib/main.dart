import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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

  factory Todo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    String status = '';
    switch (data['status']) {
      case 0:
        status = 'À faire';
        break;
      case 1:
        status = 'En cours';
        break;
      case 2:
        status = 'Terminé';
        break;
      default:
        status = 'Non défini';
    }

    return Todo(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: status,
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late Stream<List<Todo>> todosStream;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedStatus = 'À faire';

  @override
  void initState() {
    super.initState();

    todosStream = FirebaseFirestore.instance
        .collection('tasks')
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList());
  }

  void _openAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une tâche'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: const [
                  DropdownMenuItem(value: 'À faire', child: Text('À faire')),
                  DropdownMenuItem(value: 'En cours', child: Text('En cours')),
                  DropdownMenuItem(value: 'Terminé', child: Text('Terminé')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _addTask();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un titre.')),
      );
      return;
    }

    final newTask = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'status': _statusToCode(_selectedStatus),
      'created_at': DateTime.now().toIso8601String(),
    };

    await FirebaseFirestore.instance.collection('tasks').add(newTask);

    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedStatus = 'À faire';
    });
    Navigator.pop(context);
  }

  int _statusToCode(String status) {
    switch (status) {
      case 'En cours':
        return 1;
      case 'Terminé':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionnaire de Tâches'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Liste des Tâches',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Todo>>(
                stream: todosStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Aucune tâche pour le moment.'));
                  }

                  List<Todo> todos = snapshot.data!;

                  // Séparer les tâches par statut
                  List<Todo> todosToDo =
                      todos.where((todo) => todo.status == 'À faire').toList();
                  List<Todo> todosInProgress =
                      todos.where((todo) => todo.status == 'En cours').toList();
                  List<Todo> todosDone =
                      todos.where((todo) => todo.status == 'Terminé').toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaskColumn("À faire", Colors.blue, todosToDo),
                      _buildTaskColumn(
                          "En cours", Colors.orange, todosInProgress),
                      _buildTaskColumn("Terminé", Colors.green, todosDone),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskColumn(String title, Color color, List<Todo> tasks) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: tasks.isEmpty
                ? const Text(
                    "Aucune tâche",
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      Todo todo = tasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            todo.title,
                            style: TextStyle(color: color),
                          ),
                          subtitle: Text(todo.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.autorenew,
                                    color: Colors.blue),
                                onPressed: () => _changeStatus(todo),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(todo),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(Todo todo) async {
    int newStatus;

    if (todo.status == 'À faire') {
      newStatus = 1; // "En cours"
    } else if (todo.status == 'En cours') {
      newStatus = 2; // "Terminé"
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cette tâche est déjà terminée.')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('tasks')
        .where('title', isEqualTo: todo.title)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({'status': newStatus});
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statut mis à jour avec succès.')),
    );
  }

  Future<void> _deleteTask(Todo todo) async {
    await FirebaseFirestore.instance
        .collection('tasks')
        .where('title', isEqualTo: todo.title)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}
