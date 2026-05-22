import { Activity, Users, AlertTriangle, CheckCircle, ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useReports } from '../context/ReportsContext';
import './Dashboard.css';

const Dashboard = () => {
  const { user } = useAuth();
  const { getReportsByCardiologist, getReportsByPatient } = useReports();
  const welcomeName = user ? `${user.role === 'Cardiologist' ? 'Dr.' : ''} ${user.name}` : 'Guest';
  const welcomeText = user
    ? `Welcome back, ${welcomeName}. Here's today's summary.`
    : 'Welcome to CardioSense AI. Please login or register to continue.';

  // Filter reports based on user role
  const userReports = user
    ? user.role === 'Cardiologist'
      ? getReportsByCardiologist(user.email)
      : getReportsByPatient(user.email)
    : [];

  const stats = user?.role === 'Patient' 
    ? [
        { title: 'My Reports', value: userReports.length.toString(), icon: <Activity size={24} color="#0A66C2" />, bg: '#EBF3FF' },
        { title: 'Normal', value: userReports.filter(r => r.status === 'Normal').length.toString(), icon: <CheckCircle size={24} color="#10B981" />, bg: '#D1FAE5' },
        { title: 'Abnormal', value: userReports.filter(r => r.status === 'Abnormal').length.toString(), icon: <AlertTriangle size={24} color="#F59E0B" />, bg: '#FEF3C7' },
        { title: 'Critical', value: userReports.filter(r => r.status === 'Critical').length.toString(), icon: <AlertTriangle size={24} color="#EF4444" />, bg: '#FEE2E2' },
      ]
    : [
        { title: 'Total ECGs Analyzed', value: userReports.length.toString(), icon: <Activity size={24} color="#0A66C2" />, bg: '#EBF3FF' },
        { title: 'Normal Cases', value: userReports.filter(r => r.status === 'Normal').length.toString(), icon: <CheckCircle size={24} color="#10B981" />, bg: '#D1FAE5' },
        { title: 'Abnormal Cases', value: userReports.filter(r => r.status === 'Abnormal').length.toString(), icon: <AlertTriangle size={24} color="#F59E0B" />, bg: '#FEF3C7' },
        { title: 'Critical Alerts', value: userReports.filter(r => r.status === 'Critical').length.toString(), icon: <AlertTriangle size={24} color="#EF4444" />, bg: '#FEE2E2' },
      ];

  const displayedReports = userReports.slice(0, 5);

  const getStatusBadge = (status) => {
    switch(status) {
      case 'Normal': return <span className="badge badge-success">Normal</span>;
      case 'Abnormal': return <span className="badge badge-warning">Abnormal</span>;
      case 'Critical': return <span className="badge badge-danger">Critical</span>;
      case 'Pending': return <span className="badge" style={{backgroundColor: '#E5E7EB', color: '#374151'}}>Pending</span>;
      default: return null;
    }
  };

  return (
    <div className="dashboard-page">
      <div className="page-title">
        <div>
          <h1>Dashboard Overview</h1>
          <p className="text-muted" style={{marginTop: '4px', fontSize: '14px'}}>{welcomeText}</p>
        </div>
        {user?.role === 'Cardiologist' && (
          <Link to="/upload" className="btn btn-primary">
            <Activity size={18} />
            Upload New ECG
          </Link>
        )}
      </div>

      <div className="stats-grid">
        {stats.map((stat, idx) => (
          <div className="card stat-card" key={idx}>
            <div className="stat-icon" style={{ backgroundColor: stat.bg }}>
              {stat.icon}
            </div>
            <div className="stat-info">
              <h3>{stat.value}</h3>
              <p className="text-muted">{stat.title}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="card mt-8">
        <div className="card-header">
          <h2>{user?.role === 'Patient' ? 'My Reports History' : 'Recent ECG Uploads'}</h2>
          <Link to="/results" className="btn btn-outline" style={{padding: '6px 12px', fontSize: '13px'}}>
            View All <ArrowRight size={14} />
          </Link>
        </div>
        {displayedReports.length === 0 ? (
          <div style={{ padding: '32px', textAlign: 'center', color: '#6B7280' }}>
            <p>
              {user?.role === 'Patient'
                ? 'No reports available yet. Contact your cardiologist to get an ECG analysis.'
                : 'No ECG uploads yet. Start uploading ECGs to see reports here.'}
            </p>
          </div>
        ) : (
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Report ID</th>
                  <th>{user?.role === 'Patient' ? 'Cardiologist' : 'Patient Name'}</th>
                  <th>Date & Time</th>
                  <th>AI Diagnosis</th>
                  <th>Confidence</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {displayedReports.map((row, idx) => (
                  <tr key={idx}>
                    <td style={{fontWeight: '500', color: '#0A66C2'}}>{row.reportId}</td>
                    <td>{user?.role === 'Patient' ? row.cardiologistName : row.patientName}</td>
                    <td className="text-muted">
                      {new Date(row.createdAt).toLocaleDateString()} {new Date(row.createdAt).toLocaleTimeString()}
                    </td>
                    <td>{getStatusBadge(row.status)}</td>
                    <td>{row.confidence}</td>
                    <td>
                      <Link to="/results" className="btn btn-outline" style={{padding: '4px 12px', fontSize: '12px'}}>
                        {user?.role === 'Patient' ? 'View' : 'Review'}
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
