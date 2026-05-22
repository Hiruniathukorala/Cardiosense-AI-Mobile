import { NavLink, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Upload, FileText, Users, Activity, Settings, LogOut, MessageSquare } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import logo from '../assets/cardiosense-logo.svg';
import './Sidebar.css';

const Sidebar = () => {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const navItems = [
    { name: 'Dashboard', path: '/', icon: <LayoutDashboard size={20} /> },
    { name: 'Upload ECG', path: '/upload', icon: <Upload size={20} /> },
    { name: 'Results', path: '/results', icon: <Activity size={20} /> },
    { name: 'Chat', path: '/chat', icon: <MessageSquare size={20} /> },
    { name: 'Patients', path: '/patients', icon: <Users size={20} /> },
    { name: 'Reports', path: '/reports', icon: <FileText size={20} /> },
  ];

  return (
    <aside className="sidebar">
      <div className="sidebar-logo">
        <img src={logo} alt="CardioSense AI logo" className="sidebar-logo-img" />
        <h2>CardioSense AI</h2>
      </div>
      
      <nav className="sidebar-nav">
        {navItems.map((item) => (
          <NavLink 
            key={item.name} 
            to={item.path} 
            className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
          >
            {item.icon}
            <span>{item.name}</span>
          </NavLink>
        ))}
      </nav>

      <div className="sidebar-footer">
        <NavLink to="/login" className="nav-item">
          <Settings size={20} />
          <span>Settings</span>
        </NavLink>
        {user ? (
          <button
            type="button"
            onClick={() => {
              logout();
              navigate('/login');
            }}
            className="nav-item text-danger sidebar-button"
          >
            <LogOut size={20} />
            <span>Logout</span>
          </button>
        ) : (
          <NavLink to="/register" className="nav-item text-primary">
            <LogOut size={20} />
            <span>Register</span>
          </NavLink>
        )}
      </div>
    </aside>
  );
};

export default Sidebar;
