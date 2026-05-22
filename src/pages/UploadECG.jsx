import { useState } from 'react';
import { UploadCloud, File, X, Activity } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useReports } from '../context/ReportsContext';
import './UploadECG.css';

const UploadECG = () => {
  const [file, setFile] = useState(null);
  const [patientName, setPatientName] = useState('');
  const [patientEmail, setPatientEmail] = useState('');
  const [age, setAge] = useState('');
  const [gender, setGender] = useState('');
  const [symptoms, setSymptoms] = useState('');
  const [notes, setNotes] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const { user } = useAuth();
  const { uploadReport } = useReports();

  const handleDrop = (e) => {
    e.preventDefault();
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      setFile(e.dataTransfer.files[0]);
    }
  };

  const handleChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0]);
    }
  };

  const handleUpload = async (e) => {
    e.preventDefault();
    if (!file || !user) return;
    setError('');
    setIsUploading(true);

    try {
      const formData = new FormData();
      formData.append('ecgFile', file);
      formData.append('patientName', patientName);
      formData.append('patientEmail', patientEmail);
      formData.append('patientAge', age);
      formData.append('patientGender', gender);
      formData.append('symptoms', symptoms);
      formData.append('notes', notes);
      formData.append('cardiologistName', user.name);
      formData.append('cardiologistEmail', user.email);

      await uploadReport(formData);
      navigate('/results');
    } catch (uploadError) {
      setError(uploadError.message || 'Upload failed. Please try again.');
    } finally {
      setIsUploading(false);
    }
  };

  return (
    <div className="upload-page">
      <div className="page-title">
        <h1>Upload ECG for Analysis</h1>
      </div>

      <div className="upload-container">
        <div className="card upload-section">
          <h2>ECG Document</h2>
          <p className="text-muted" style={{marginBottom: '20px', fontSize: '14px'}}>
            Upload the patient's ECG report in PDF format.
          </p>
          
          {!file ? (
            <div 
              className="dropzone" 
              onDragOver={(e) => e.preventDefault()} 
              onDrop={handleDrop}
            >
              <div className="dropzone-icon">
                <UploadCloud size={40} color="#0A66C2" />
              </div>
              <h3>Drag & drop your PDF here</h3>
              <p className="text-muted">or click to browse from your computer</p>
              <input 
                type="file" 
                id="file-upload" 
                accept=".pdf" 
                onChange={handleChange} 
                style={{display: 'none'}} 
              />
              <label htmlFor="file-upload" className="btn btn-outline" style={{marginTop: '16px'}}>
                Browse Files
              </label>
            </div>
          ) : (
            <div className="file-preview">
              <div className="file-info">
                <File size={24} color="#0A66C2" />
                <div>
                  <p className="file-name">{file.name}</p>
                  <p className="file-size">{(file.size / 1024 / 1024).toFixed(2)} MB</p>
                </div>
              </div>
              <button className="icon-btn" onClick={() => setFile(null)}>
                <X size={20} />
              </button>
            </div>
          )}
        </div>

        <div className="card form-section">
          <h2>Patient Information</h2>
          <form onSubmit={handleUpload}>
            <div className="input-group">
              <label className="input-label">Full Name</label>
              <input
                type="text"
                className="input-field"
                placeholder="e.g. John Doe"
                value={patientName}
                onChange={(event) => setPatientName(event.target.value)}
                required
              />
            </div>

            <div className="input-group">
              <label className="input-label">Email</label>
              <input
                type="email"
                className="input-field"
                placeholder="e.g. patient@example.com"
                value={patientEmail}
                onChange={(event) => setPatientEmail(event.target.value)}
                required
              />
            </div>

            <div className="form-row">
              <div className="input-group">
                <label className="input-label">Age</label>
                <input
                  type="number"
                  className="input-field"
                  placeholder="e.g. 45"
                  value={age}
                  onChange={(event) => setAge(event.target.value)}
                  required
                />
              </div>
              <div className="input-group">
                <label className="input-label">Gender</label>
                <select
                  className="input-field"
                  value={gender}
                  onChange={(event) => setGender(event.target.value)}
                  required
                >
                  <option value="">Select gender...</option>
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="other">Other</option>
                </select>
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Symptoms</label>
              <input
                type="text"
                className="input-field"
                placeholder="e.g. Chest pain, shortness of breath"
                value={symptoms}
                onChange={(event) => setSymptoms(event.target.value)}
              />
            </div>

            <div className="input-group">
              <label className="input-label">Additional Notes</label>
              <textarea
                className="input-field"
                placeholder="Any relevant medical history..."
                value={notes}
                onChange={(event) => setNotes(event.target.value)}
              />
            </div>

            {error && <div className="auth-error" style={{ marginBottom: '16px' }}>{error}</div>}

            <button
              type="submit"
              className="btn btn-primary btn-block"
              disabled={!file || isUploading}
              style={{ width: '100%', marginTop: '16px', padding: '12px' }}
            >
              {isUploading ? (
                <>
                  <Activity className="spinner" size={18} />
                  Analyzing with AI...
                </>
              ) : (
                'Upload and Analyze'
              )}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default UploadECG;
