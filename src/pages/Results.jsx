import { CheckCircle, AlertTriangle, Download, Send, HeartPulse, ArrowLeft } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useReports } from '../context/ReportsContext';
import './Results.css';

const Results = () => {
  const { user } = useAuth();
  const { getReportsByCardiologist, getReportsByPatient } = useReports();
  const navigate = useNavigate();

  // Filter reports based on user role
  const userReports = user
    ? user.role === 'Cardiologist'
      ? getReportsByCardiologist(user.email)
      : getReportsByPatient(user.email)
    : [];

  // Use first report or default diagnosis
  const selectedReport = userReports.length > 0 ? userReports[0] : null;
  const diagnosis = selectedReport || {
    status: 'Abnormal',
    confidence: '94.2%',
    conditions: [
      { name: 'Atrial Fibrillation', severity: 'High' },
      { name: 'Premature Ventricular Contractions', severity: 'Medium' }
    ],
    heartRate: '112 bpm',
    prInterval: '140 ms',
    qrsDuration: '95 ms',
    qtInterval: '420 ms',
    patientName: 'John Doe',
    reportId: 'ECG-2023-1042'
  };

  return (
    <div className="results-page">
      <div className="page-title">
        <div>
          <h1>AI Analysis Results</h1>
          <p className="text-muted" style={{marginTop: '4px', fontSize: '14px'}}>
            Report ID: {diagnosis.reportId || 'ECG-2023-1042'} • Patient: {diagnosis.patientName || 'John Doe'}
          </p>
        </div>
        <div style={{display: 'flex', gap: '12px'}}>
          <Link to="/report" className="btn btn-outline">
            <Download size={18} />
            Download Report
          </Link>
          {user?.role === 'Patient' ? (
            <button
              type="button"
              onClick={() => navigate(-1)}
              className="btn btn-outline"
            >
              <ArrowLeft size={18} />
              Back
            </button>
          ) : (
            <Link to="/review" className="btn btn-primary">
              <Send size={18} />
              Send to Doctor
            </Link>
          )}
        </div>
      </div>

      {userReports.length === 0 ? (
        <div className="card" style={{ padding: '48px', textAlign: 'center' }}>
          <h2 style={{ marginBottom: '16px' }}>No Reports Available</h2>
          <p style={{ color: '#6B7280', marginBottom: '24px' }}>
            {user?.role === 'Patient'
              ? 'Your ECG reports will appear here once they are created.'
              : 'No reports created yet. Upload an ECG to get started.'}
          </p>
          {user?.role === 'Cardiologist' && (
            <Link to="/upload" className="btn btn-primary">
              Upload New ECG
            </Link>
          )}
        </div>
      ) : (
        <div className="results-container">
          <div className="results-main">
            <div className="card waveform-card">
              <div className="card-header">
                <h2>ECG Waveform</h2>
                <div className="controls">
                  <span className="badge" style={{backgroundColor: '#E5E7EB', color: '#374151'}}>Lead II</span>
                  <span className="badge" style={{backgroundColor: '#E5E7EB', color: '#374151'}}>25 mm/s</span>
                </div>
              </div>
              
              <div className="waveform-display">
                {/* SVG Mockup for ECG Waveform */}
                <svg viewBox="0 0 800 200" className="ecg-line">
                  <path 
                    d="M0,100 L50,100 L60,80 L70,100 L90,100 L110,120 L130,20 L140,180 L160,100 L180,100 L200,80 L220,100 L250,100 L260,80 L270,100 L290,100 L310,120 L330,20 L340,180 L360,100 L380,100 L400,80 L420,100 L450,100 L460,80 L470,100 L490,100 L510,120 L530,20 L540,180 L560,100 L580,100 L600,80 L620,100 L650,100 L660,80 L670,100 L690,100 L710,120 L730,20 L740,180 L760,100 L780,100 L800,80" 
                    fill="none" 
                    stroke="#0A66C2" 
                    strokeWidth="2"
                    strokeLinejoin="round"
                  />
                </svg>
                <div className="grid-overlay"></div>
              </div>
              
              <div className="metrics-row">
                <div className="metric">
                  <span className="metric-label">Heart Rate</span>
                  <span className="metric-value">{diagnosis.heartRate}</span>
                </div>
                <div className="metric">
                  <span className="metric-label">PR Interval</span>
                  <span className="metric-value">{diagnosis.prInterval}</span>
                </div>
                <div className="metric">
                  <span className="metric-label">QRS Duration</span>
                  <span className="metric-value">{diagnosis.qrsDuration}</span>
                </div>
                <div className="metric">
                  <span className="metric-label">QT/QTc</span>
                  <span className="metric-value">{diagnosis.qtInterval}</span>
                </div>
              </div>
            </div>

            {userReports.length > 1 && (
              <div className="card" style={{ marginTop: '24px' }}>
                <h3 style={{ marginBottom: '16px' }}>Report History</h3>
                <div style={{ maxHeight: '200px', overflowY: 'auto' }}>
                  {userReports.map((report, idx) => (
                    <div
                      key={idx}
                      style={{
                        padding: '12px',
                        borderBottom: idx < userReports.length - 1 ? '1px solid #E5E7EB' : 'none',
                        cursor: 'pointer',
                        backgroundColor: selectedReport?.id === report.id ? '#EBF3FF' : 'transparent',
                      }}
                    >
                      <div style={{ fontSize: '14px', fontWeight: '500' }}>
                        {report.reportId || 'Report'}
                      </div>
                      <div style={{ fontSize: '12px', color: '#6B7280' }}>
                        {new Date(report.createdAt).toLocaleDateString()} • {report.status}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          <div className="results-sidebar">
            <div className="card summary-card">
              <h2>Diagnosis Summary</h2>
              
              <div className={`status-banner ${diagnosis.status?.toLowerCase() || 'normal'}`}>
                {diagnosis.status === 'Normal' ? (
                  <CheckCircle size={32} />
                ) : (
                  <AlertTriangle size={32} />
                )}
                <div className="status-text">
                  <h3>{diagnosis.status || 'Normal'}</h3>
                  <p>AI Confidence: {diagnosis.confidence || '95%'}</p>
                </div>
              </div>

              <div className="conditions-list">
                <h4 style={{marginBottom: '12px', fontSize: '14px', color: '#6B7280'}}>DETECTED CONDITIONS</h4>
                {diagnosis.conditions?.map((condition, idx) => (
                  <div className="condition-item" key={idx}>
                    <HeartPulse size={16} color="#EF4444" />
                    <span style={{flex: 1, fontSize: '14px', fontWeight: '500'}}>{condition.name}</span>
                    <span className={`badge badge-${condition.severity === 'High' ? 'danger' : 'warning'}`}>
                      {condition.severity} Risk
                    </span>
                  </div>
                )) || (
                  <p style={{ fontSize: '14px', color: '#6B7280' }}>No conditions detected</p>
                )}
              </div>
              
              <div style={{marginTop: '24px', paddingTop: '16px', borderTop: '1px solid #E5E7EB'}}>
                <h4 style={{marginBottom: '8px', fontSize: '14px', color: '#6B7280'}}>AI RECOMMENDATION</h4>
                <p style={{fontSize: '14px', lineHeight: '1.6'}}>
                  {diagnosis.recommendation || 'Patient exhibits signs of Atrial Fibrillation with rapid ventricular response. Immediate review by a cardiologist is recommended.'}
                </p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Results;
