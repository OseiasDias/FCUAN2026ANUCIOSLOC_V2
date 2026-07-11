import React from 'react';
import { FaBars, FaBell, FaSearch, FaUserCircle } from 'react-icons/fa';
import { useLocation } from 'react-router-dom';
import './HeaderProfissional.css';

const HeaderProfissional = ({ 
  onToggleMobile, 
  isMobileOpen, 
  onLogout 
}) => {
  const location = useLocation();

  const getPageTitle = () => {
    const path = location.pathname;
    if (path === '/') return 'Dashboard';
    if (path === '/utilizadores') return 'Utilizadores';
    if (path === '/anuncios') return 'Anúncios';
    if (path === '/locais') return 'Locais';
    if (path === '/estatisticas') return 'Estatísticas';
    if (path === '/configuracoes') return 'Configurações';
    return 'Dashboard';
  };

  const getPageSubtitle = () => {
    const path = location.pathname;
    if (path === '/') return 'Visão geral da plataforma';
    if (path === '/utilizadores') return 'Gerir todos os utilizadores';
    if (path === '/anuncios') return 'Moderar anúncios';
    if (path === '/locais') return 'Gerir infraestruturas';
    if (path === '/estatisticas') return 'Análise de dados da plataforma';
    if (path === '/configuracoes') return 'Definições do sistema';
    return '';
  };

  return (
    <header className="header-profissional">
      <div className="header-left">
        <button className="mobile-toggle" onClick={onToggleMobile}>
          <FaBars />
        </button>
        <div>
          <h2 className="header-title">{getPageTitle()}</h2>
          <p className="header-subtitle">{getPageSubtitle()}</p>
        </div>
      </div>

      <div className="header-right">
        <div className="search-box">
          <FaSearch className="search-icon" />
          <input type="text" placeholder="Pesquisar..." />
        </div>
        
        <button className="notification-btn">
          <FaBell />
          <span className="notification-dot"></span>
        </button>
        
        <div className="user-profile" onClick={onLogout}>
          <FaUserCircle className="user-avatar" />
          <span className="user-name">Admin</span>
        </div>
      </div>
    </header>
  );
};

export default HeaderProfissional;