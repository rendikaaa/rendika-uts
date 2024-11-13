import 'package:flutter/material.dart';

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
      ),
      home: NotesPage(), // Pastikan ini ada dan didefinisikan
    );
  }
}

// Pastikan Anda juga memiliki kelas NotesPage yang didefinisikan
class NotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Saya'),
      ),
      body: Center(
        child: Text('Daftar Catatan'),
      ),
    );
  }
}