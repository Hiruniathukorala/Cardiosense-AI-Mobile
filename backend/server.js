import express from 'express';
import cors from 'cors';
import multer from 'multer';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const app = express();
const PORT = process.env.PORT || 5000;
const API_PREFIX = '/api';
const DATA_FILE = path.join(__dirname, 'data', 'db.json');
const UPLOAD_DIR = path.join(__dirname, 'uploads');

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

const loadData = async () => {
  try {
    const json = await fs.readFile(DATA_FILE, 'utf-8');
    return JSON.parse(json);
  } catch (error) {
    return { users: [], reports: [] };
  }
};

const saveData = async (data) => {
  await fs.mkdir(path.dirname(DATA_FILE), { recursive: true });
  await fs.writeFile(DATA_FILE, JSON.stringify(data, null, 2), 'utf-8');
};

const normalizeEmail = (email) => email?.trim().toLowerCase() || '';

app.use(cors({ origin: ['http://localhost:5173'], methods: ['GET', 'POST', 'PUT', 'DELETE'], credentials: true }));
app.use(express.json());
app.use('/uploads', express.static(UPLOAD_DIR));

app.get(`${API_PREFIX}/health`, (req, res) => {
  res.json({ status: 'ok' });
});

app.post(`${API_PREFIX}/auth/register`, async (req, res) => {
  const { name, email, password, role } = req.body;

  if (!name || !email || !password || !role) {
    return res.status(400).json({ success: false, message: 'All registration fields are required.' });
  }

  const data = await loadData();
  const existing = data.users.find(
    (user) => normalizeEmail(user.email) === normalizeEmail(email) && user.role === role,
  );

  if (existing) {
    return res.status(409).json({ success: false, message: 'An account with this email and role already exists.' });
  }

  const user = {
    id: `user-${Date.now()}`,
    name: name.trim(),
    email: normalizeEmail(email),
    password,
    role,
    createdAt: new Date().toISOString(),
  };

  data.users.push(user);
  await saveData(data);

  res.json({ success: true });
});

app.post(`${API_PREFIX}/auth/login`, async (req, res) => {
  const { email, password, role } = req.body;

  if (!email || !password || !role) {
    return res.status(400).json({ success: false, message: 'Email, password, and role are required.' });
  }

  const data = await loadData();
  const user = data.users.find(
    (saved) =>
      normalizeEmail(saved.email) === normalizeEmail(email) &&
      saved.password === password &&
      saved.role === role,
  );

  if (!user) {
    return res.status(401).json({ success: false, message: 'Invalid email, password, or role selection.' });
  }

  const { password: _, ...returnedUser } = user;
  res.json({ success: true, user: returnedUser });
});

app.get(`${API_PREFIX}/reports`, async (req, res) => {
  const { patientEmail, cardiologistEmail } = req.query;
  const data = await loadData();
  let reports = data.reports;

  if (patientEmail) {
    reports = reports.filter((report) => normalizeEmail(report.patientEmail) === normalizeEmail(patientEmail));
  }

  if (cardiologistEmail) {
    reports = reports.filter(
      (report) => normalizeEmail(report.cardiologistEmail) === normalizeEmail(cardiologistEmail),
    );
  }

  res.json(reports);
});

app.post(`${API_PREFIX}/reports`, async (req, res) => {
  const data = await loadData();
  const reportData = req.body;

  if (!reportData.patientName || !reportData.patientEmail || !reportData.cardiologistName || !reportData.cardiologistEmail) {
    return res.status(400).json({ success: false, message: 'Missing required report fields.' });
  }

  const report = {
    id: `ECG-${Date.now()}`,
    reportId: reportData.reportId || `ECG-${Date.now()}`,
    createdAt: new Date().toISOString(),
    patientName: reportData.patientName,
    patientEmail: normalizeEmail(reportData.patientEmail),
    patientAge: reportData.patientAge || null,
    patientGender: reportData.patientGender || null,
    symptoms: reportData.symptoms || '',
    notes: reportData.notes || '',
    cardiologistName: reportData.cardiologistName,
    cardiologistEmail: normalizeEmail(reportData.cardiologistEmail),
    status: reportData.status || 'Pending',
    confidence: reportData.confidence || 'Pending',
    conditions: reportData.conditions || [],
    fileUrl: reportData.fileUrl || null,
  };

  data.reports.push(report);
  await saveData(data);

  res.json(report);
});

app.post(`${API_PREFIX}/upload`, upload.single('ecgFile'), async (req, res) => {
  const data = await loadData();
  const {
    patientName,
    patientEmail,
    patientAge,
    patientGender,
    symptoms,
    notes,
    cardiologistName,
    cardiologistEmail,
  } = req.body;

  if (!req.file || !patientName || !patientEmail || !cardiologistName || !cardiologistEmail) {
    return res.status(400).json({ success: false, message: 'Missing required upload fields or file.' });
  }

  const report = {
    id: `ECG-${Date.now()}`,
    reportId: `ECG-${Date.now()}`,
    createdAt: new Date().toISOString(),
    patientName: patientName.trim(),
    patientEmail: normalizeEmail(patientEmail),
    patientAge: patientAge ? Number(patientAge) : null,
    patientGender: patientGender || null,
    symptoms: symptoms || '',
    notes: notes || '',
    cardiologistName: cardiologistName.trim(),
    cardiologistEmail: normalizeEmail(cardiologistEmail),
    status: 'Pending',
    confidence: 'Pending',
    conditions: [],
    fileUrl: `/uploads/${req.file.filename}`,
    doctorNotes: '',
    doctorAssessment: '',
  };

  data.reports.push(report);
  await saveData(data);

  res.json(report);
});

app.put(`${API_PREFIX}/reports/:id`, async (req, res) => {
  const data = await loadData();
  const { id } = req.params;
  const { status, doctorNotes, doctorAssessment, conditions, confidence } = req.body;

  const reportIndex = data.reports.findIndex((r) => r.id === id);
  if (reportIndex === -1) {
    return res.status(404).json({ success: false, message: 'Report not found.' });
  }

  const report = data.reports[reportIndex];
  if (status) report.status = status;
  if (doctorNotes !== undefined) report.doctorNotes = doctorNotes;
  if (doctorAssessment !== undefined) report.doctorAssessment = doctorAssessment;
  if (conditions) report.conditions = conditions;
  if (confidence) report.confidence = confidence;
  if (status !== 'Pending') report.finalizedAt = new Date().toISOString();

  data.reports[reportIndex] = report;
  await saveData(data);

  res.json(report);
});

app.listen(PORT, () => {
  console.log(`CardioSense backend listening on http://localhost:${PORT}`);
});
