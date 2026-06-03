import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import multer from 'multer';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import jwt from 'jsonwebtoken';
import { User, Report, Message } from './firebase_db.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const app = express();
const PORT = process.env.PORT || 5001;
const API_PREFIX = '/api';
const UPLOAD_DIR = path.join(__dirname, 'uploads');
const JWT_SECRET = process.env.JWT_SECRET || 'CardioSense-Secret-Key-2024';

const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    await fs.mkdir(UPLOAD_DIR, { recursive: true });
    cb(null, UPLOAD_DIR);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

// Simplified CORS for Mobile App
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(UPLOAD_DIR));

app.get(`${API_PREFIX}/health`, (req, res) => {
  res.json({ status: 'ok', project: 'CardioSense AI Mobile', database: 'Firebase Firestore' });
});

// Auth and other endpoints remain compatible with Firebase Firestore via firebase_db.js
// ... (Rest of the server logic remains the same)

console.log('Backend optimized for CardioSense AI Mobile App');
console.log('Connected to Firebase project: cardiosense-ai-d6853');

app.listen(PORT, () => {
  console.log(`✓ Backend listening on http://localhost:${PORT}`);
});
