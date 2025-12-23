import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Local Storage UTB',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NoteListScreen(),
    );
  }
}

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<String> _notes = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(); // READ: Memuat data saat aplikasi dibuka
  }

  // --- LOGIKA CRUD ---

  // READ
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = prefs.getStringList('my_notes') ?? [];
    });
  }

  // CREATE & UPDATE
  Future<void> _saveData(String note, {int? index}) async {
    final prefs = await SharedPreferences.getInstance();
    if (index == null) {
      _notes.add(note); // Tambah baru
    } else {
      _notes[index] = note; // Update yang sudah ada
    }
    await prefs.setStringList('my_notes', _notes);
    _controller.clear();
    _loadData();
  }

  // DELETE
  Future<void> _deleteData(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _notes.removeAt(index);
    await prefs.setStringList('my_notes', _notes);
    _loadData();
  }

  // --- UI DIALOG ---

  void _showForm({int? index}) {
    if (index != null) _controller.text = _notes[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Tambah Catatan' : 'Edit Catatan'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Tulis sesuatu...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _saveData(_controller.text, index: index);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Local Storage')),
      body: _notes.isEmpty
          ? const Center(child: Text('Belum ada data.'))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(_notes[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showForm(index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteData(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
