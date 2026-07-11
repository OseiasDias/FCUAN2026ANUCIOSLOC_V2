import React from 'react';
import { FaUsers, FaBullhorn, FaMapMarkedAlt, FaCoins } from 'react-icons/fa';

const StatCard = ({ title, value, icon, color, subtitle }) => {
  const icons = {
    users: <FaUsers size={24} />,
    anuncios: <FaBullhorn size={24} />,
    locais: <FaMapMarkedAlt size={24} />,
    saldo: <FaCoins size={24} />,
  };

  const colors = {
    purple: '#6200EE',
    blue: '#0D6EFD',
    green: '#198754',
    orange: '#FD7E14',
  };

  return (
    <div className="card shadow-sm h-100">
      <div className="card-body d-flex align-items-center">
        <div 
          className="rounded-circle d-flex align-items-center justify-content-center me-3"
          style={{ 
            width: '56px', 
            height: '56px', 
            backgroundColor: colors[color] + '20',
            color: colors[color]
          }}
        >
          {icons[icon] || icons.users}
        </div>
        <div>
          <h6 className="text-muted mb-0" style={{ fontSize: '14px' }}>{title}</h6>
          <h3 className="mb-0 fw-bold">{value}</h3>
          {subtitle && <small className="text-muted">{subtitle}</small>}
        </div>
      </div>
    </div>
  );
};

export default StatCard;