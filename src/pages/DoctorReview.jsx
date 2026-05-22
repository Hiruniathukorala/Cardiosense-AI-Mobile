import { useState, useEffect } from 'react';
import { Search, Filter, Check, X, User, AlertCircle } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useReports } from '../context/ReportsContext';
import './DoctorReview.css';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:5001';

const DoctorReview = () => {
  const [selectedPatient, setSelectedPatient] = useState(0);
  const [doctorNotes, setDoctorNotes] = useState('');
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [patients, setPatients] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const { user } = useAuth();
  const { reports } = useReports();

  useEffect(() => {
    if (user && reports.length > 0) {
      const filteredReports = reports.filter(
        (report) => report.cardiologistEmail === user.email && report.status === 'Pending',
      );
      setPatients(filteredReports);
      setIsLoading(false);
      if (filteredReports.length > 0) {
        setDoctorNotes(filteredReports[0].doctorNotes || '');
      }
    }
  }, [user, reports]);

  const handleSaveDraft = async () => {
    if (!patients[selectedPatient]) return;
    setError('');
    setSuccess('');
    setIsSaving(true);

    try {
      const response = await fetch(`${API_BASE}/api/reports/${patients[selectedPatient].id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ doctorNotes, status: 'Pending' }),
      });

      if (!response.ok) {
        throw new Error('Failed to save draft.');
      }

      setSuccess('Draft saved successfully.');
    } catch (err) {
      setError(err.message || 'Failed to save draft.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleApprove = async () => {
    if (!patients[selectedPatient]) return;
    setError('');
    setSuccess('');
    setIsSaving(true);

    try {
      const response = await fetch(`${API_BASE}/api/reports/${patients[selectedPatient].id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ doctorNotes, doctorAssessment: doctorNotes, status: 'Approved' }),
      });

      if (!response.ok) {
        throw new Error('Failed to approve report.');
      }

      setSuccess('Report approved and finalized.');
      setPatients((prev) => prev.filter((_, idx) => idx !== selectedPatient));
    } catch (err) {
      setError(err.message || 'Failed to approve report.');
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading) {
    return (
      <div className="review-page">
        <div className="page-title">
          <h1>Doctor Review Dashboard</h1>
        </div>
        <div className="card" style={{ padding: '48px', textAlign: 'center' }}>
          <p>Loading pending reports...</p>
        </div>
      </div>
    );
  }

  if (patients.length === 0) {
    return (
      <div className="review-page">
        <div className="page-title">
          <h1>Doctor Review Dashboard</h1>
        </div>
        <div className="card" style={{ padding: '48px', textAlign: 'center' }}>
          <p>No pending reports for review.</p>
        </div>
      </div>
    );
  }

  const currentPatient = patients[selectedPatient];

  return (
    <div className="review-page">
      <div className="page-title">
        <h1>Doctor Review Dashboard</h1>
      </div>

      <div className="review-container">
        <div className="card patient-list-card">
          <div className="list-header">
            <div className="search-filter">
              <div className="search-box">
                <Search size={16} />
                <input type="text" placeholder="Search patients..." />
              </div>
              <button className="icon-btn" style={{border: '1px solid #E5E7EB', padding: '8px', borderRadius: '8px'}}>
                <Filter size={16} />
              </button>
            </div>
          </div>
          
          <div className="patients-list">
            {patients.map((patient, idx) => (
              <div 
                className={`patient-list-item ${selectedPatient === idx ? 'selected' : ''}`}
                key={patient.id}
                onClick={() => {
                  setSelectedPatient(idx);
                  setDoctorNotes(patient.doctorNotes || '');
                }}
              >
                <div className="patient-avatar">
                  <User size={20} color="#0A66C2" />
                </div>
                <div className="patient-info-list">
                  <h4>{patient.patientName}</h4>
                  <p>{patient.reportId} • {new Date(patient.createdAt).toLocaleDateString()}</p>
                </div>
                {patient.status === 'Abnormal' && (
                  <span className="dot-indicator danger"></span>
                )}
                {patient.status === 'Pending' && (
                  <span className="dot-indicator warning"></span>
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="review-main-panel">
          <div className="card review-details-card">
            <div className="detail-header">
              <div className="patient-summary">
                <h2>{patients[selectedPatient].name}</h2>
                <p className="text-muted">{patients[selectedPatient].age} yrs • {patients[selectedPatient].gender} • ID: {patients[selectedPatient].id}</p>
              </div>
              <div className="ai-summary-badge">
                <span className="badge badge-danger">AI Diagnosis: Abnormal (94.2%)</span>
              </div>
            </div>

            <div className="mini-waveform">
              {/* SVG Mockup */}
              <svg viewBox="0 0 800 150" className="ecg-line">
                <path 
                  d="M0,75 L50,75 L60,55 L70,75 L90,75 L110,95 L130,15 L140,135 L160,75 L180,75 L200,55 L220,75 L250,75 L260,55 L270,75 L290,75 L310,95 L330,15 L340,135 L360,75" 
                  fill="none" 
                  stroke="#0A66C2" 
                  strokeWidth="2"
                  strokeLinejoin="round"
                />
              </svg>
              <div className="grid-overlay"></div>
            </div>

            <div className="doctor-notes-section">
              <h3>Doctor's Assessment</h3>
              <textarea 
                className="input-field" 
                placeholder="Enter clinical notes, final diagnosis, and recommendations here..."
                style={{minHeight: '150px', marginTop: '12px'}}
              ></textarea>
            </div>

            <div className="review-actions">
              <button className="btn btn-outline" style={{borderColor: '#EF4444', color: '#EF4444'}}>
                <X size={18} />
                Reject AI Finding
              </button>
              <div style={{flex: 1}}></div>
              <button className="btn btn-outline">Save Draft</button>
              <button className="btn btn-success">
                <Check size={18} />
                Approve & Finalize
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DoctorReview;
