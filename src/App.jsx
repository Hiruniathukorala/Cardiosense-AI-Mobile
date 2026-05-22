import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import UploadECG from './pages/UploadECG';
import Results from './pages/Results';
import DoctorReview from './pages/DoctorReview';
import Report from './pages/Report';
import ChatBot from './pages/ChatBot';
import Login from './pages/Login';
import Register from './pages/Register';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="upload" element={<UploadECG />} />
          <Route path="results" element={<Results />} />
          <Route path="review" element={<DoctorReview />} />
          <Route path="report" element={<Report />} />
          <Route path="chat" element={<ChatBot />} />
          <Route path="patients" element={<div className="page-title"><h1>Patients Directory (Coming Soon)</h1></div>} />
          <Route path="reports" element={<div className="page-title"><h1>All Reports (Coming Soon)</h1></div>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
