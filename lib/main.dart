import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Saya',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NotesPage(),
    );
  }
}


class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadNotes();
  }

  // Memuat catatan dari database
  void _loadNotes() async {
    final loadedNotes = await DatabaseHelper.instance.getNotes();
    setState(() {
      notes = loadedNotes; // Update UI dengan catatan dari database
    });
  }

  // Menambahkan catatan baru ke dalam database
  void _addNote() async {
    final note = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
    };

    if (note['title']!.isNotEmpty && note['content']!.isNotEmpty) {
      await DatabaseHelper.instance.insertNote(note);
      _titleController.clear();
      _contentController.clear();
      _loadNotes();
    } else {
      // Menampilkan pesan kesalahan jika data kosong
      print('Title or content cannot be empty');
    }
  }

  // Mengedit catatan yang ada
  void _editNote(Map<String, dynamic> note) {
    _titleController.text = note['title'];
    _contentController.text = note['content'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: 'Judul'),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(hintText: 'Konten'),
                maxLines: null, // Membolehkan input multiline
                keyboardType: TextInputType.multiline, // Menggunakan keyboard multiline
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.updateNote({
                  'id': note['id'],
                  'title': _titleController.text,
                  'content': _contentController.text,
                });
                Navigator.pop(context);
                _loadNotes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text('Simpan Perubahan'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Menghapus catatan
  void _deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Saya'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Konten',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: null, // Membolehkan input multiline
                  keyboardType: TextInputType.multiline, // Menggunakan keyboard multiline
                ),
                SizedBox(height : 16.0),
                ElevatedButton(
                  onPressed: _addNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  ),
                  child: Text('Tambah Catatan'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(note['title']),
                    subtitle: Text(note['content']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteNote(note['id']),
                    ),
                    onTap: () => _editNote(note),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}