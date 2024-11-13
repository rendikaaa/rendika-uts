const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;  // Port yang digunakan oleh server Express

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Setup koneksi ke MySQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',  // Ganti dengan user MySQL Anda
  password: '',  // Ganti dengan password MySQL Anda jika ada
  database: 'notes_db'  // Ganti dengan nama database Anda
});

// Cek koneksi ke database
db.connect(err => {
  if (err) {
    console.error('Error connecting to the database:', err.stack);
    return;
  }
  console.log('Connected to MySQL database.');
});

// API Endpoints

// Menambahkan catatan baru
app.post('/notes', (req, res) => {
  const { title, content } = req.body;
  const createdAt = new Date().toISOString();
  const updatedAt = new Date().toISOString();

  const query = 'INSERT INTO notes (title, content, created_at, updated_at) VALUES (?, ?, ?, ?)';
  db.query(query, [title, content, createdAt, updatedAt], (err, result) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.status(201).json({ id: result.insertId, title, content, createdAt, updatedAt });
  });
});

// Mendapatkan semua catatan
app.get('/notes', (req, res) => {
  const query = 'SELECT * FROM notes';
  db.query(query, (err, results) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.status(200).json(results);
  });
});

// Mengupdate catatan
app.put('/notes/:id', (req, res) => {
  const { title, content } = req.body;
  const updatedAt = new Date().toISOString();
  const { id } = req.params;

  const query = 'UPDATE notes SET title = ?, content = ?, updated_at = ? WHERE id = ?';
  db.query(query, [title, content, updatedAt, id], (err, result) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (result.affectedRows === 0) {
      res.status(404).json({ message: 'Note not found' });
      return;
    }
    res.status(200).json({ id, title, content, updatedAt });
  });
});

// Menghapus catatan
app.delete('/notes/:id', (req, res) => {
  const { id } = req.params;

  const query = 'DELETE FROM notes WHERE id = ?';
  db.query(query, [id], (err, result) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (result.affectedRows === 0) {
      res.status(404).json({ message: 'Note not found' });
      return;
    }
    res.status(200).json({ message: 'Note deleted' });
  });
});

// Jalankan server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
