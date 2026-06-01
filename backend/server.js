import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import multer from 'multer';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { connectDatabase, User, Report, Message } from './models.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const app = express();
const PORT = process.env.PORT || 5001;
const API_PREFIX = '/api';
const UPLOAD_DIR = path.join(__dirname, 'uploads');
const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/cardiosense-ai';
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

const normalizeEmail = (email) => email?.trim().toLowerCase() || '';

const createToken = (user) => {
  return jwt.sign({ id: user._id.toString(), email: user.email, role: user.role }, JWT_SECRET, {
    expiresIn: '7d',
  });
};

const getMedicalReferences = () => ({
  conditions: [
    {
      id: 'normal-sinus',
      name: 'Normal Sinus Rhythm',
      code: 'NSR',
      description: 'Normal heart rhythm with regular rate and rhythm',
      symptoms: [],
      riskLevel: 'Low',
      prevalence: '60-70% of normal populations',
    },
    {
      id: 'atrial-fibrillation',
      name: 'Atrial Fibrillation',
      code: 'AFib',
      description: 'Irregular and rapid heart rate, blood may pool in the atria and form clots',
      symptoms: ['Palpitations', 'Shortness of breath', 'Fatigue', 'Dizziness'],
      riskLevel: 'High',
      treatment: ['Rate control medications', 'Anticoagulation therapy', 'Cardioversion'],
      prevalence: '1-2% of the population',
    },
    {
      id: 'myocardial-infarction',
      name: 'Myocardial Infarction',
      code: 'MI',
      description: 'Heart attack caused by blockage of coronary artery',
      symptoms: ['Chest pain', 'Radiating pain', 'Shortness of breath', 'Nausea'],
      riskLevel: 'Critical',
      treatment: ['Emergency intervention', 'Thrombolysis', 'Angioplasty'],
      prevalence: '1 million cases annually in US',
    },
    {
      id: 'left-ventricular-hypertrophy',
      name: 'Left Ventricular Hypertrophy',
      code: 'LVH',
      description: 'Thickened left ventricle walls usually from high blood pressure',
      symptoms: ['None typically', 'Chest pain', 'Shortness of breath'],
      riskLevel: 'Moderate',
      treatment: ['Blood pressure control', 'ACE inhibitors', 'Beta-blockers'],
      prevalence: 'In 15-20% of hypertensive patients',
    },
    {
      id: 'bundle-branch-block',
      name: 'Bundle Branch Block',
      code: 'BBB',
      description: 'Delay in electrical conduction through the heart',
      symptoms: ['Usually asymptomatic', 'Syncope', 'Dizziness'],
      riskLevel: 'Moderate',
      treatment: ['Pacemaker', 'Monitoring', 'Treat underlying cause'],
      prevalence: '0.1-0.2% of population',
    },
    {
      id: 'st-elevation',
      name: 'ST Elevation',
      code: 'STE',
      description: 'Elevation of ST segment, indicator of acute coronary syndrome',
      symptoms: ['Acute chest pain', 'Sweating', 'Severe dyspnea'],
      riskLevel: 'Critical',
      treatment: ['Emergency reperfusion therapy', 'Coronary intervention'],
      prevalence: 'Medical emergency indicator',
    },
  ],
  measurements: [
    { name: 'Heart Rate', normal: '60-100 bpm', unit: 'bpm' },
    { name: 'PR Interval', normal: '120-200 ms', unit: 'ms' },
    { name: 'QRS Duration', normal: '80-120 ms', unit: 'ms' },
    { name: 'QT Interval', normal: '< 440 ms (males), < 460 ms (females)', unit: 'ms' },
    { name: 'ST Segment', normal: 'Isoelectric', unit: 'mV' },
  ],
});

const analyzeECG = async () => {
  const analysis = {
    heartRate: Math.floor(Math.random() * 40) + 60,
    rhythmType: ['Normal Sinus Rhythm', 'Atrial Fibrillation', 'Tachycardia', 'Bradycardia'][Math.floor(Math.random() * 4)],
    prInterval: (Math.random() * 80 + 120).toFixed(0),
    qrsInterval: (Math.random() * 40 + 80).toFixed(0),
    qtInterval: (Math.random() * 100 + 350).toFixed(0),
    stSegment: (Math.random() * 2 - 1).toFixed(2),
    conditions: [],
    confidence: (Math.random() * 30 + 70).toFixed(1),
    timestamp: new Date().toISOString(),
    normalizeFindings: 'Analysis complete',
  };

  if (analysis.heartRate > 100) analysis.conditions.push('Tachycardia');
  if (analysis.heartRate < 60) analysis.conditions.push('Bradycardia');
  if (Math.random() > 0.7) analysis.conditions.push('Abnormal ST Segment');

  return analysis;
};

const verifyToken = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ success: false, message: 'No token provided' });
  }
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (error) {
    res.status(401).json({ success: false, message: 'Invalid token' });
  }
};

app.use(
  cors({
    origin: ['http://localhost:5173', 'http://localhost:5174', 'http://localhost:5175', 'http://localhost:3000'],
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true,
  }),
);
app.use(express.json());
app.use('/uploads', express.static(UPLOAD_DIR));

app.get(`${API_PREFIX}/health`, (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.post(`${API_PREFIX}/auth/register`, async (req, res) => {
  try {
    const { name, email, password, role, specialization, licenseNumber } = req.body;

    if (!name || !email || !password || !role) {
      return res.status(400).json({ success: false, message: 'All registration fields are required.' });
    }

    if (password.length < 6) {
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters.' });
    }

    const normalizedEmail = normalizeEmail(email);
    const existing = await User.findOne({ email: normalizedEmail });
    if (existing) {
      return res.status(409).json({ success: false, message: 'An account with this email already exists.' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({
      name: name.trim(),
      email: normalizedEmail,
      passwordHash,
      role,
      specialization: role === 'Cardiologist' ? specialization || 'General Cardiology' : null,
      licenseNumber: role === 'Cardiologist' ? licenseNumber || null : null,
    });

    const token = createToken(user);

    res.json({
      success: true,
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        role: user.role,
      },
      token,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.post(`${API_PREFIX}/auth/login`, async (req, res) => {
  try {
    const { email, password, role } = req.body;
    if (!email || !password || !role) {
      return res.status(400).json({ success: false, message: 'Email, password, and role are required.' });
    }

    const normalizedEmail = normalizeEmail(email);
    const user = await User.findOne({ email: normalizedEmail, role, isActive: true });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      return res.status(401).json({ success: false, message: 'Invalid email, password, or role selection.' });
    }

    const token = createToken(user);
    res.json({
      success: true,
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        role: user.role,
      },
      token,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.get(`${API_PREFIX}/users/:id`, verifyToken, async (req, res) => {
  try {
    const user = await User.findById(req.params.id).lean();
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const { passwordHash, ...returnedUser } = user;
    res.json(returnedUser);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.get(`${API_PREFIX}/doctors`, async (req, res) => {
  try {
    const doctors = await User.find({ role: 'Cardiologist', isActive: true }).select('-passwordHash').lean();
    res.json(doctors);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.get(`${API_PREFIX}/medical-reference`, (req, res) => {
  res.json(getMedicalReferences());
});

app.get(`${API_PREFIX}/medical-reference/conditions`, (req, res) => {
  res.json(getMedicalReferences().conditions);
});

app.get(`${API_PREFIX}/medical-reference/conditions/:id`, (req, res) => {
  const condition = getMedicalReferences().conditions.find((c) => c.id === req.params.id);
  if (!condition) {
    return res.status(404).json({ success: false, message: 'Condition not found' });
  }
  res.json(condition);
});

app.get(`${API_PREFIX}/medical-reference/measurements`, (req, res) => {
  res.json(getMedicalReferences().measurements);
});

app.get(`${API_PREFIX}/reports`, verifyToken, async (req, res) => {
  try {
    const { patientEmail, doctorEmail, status, limit = 20, offset = 0 } = req.query;
    const query = {};
    if (patientEmail) query.patientEmail = normalizeEmail(patientEmail);
    if (doctorEmail) query.cardiologistEmail = normalizeEmail(doctorEmail);
    if (status) query.status = status;

    const total = await Report.countDocuments(query);
    const reports = await Report.find(query)
      .sort({ createdAt: -1 })
      .skip(Number(offset))
      .limit(Number(limit))
      .lean();

    res.json({ success: true, reports, total, limit: Number(limit), offset: Number(offset) });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.get(`${API_PREFIX}/reports/:id`, verifyToken, async (req, res) => {
  try {
    const report = await Report.findById(req.params.id).lean();
    if (!report) {
      return res.status(404).json({ success: false, message: 'Report not found' });
    }
    res.json(report);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.post(`${API_PREFIX}/reports`, verifyToken, async (req, res) => {
  try {
    const reportData = req.body;
    if (!reportData.patientName || !reportData.patientEmail || !reportData.cardiologistName || !reportData.cardiologistEmail) {
      return res.status(400).json({ success: false, message: 'Missing required report fields.' });
    }

    const report = await Report.create({
      reportId: reportData.reportId || `ECG-${Date.now()}`,
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
      doctorNotes: '',
      doctorAssessment: '',
      analysis: reportData.analysis || {},
    });

    res.json({ success: true, report });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.post(`${API_PREFIX}/upload`, verifyToken, upload.single('ecgFile'), async (req, res) => {
  try {
    const { patientName, patientEmail, patientAge, patientGender, symptoms, notes, cardiologistName, cardiologistEmail } = req.body;

    if (!req.file || !patientName || !patientEmail || !cardiologistName || !cardiologistEmail) {
      return res.status(400).json({ success: false, message: 'Missing required upload fields or file.' });
    }

    const report = await Report.create({
      reportId: `ECG-${Date.now()}`,
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
      fileName: req.file.originalname,
      fileSize: req.file.size,
      doctorNotes: '',
      doctorAssessment: '',
      analysis: await analyzeECG(),
    });

    res.json({ success: true, report });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.put(`${API_PREFIX}/reports/:id`, verifyToken, async (req, res) => {
  try {
    const { status, doctorNotes, doctorAssessment, conditions, confidence, analysis } = req.body;
    const report = await Report.findById(req.params.id);
    if (!report) {
      return res.status(404).json({ success: false, message: 'Report not found.' });
    }

    if (status) report.status = status;
    if (doctorNotes !== undefined) report.doctorNotes = doctorNotes;
    if (doctorAssessment !== undefined) report.doctorAssessment = doctorAssessment;
    if (conditions) report.conditions = conditions;
    if (confidence) report.confidence = confidence;
    if (analysis) report.analysis = { ...report.analysis, ...analysis };
    if (status && status !== 'Pending') report.finalizedAt = new Date();

    await report.save();
    res.json({ success: true, report });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.delete(`${API_PREFIX}/reports/:id`, verifyToken, async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);
    if (!report) {
      return res.status(404).json({ success: false, message: 'Report not found' });
    }

    if (report.fileUrl) {
      const filePath = path.join(__dirname, report.fileUrl);
      try {
        await fs.unlink(filePath);
      } catch (err) {
        console.warn('File deletion skipped:', err.message);
      }
    }

    await report.remove();
    res.json({ success: true, message: 'Report deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.get(`${API_PREFIX}/analysis`, verifyToken, async (req, res) => {
  try {
    const analyses = await Report.find({ 'analysis.heartRate': { $exists: true } })
      .sort({ createdAt: -1 })
      .select('reportId analysis createdAt')
      .lean();
    res.json({ success: true, analyses });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.post(`${API_PREFIX}/analyze-ecg/:reportId`, verifyToken, async (req, res) => {
  try {
    const report = await Report.findById(req.params.reportId);
    if (!report) {
      return res.status(404).json({ success: false, message: 'Report not found' });
    }

    const analysis = await analyzeECG();
    report.analysis = analysis;
    report.confidence = analysis.confidence;
    report.conditions = analysis.conditions;
    await report.save();

    res.json({ success: true, analysis });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.get(`${API_PREFIX}/messages`, verifyToken, async (req, res) => {
  try {
    const { conversationId, limit = 50, offset = 0 } = req.query;
    const query = {};
    if (conversationId) query.conversationId = conversationId;

    const total = await Message.countDocuments(query);
    const messages = await Message.find(query)
      .sort({ createdAt: 1 })
      .skip(Number(offset))
      .limit(Number(limit))
      .lean();

    res.json({ success: true, messages, total, limit: Number(limit), offset: Number(offset) });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.post(`${API_PREFIX}/messages`, verifyToken, async (req, res) => {
  try {
    const { conversationId, text, senderRole, senderName, senderEmail } = req.body;
    if (!conversationId || !text || !senderEmail) {
      return res.status(400).json({ success: false, message: 'Conversation ID, text, and sender email are required.' });
    }

    const message = await Message.create({
      conversationId,
      text,
      senderRole: senderRole || 'patient',
      senderName: senderName || 'User',
      senderEmail: normalizeEmail(senderEmail),
      isRead: false,
    });

    res.json({ success: true, message });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.post(`${API_PREFIX}/chat`, async (req, res) => {
  try {
    const { message } = req.body;
    if (!message) {
      return res.status(400).json({ success: false, message: 'Message is required' });
    }

    const lowerMessage = message.toLowerCase();
    let response = 'I\'m here to help with questions about cardiac health and ECG analysis. Please ask me about heart conditions, ECG readings, or general cardiac information.';

    if (lowerMessage.includes('heart rate') || lowerMessage.includes('bpm')) {
      response = 'Normal resting heart rate for adults is typically 60-100 beats per minute. Values outside this range may indicate a health concern that should be evaluated by a cardiologist.';
    } else if (lowerMessage.includes('ecg') || lowerMessage.includes('ekg')) {
      response = 'An ECG (Electrocardiogram) is a test that measures the electrical activity of the heart. It can help detect various heart conditions including irregular heartbeats, heart attacks, and other abnormalities.';
    } else if (lowerMessage.includes('symptoms') || lowerMessage.includes('chest pain')) {
      response = 'If you experience chest pain, shortness of breath, dizziness, or other concerning symptoms, please seek immediate medical attention by calling emergency services or visiting the nearest emergency room.';
    } else if (lowerMessage.includes('analysis') || lowerMessage.includes('result')) {
      response = 'Your ECG analysis includes heart rate, rhythm type, and measurements of various intervals. A qualified cardiologist reviews these results to identify any abnormalities or conditions.';
    } else if (lowerMessage.includes('atrial fibrillation') || lowerMessage.includes('afib')) {
      response = 'Atrial fibrillation is an irregular heartbeat that can increase the risk of stroke and heart failure. Treatment options include medications and procedures like cardioversion.';
    } else if (lowerMessage.includes('hello') || lowerMessage.includes('hi')) {
      response = 'Hello! I\'m the CardioSense AI assistant. I can help answer questions about heart health, ECG readings, and cardiac conditions. What would you like to know?';
    }

    res.json({ success: true, message: { id: `msg-${Date.now()}`, text: response, sender: 'chatbot', timestamp: new Date().toISOString() } });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.get(`${API_PREFIX}/conversations`, verifyToken, async (req, res) => {
  try {
    const conversations = await Message.aggregate([
      { $sort: { createdAt: 1 } },
      {
        $group: {
          _id: '$conversationId',
          lastMessage: { $last: '$text' },
          lastMessageTime: { $last: '$createdAt' },
          messageCount: { $sum: 1 },
          participants: { $addToSet: '$senderEmail' },
        },
      },
      { $project: { id: '$_id', _id: 0, lastMessage: 1, lastMessageTime: 1, messageCount: 1, participants: 1 } },
      { $sort: { lastMessageTime: -1 } },
    ]);

    res.json({ success: true, conversations });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

app.all('*', (req, res) => {
  res.status(404).json({ success: false, message: 'Endpoint not found' });
});

await connectDatabase(MONGO_URI);
console.log('Connected to MongoDB', MONGO_URI);

app.listen(PORT, () => {
  console.log(`✓ CardioSense backend listening on http://localhost:${PORT}`);
  console.log(`✓ API prefix: ${API_PREFIX}`);
  console.log(`✓ Upload directory: ${UPLOAD_DIR}`);
});
