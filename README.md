<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CardioSense AI · GitHub README</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      background: #0a0c12;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Inter', 'SF Mono', 'Roboto', monospace;
      padding: 48px 24px;
      line-height: 1.6;
      color: #eef2ff;
    }

    .readme-container {
      max-width: 1100px;
      margin: 0 auto;
      background: #0f111a;
      border-radius: 32px;
      border: 1px solid rgba(37, 99, 235, 0.25);
      overflow: hidden;
      box-shadow: 0 25px 40px -12px rgba(0, 0, 0, 0.6);
    }

    /* header section with blue heart */
    .repo-header {
      background: linear-gradient(135deg, #0b1120 0%, #10162b 100%);
      padding: 48px 40px 32px 40px;
      border-bottom: 1px solid #1e2a4a;
      text-align: center;
      position: relative;
      overflow: hidden;
    }

    .blue-heart {
      display: inline-block;
      font-size: 56px;
      filter: drop-shadow(0 0 12px rgba(59,130,246,0.6));
      animation: heartbeat 1.5s ease infinite;
      margin-bottom: 16px;
    }

    @keyframes heartbeat {
      0%, 100% { transform: scale(1); }
      15% { transform: scale(1.2); }
      30% { transform: scale(1); }
      45% { transform: scale(1.1); }
      60% { transform: scale(1); }
    }

    h1 {
      font-size: 3.2rem;
      font-weight: 800;
      background: linear-gradient(120deg, #ffffff, #7aa9ff, #3b82f6);
      background-clip: text;
      -webkit-background-clip: text;
      color: transparent;
      letter-spacing: -0.02em;
      margin-bottom: 12px;
    }

    .tagline {
      font-size: 1.1rem;
      color: #9aa9c7;
      max-width: 680px;
      margin: 0 auto;
    }

    .badge-strip {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 12px;
      margin: 28px 0 10px;
    }

    .badge {
      background: #151e2c;
      padding: 6px 14px;
      border-radius: 60px;
      font-size: 0.75rem;
      font-weight: 500;
      font-family: monospace;
      border: 1px solid #2a3a55;
      color: #b9d0ff;
    }

    /* main content */
    .readme-body {
      padding: 44px 40px;
    }

    h2 {
      font-size: 1.8rem;
      font-weight: 700;
      margin: 40px 0 16px 0;
      padding-bottom: 8px;
      border-bottom: 2px solid #1f2b42;
      display: inline-block;
      letter-spacing: -0.3px;
    }

    h3 {
      font-size: 1.35rem;
      font-weight: 600;
      margin: 28px 0 12px 0;
      color: #cbd5ff;
    }

    p {
      color: #b9c3e0;
      margin-bottom: 1.2rem;
    }

    .features-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 20px;
      margin: 30px 0 20px;
    }

    .feature-card {
      background: #121624;
      border-radius: 24px;
      padding: 20px 22px;
      border: 1px solid #232b3c;
      transition: 0.2s ease;
    }

    .feature-card:hover {
      border-color: #3b82f6;
      transform: translateY(-3px);
    }

    .feature-emoji {
      font-size: 28px;
      margin-bottom: 12px;
      display: block;
    }

    .feature-title {
      font-weight: 700;
      font-size: 1.1rem;
      margin-bottom: 6px;
    }

    .feature-desc {
      font-size: 0.85rem;
      color: #8e9bbe;
      line-height: 1.45;
    }

    .architecture {
      background: #0b0e16;
      border-radius: 28px;
      padding: 28px;
      margin: 28px 0;
      border: 1px solid #1f2a44;
    }

    .layer {
      margin-bottom: 24px;
    }

    .layer-name {
      font-family: monospace;
      font-size: 0.8rem;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: #6b85c2;
      margin-bottom: 12px;
    }

    .layer-boxes {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
    }

    .layer-box {
      background: #0f1420;
      flex: 1;
      min-width: 180px;
      border-radius: 18px;
      padding: 16px 18px;
      border: 1px solid #232e46;
    }

    .layer-box strong {
      color: #90acf0;
    }

    hr {
      border: none;
      height: 1px;
      background: linear-gradient(90deg, transparent, #2d3b60, transparent);
      margin: 40px 0;
    }

    .pipeline {
      display: flex;
      flex-direction: column;
      gap: 8px;
      background: #0b0f18;
      border-radius: 24px;
      padding: 24px;
    }

    .step {
      display: flex;
      gap: 16px;
      align-items: baseline;
      border-left: 2px solid #2d4670;
      padding-left: 18px;
      margin: 6px 0;
    }

    .step-marker {
      font-family: monospace;
      font-weight: bold;
      color: #3b82f6;
      min-width: 32px;
    }

    .risk-table {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      margin: 24px 0;
    }

    .risk-card {
      flex: 1;
      background: #111722;
      border-radius: 20px;
      padding: 18px;
      text-align: center;
      border: 1px solid #253153;
    }

    .risk-low { border-top: 4px solid #22c55e; }
    .risk-mod { border-top: 4px solid #facc15; }
    .risk-high { border-top: 4px solid #f97316; }
    .risk-crit { border-top: 4px solid #ef4444; }

    .risk-score {
      font-size: 1.5rem;
      font-weight: 800;
      font-family: monospace;
    }

    pre {
      background: #090c14;
      padding: 18px;
      border-radius: 20px;
      overflow-x: auto;
      font-family: 'Fira Code', monospace;
      font-size: 0.8rem;
      border: 1px solid #1e293b;
      margin: 20px 0;
      color: #b9f2ff;
    }

    code {
      font-family: monospace;
      background: #131a26;
      padding: 3px 8px;
      border-radius: 12px;
      font-size: 0.85rem;
    }

    .api-grid {
      overflow-x: auto;
      background: #0b0f1a;
      border-radius: 20px;
      padding: 4px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
    }

    th, td {
      text-align: left;
      padding: 12px 16px;
      border-bottom: 1px solid #20273b;
    }

    th {
      color: #9bb1e0;
      font-weight: 500;
    }

    .method {
      font-family: monospace;
      font-weight: 700;
      padding: 4px 8px;
      border-radius: 30px;
      font-size: 0.7rem;
      display: inline-block;
    }
    .get { background: #14532d20; color: #4ade80; border: 1px solid #22c55e40; }
    .post { background: #1e3a8a30; color: #60a5fa; border: 1px solid #3b82f650; }
    .put { background: #b4530920; color: #fbbf24; border: 1px solid #f59e0b50; }

    .footnote {
      background: #10141f;
      border-radius: 20px;
      padding: 20px;
      margin-top: 40px;
      border-left: 5px solid #3b82f6;
    }

    .contributing-box {
      background: #0f1422;
      border-radius: 20px;
      padding: 18px 24px;
    }

    @media (max-width: 720px) {
      .readme-body { padding: 28px 20px; }
      h1 { font-size: 2.2rem; }
    }
  </style>
</head>
<body>
<div class="readme-container">
  <div class="repo-header">
    <div class="blue-heart">💙</div>
    <h1>CardioSense AI</h1>
    <div class="tagline">AI-Powered Cardiovascular Health Monitoring System — Real-time ECG analysis · Arrhythmia detection · Personalized cardiac risk assessment</div>
    <div class="badge-strip">
      <span class="badge">React 19.x</span>
      <span class="badge">Flutter 3.x</span>
      <span class="badge">Node.js 20+</span>
      <span class="badge">Vite 8</span>
      <span class="badge">C++ AI Engine</span>
      <span class="badge">MIT License</span>
    </div>
  </div>

  <div class="readme-body">
    <!-- Overview -->
    <h2>📖 Overview</h2>
    <p><strong>CardioSense AI</strong> is a full-stack, intelligent cardiovascular monitoring platform that bridges wearable ECG devices, mobile patients, and clinical dashboards. It leverages a real-time AI inference engine (C++) to detect arrhythmias, compute dynamic risk scores, and deliver smart alerts — empowering both patients and healthcare providers with actionable heart health intelligence.</p>
    <p>Built with a <strong>Flutter mobile app</strong> for on-the-go monitoring, a <strong>React dashboard</strong> for clinicians, and a robust <strong>Node.js backend</strong> hosting a high-performance C++ ML pipeline.</p>

    <!-- Key Features 2x2 grid with blue heart motif-->
    <h2>✨ Key Features</h2>
    <div class="features-grid">
      <div class="feature-card"><span class="feature-emoji">💙</span><div class="feature-title">Real-Time ECG Analysis</div><div class="feature-desc">Continuous streaming & visualization of ECG from wearables (BLE / simulation).</div></div>
      <div class="feature-card"><span class="feature-emoji">⚡</span><div class="feature-title">Arrhythmia Detection</div><div class="feature-desc">AI classification: AFib, PVCs, Tachycardia, Bradycardia & more.</div></div>
      <div class="feature-card"><span class="feature-emoji">📊</span><div class="feature-title">Cardiac Risk Scoring</div><div class="feature-desc">0–100 personalized risk score — Low → Critical.</div></div>
      <div class="feature-card"><span class="feature-emoji">📱</span><div class="feature-title">Flutter Mobile App</div><div class="feature-desc">iOS/Android patient portal, ECG trends, vital monitoring, alerts.</div></div>
      <div class="feature-card"><span class="feature-emoji">🖥️</span><div class="feature-title">React Web Dashboard</div><div class="feature-desc">Clinician analytics, patient overview, alert management, reports.</div></div>
      <div class="feature-card"><span class="feature-emoji">🔔</span><div class="feature-title">Smart Alerts</div><div class="feature-desc">Instant push notifications for critical or high-risk events.</div></div>
    </div>

    <!-- System Architecture -->
    <h2>🏗️ System Architecture</h2>
    <div class="architecture">
      <div class="layer">
        <div class="layer-name">🎨 PRESENTATION LAYER</div>
        <div class="layer-boxes">
          <div class="layer-box"><strong>📱 Flutter Mobile</strong><br/>ECG viewer · Health Alerts · Risk dashboard · Profile</div>
          <div class="layer-box"><strong>🖥️ React Web</strong><br/>Patient overview · Analytics · Alert panel · Reports</div>
        </div>
      </div>
      <div style="text-align:center; margin: 12px 0; color:#3b82f6; font-size: 20px;">⬇️ HTTPS / REST API ⬇️</div>
      <div class="layer">
        <div class="layer-name">⚙️ APPLICATION LAYER (Node.js + Express)</div>
        <div class="layer-boxes">
          <div class="layer-box"><strong>🔐 Auth & Users</strong><br/>JWT, role-based access</div>
          <div class="layer-box"><strong>📡 ECG Ingestion</strong><br/>Signal validation & routing</div>
          <div class="layer-box" style="border-color:#3b82f6;"><strong>🧠 AI Inference Engine (C++)</strong><br/>Noise filtering · Pan-Tompkins R-peak · Arrhythmia classifier · Risk scorer</div>
        </div>
      </div>
      <div style="text-align:center; margin: 12px 0; color:#3b82f6;">⬇️ Data Queries ⬇️</div>
      <div class="layer">
        <div class="layer-name">🗄️ DATA LAYER</div>
        <div class="layer-boxes">
          <div class="layer-box"><strong>Patient DB</strong><br/>profiles, history</div>
          <div class="layer-box"><strong>ECG Time‑Series DB</strong><br/>raw signals + analysis results</div>
        </div>
      </div>
    </div>

    <!-- AI Pipeline + risk bands -->
    <h2>🧠 AI Model Pipeline & Risk Scoring</h2>
    <div class="pipeline">
      <div class="step"><span class="step-marker">①</span> Bandpass filter (0.5–40 Hz) → remove noise & wander</div>
      <div class="step"><span class="step-marker">②</span> Derivative filter → amplify QRS slopes</div>
      <div class="step"><span class="step-marker">③</span> Squaring & moving window integration → energy peaks</div>
      <div class="step"><span class="step-marker">④</span> Pan‑Tompkins R‑Peak detection → heartbeats</div>
      <div class="step"><span class="step-marker">⑤</span> Feature extraction: RR intervals, HRV, QRS, PR, QT, ST deviation</div>
      <div class="step"><span class="step-marker">⑥</span> ML Arrhythmia Classifier (N, A, V, S, F classes)</div>
      <div class="step"><span class="step-marker">⑦</span> <strong style="color:#3b82f6;">Cardiac Risk Score (0–100)</strong></div>
    </div>

    <div class="risk-table">
      <div class="risk-card risk-low"><div class="risk-score">0–30</div>✅ Low Risk<br/><span style="font-size:12px;">Normal monitoring</span></div>
      <div class="risk-card risk-mod"><div class="risk-score">31–60</div>⚠️ Moderate<br/><span style="font-size:12px;">Lifestyle review</span></div>
      <div class="risk-card risk-high"><div class="risk-score">61–85</div>🔶 High Risk<br/><span style="font-size:12px;">Clinical follow-up</span></div>
      <div class="risk-card risk-crit"><div class="risk-score">86–100</div>🚨 Critical<br/><span style="font-size:12px;">Immediate alert</span></div>
    </div>

    <!-- Tech Stack -->
    <h2>🛠️ Tech Stack</h2>
    <div style="display: flex; gap: 20px; flex-wrap: wrap; margin: 20px 0;">
      <div style="flex:1; background:#111722; border-radius: 24px; padding: 18px;">
        <h3 style="margin:0 0 12px 0;">Frontend (Web)</h3>
        <ul style="color:#b9c3e0; margin-left: 20px;">
          <li>React 19 + Vite 8</li>
          <li>React Router v7</li>
          <li>CSS Modules / Lucide Icons</li>
        </ul>
      </div>
      <div style="flex:1; background:#111722; border-radius: 24px; padding: 18px;">
        <h3 style="margin:0 0 12px 0;">Mobile</h3>
        <ul style="color:#b9c3e0; margin-left: 20px;">
          <li>Flutter 3.x · Dart</li>
          <li>BLE packages for wearables</li>
        </ul>
      </div>
      <div style="flex:1; background:#111722; border-radius: 24px; padding: 18px;">
        <h3 style="margin:0 0 12px 0;">Backend + AI</h3>
        <ul style="color:#b9c3e0; margin-left: 20px;">
          <li>Node.js · Express</li>
          <li>C++ inference engine (CMake)</li>
        </ul>
      </div>
    </div>

    <!-- Project Structure -->
    <h2>📁 Project Structure</h2>
    <pre>
Cardiosense-AI/
├── src/                     # React web dashboard
│   ├── components/          # Reusable UI
│   ├── pages/               # Route pages
│   └── utils/
├── backend/                 # Node.js API server
│   ├── routes/              # REST endpoints
│   ├── controllers/         # Business logic
│   ├── ai/                  # C++ AI engine (ECG analysis)
│   └── models/
├── cardiosense_mobile/      # Flutter mobile app
│   ├── lib/screens/         # UI screens
│   ├── lib/services/        # API & BLE
│   └── ...
├── public/                  # static assets
├── vite.config.js
└── package.json
    </pre>

    <!-- Getting Started -->
    <h2>🚀 Getting Started</h2>
    <p><strong>Prerequisites:</strong> Node.js ≥ 18, npm ≥ 9, Flutter SDK ≥ 3, CMake ≥ 3.x</p>

    <pre><span style="color:#60a5fa;"># 1. Clone the repository</span>
git clone https://github.com/Hiruniathukorala/Cardiosense-AI.git
cd Cardiosense-AI

<span style="color:#60a5fa;"># 2. Start Web Dashboard (React)</span>
npm install
npm run dev
# ➜ http://localhost:5173

<span style="color:#60a5fa;"># 3. Run Backend API (Node + C++ inference)</span>
cd backend
npm install
npm start
# Backend on http://localhost:5001

<span style="color:#60a5fa;"># 4. Launch Flutter Mobile App</span>
cd ../cardiosense_mobile
flutter pub get
flutter run
    </pre>

    <!-- API Reference (concise but complete) -->
    <h2>📡 API Reference</h2>
    <div class="api-grid">
      <table>
        <thead><tr><th>Method</th><th>Endpoint</th><th>Description</th></tr></thead>
        <tbody>
          <tr><td><span class="method post">POST</span></td><td><code>/api/ecg/stream</code></td><td>Ingest raw ECG signal data</td></tr>
          <tr><td><span class="method get">GET</span></td><td><code>/api/ecg/:patientId/history</code></td><td>Retrieve ECG history</td></tr>
          <tr><td><span class="method get">GET</span></td><td><code>/api/ecg/:recordId/analysis</code></td><td>Get AI analysis for a record</td></tr>
          <tr><td><span class="method get">GET</span></td><td><code>/api/patients</code></td><td>List all patients</td></tr>
          <tr><td><span class="method get">GET</span></td><td><code>/api/patients/:id</code></td><td>Patient profile</td></tr>
          <tr><td><span class="method put">PUT</span></td><td><code>/api/patients/:id</code></td><td>Update patient data</td></tr>
          <tr><td><span class="method get">GET</span></td><td><code>/api/health/risk/:patientId</code></td><td>Current cardiac risk score</td></tr>
          <tr><td><span class="method get">GET</span></td><td><code>/api/alerts/:patientId</code></td><td>Get alerts for patient</td></tr>
        </tbody>
      </table>
    </div>

    <!-- Data flow diagram (text-based but expressive) -->
    <h2>🔄 Data Flow (Simplified)</h2>
    <pre style="background:#0a0e18; font-size:0.7rem; line-height:1.5;">
[ Wearable / ECG Sensor ] → (BLE) → [ Flutter Mobile App ]
                                          │
                                          ▼ (HTTPS POST /api/ecg/stream)
                                   [ Node.js Backend ]
                                          │
                                          ▼
                              [ AI Inference Engine (C++) ]
                     (preprocess → R-peak detection → feature extraction)
                                          │
                                          ▼
                              [ Arrhythmia classifier & Risk Scorer ]
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    ▼                     ▼                     ▼
             [Critical Alert]       [Push Notification]    [Patient DB]
                 (🚨)                   (⚠️ warning)        (store result)
                                          │
                                          ▼
                                   [ React Web Dashboard ]
                                   & [ Mobile risk UI ]
    </pre>

    <!-- Contributing section -->
    <h2>🤝 Contributing</h2>
    <div class="contributing-box">
      <p>Contributions are welcome! Follow these steps:</p>
      <ol style="margin-left: 24px; color:#b0c2e8;">
        <li>Fork the repository</li>
        <li>Create a feature branch: <code>git checkout -b feature/amazing-feature</code></li>
        <li>Commit changes: <code>git commit -m 'Add amazing feature'</code></li>
        <li>Push to branch: <code>git push origin feature/amazing-feature</code></li>
        <li>Open a Pull Request 🚀</li>
      </ol>
    </div>

    <!-- License & Disclaimer -->
    <h2>📜 License & Disclaimer</h2>
    <div class="footnote">
      <p><strong>MIT License</strong> — free to use, modify, and distribute with attribution.</p>
      <p style="margin-top: 12px;"><strong>⚠️ Medical Disclaimer:</strong> CardioSense AI is not a substitute for professional medical advice. It is an informational tool for monitoring and research. Always consult a physician for cardiac diagnosis or treatment. The authors assume no liability for clinical use.</p>
      <p style="margin-top: 16px;">💙 Made with passion for cardiovascular health & AI. Built by <strong>Hiruni Athukorala</strong> and contributors.</p>
    </div>

    <hr />
    <div style="text-align: center; font-size: 0.8rem; color: #6d7faf;">
      ⭐ Star this repo if it helps your heart health research | Report issues on GitHub
    </div>
  </div>
</div>
</body>
</html>
