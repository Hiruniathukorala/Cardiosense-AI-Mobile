import { Printer, Download, ArrowLeft } from 'lucide-react';
import { Link } from 'react-router-dom';
import './Report.css';

const Report = () => {
  return (
    <div className="report-page">
      <div className="page-title no-print">
        <div style={{display: 'flex', alignItems: 'center', gap: '16px'}}>
          <Link to="/results" className="icon-btn">
            <ArrowLeft size={20} />
          </Link>
          <h1>Final Medical Report</h1>
        </div>
        <div style={{display: 'flex', gap: '12px'}}>
          <button className="btn btn-outline" onClick={() => window.print()}>
            <Printer size={18} />
            Print
          </button>
          <button className="btn btn-primary">
            <Download size={18} />
            Download PDF
          </button>
        </div>
      </div>

      <div className="report-document printable-area">
        <div className="report-header">
          <div className="hospital-info">
            <h2 style={{color: '#0A66C2', marginBottom: '4px'}}>CardioSense General Hospital</h2>
            <p className="text-muted" style={{fontSize: '12px'}}>123 Medical Parkway, Healthville, MC 90210</p>
            <p className="text-muted" style={{fontSize: '12px'}}>Tel: (555) 123-4567 • Web: www.cardiosense.org</p>
          </div>
          <div className="report-meta">
            <p><strong>Report ID:</strong> ECG-2023-1042</p>
            <p><strong>Date:</strong> Oct 24, 2023</p>
            <p><strong>Time:</strong> 14:30 EST</p>
          </div>
        </div>

        <div className="divider"></div>

        <div className="patient-section">
          <h3 className="section-title">PATIENT INFORMATION</h3>
          <div className="info-grid">
            <div className="info-item">
              <span className="label">Name:</span>
              <span className="value">John Doe</span>
            </div>
            <div className="info-item">
              <span className="label">Patient ID:</span>
              <span className="value">PT-89432</span>
            </div>
            <div className="info-item">
              <span className="label">Age/Gender:</span>
              <span className="value">45 / Male</span>
            </div>
            <div className="info-item">
              <span className="label">DOB:</span>
              <span className="value">12/05/1978</span>
            </div>
            <div className="info-item" style={{gridColumn: 'span 2'}}>
              <span className="label">Symptoms:</span>
              <span className="value">Palpitations, shortness of breath, mild chest discomfort</span>
            </div>
          </div>
        </div>

        <div className="divider"></div>

        <div className="ecg-section">
          <h3 className="section-title">ECG TRACING (Lead II)</h3>
          <div className="report-waveform">
            {/* SVG Mockup */}
            <svg viewBox="0 0 800 120" className="ecg-line">
              <path 
                d="M0,60 L50,60 L60,40 L70,60 L90,60 L110,80 L130,10 L140,110 L160,60 L180,60 L200,40 L220,60 L250,60 L260,40 L270,60 L290,60 L310,80 L330,10 L340,110 L360,60 L380,60 L400,40 L420,60 L450,60 L460,40 L470,60 L490,60 L510,80 L530,10 L540,110 L560,60 L580,60 L600,40 L620,60 L650,60 L660,40 L670,60 L690,60 L710,80 L730,10 L740,110 L760,60 L780,60 L800,40" 
                fill="none" 
                stroke="#1F2937" 
                strokeWidth="1.5"
                strokeLinejoin="round"
              />
            </svg>
            <div className="grid-overlay"></div>
          </div>
          <div className="metrics-simple">
            <span>HR: 112 bpm</span>
            <span>PR: 140 ms</span>
            <span>QRS: 95 ms</span>
            <span>QTc: 420 ms</span>
          </div>
        </div>

        <div className="divider"></div>

        <div className="findings-section">
          <h3 className="section-title">AI ANALYSIS FINDINGS</h3>
          <div className="findings-box abnormal">
            <h4>PRIMARY IMPRESSION: ABNORMAL ECG</h4>
            <p><strong>Detected:</strong> Atrial Fibrillation with rapid ventricular response.</p>
            <p><strong>Secondary:</strong> Frequent Premature Ventricular Contractions (PVCs).</p>
            <p><strong>AI Confidence Level:</strong> 94.2%</p>
          </div>
        </div>

        <div className="divider"></div>

        <div className="doctor-section">
          <h3 className="section-title">CLINICIAN ASSESSMENT & PLAN</h3>
          <p className="doctor-notes">
            The patient presented with complaints of palpitations and shortness of breath. The ECG confirms Atrial Fibrillation with a rapid ventricular rate (112 bpm). 
            Given the patient's symptoms and ECG findings, rate control management is required immediately. 
            <br/><br/>
            <strong>Plan:</strong><br/>
            1. Administer Beta-blocker (Metoprolol 25mg IV) for rate control.<br/>
            2. Check comprehensive metabolic panel, thyroid function, and troponins.<br/>
            3. Admit to telemetry for continuous monitoring.<br/>
            4. Consider anticoagulation therapy pending CHA2DS2-VASc score evaluation.
          </p>
          
          <div className="signature-area">
            <div className="signature-line">
              <span className="cursive-font" style={{fontSize: '24px', fontFamily: 'Georgia, serif', color: '#0A66C2'}}>Dr. Ishan Aththanayake</span>
              <div className="sig-border"></div>
              <p>Dr. Ishan Aththanayake, MD, FACC</p>
              <p className="text-muted">Attending Cardiologist</p>
              <p className="text-muted">License: MC-849302</p>
            </div>
            <div className="date-line">
              <span style={{fontSize: '16px'}}>Oct 24, 2023 15:10 EST</span>
              <div className="sig-border"></div>
              <p>Date & Time</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Report;
