import mongoose from 'mongoose';

const { Schema, model } = mongoose;

const UserSchema = new Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, trim: true, lowercase: true, unique: true },
    passwordHash: { type: String, required: true },
    role: { type: String, required: true, enum: ['Patient', 'Cardiologist'] },
    specialization: { type: String, default: null },
    licenseNumber: { type: String, default: null },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

const ReportSchema = new Schema(
  {
    reportId: { type: String, required: true, unique: true },
    patientName: { type: String, required: true, trim: true },
    patientEmail: { type: String, required: true, trim: true, lowercase: true },
    patientAge: { type: Number, default: null },
    patientGender: { type: String, default: null },
    symptoms: { type: String, default: '' },
    notes: { type: String, default: '' },
    cardiologistName: { type: String, required: true, trim: true },
    cardiologistEmail: { type: String, required: true, trim: true, lowercase: true },
    status: { type: String, default: 'Pending' },
    confidence: { type: String, default: 'Pending' },
    conditions: { type: [String], default: [] },
    fileUrl: { type: String, default: null },
    fileName: { type: String, default: null },
    fileSize: { type: Number, default: null },
    doctorNotes: { type: String, default: '' },
    doctorAssessment: { type: String, default: '' },
    analysis: { type: Schema.Types.Mixed, default: {} },
    finalizedAt: { type: Date, default: null },
  },
  { timestamps: true }
);

const MessageSchema = new Schema(
  {
    conversationId: { type: String, required: true },
    text: { type: String, required: true },
    senderRole: { type: String, default: 'patient' },
    senderName: { type: String, default: 'User' },
    senderEmail: { type: String, required: true, trim: true, lowercase: true },
    isRead: { type: Boolean, default: false },
  },
  { timestamps: true }
);

export const connectDatabase = async (uri) => {
  mongoose.set('strictQuery', false);
  return mongoose.connect(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
};

export const User = model('User', UserSchema);
export const Report = model('Report', ReportSchema);
export const Message = model('Message', MessageSchema);
