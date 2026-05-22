import { Bell, Search, User } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import './Header.css';

const Header = () => {
  const { user } = useAuth();
  const displayName = user
    ? `${user.role === 'Cardiologist' ? 'Dr.' : ''} ${user.name}`
    : 'Guest User';
  const displayRole = user ? user.role : 'Visitor';

  return (
    <header className="header">
      <div className="header-search">
        <Search size={18} className="search-icon" />
        <input type="text" placeholder="Search patients, reports, ID..." className="search-input" />
      </div>

      <div className="header-actions">
        <button className="icon-btn notification-btn">
          <Bell size={20} />
          <span className="notification-badge">3</span>
        </button>
        
        <div className="user-profile">
          <div className="avatar">
            <User size={20} color="#fff" />
          </div>
          <div className="user-info">
            <span className="user-name">{displayName}</span>
            <span className="user-role">{displayRole}</span>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
