import React, { useState, useRef, useEffect } from 'react';
import { 
  FaBars, 
  FaBell, 
  FaSearch, 
  FaUserCircle, 
  FaTimes,
  FaChevronDown,
  FaSignOutAlt,
  FaCog,
  FaUser,
  FaMoon,
  FaSun,
  FaRegBell,
  FaRegEnvelope
} from 'react-icons/fa';
import { useLocation, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import './HeaderProfissional.css';

const HeaderProfissional = ({ 
  onToggleMobile, 
  isMobileOpen, 
  onLogout 
}) => {
  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [isUserMenuOpen, setIsUserMenuOpen] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  
  const location = useLocation();
  const navigate = useNavigate();
  const userMenuRef = useRef(null);
  const notificationRef = useRef(null);

  const notifications = [
    { id: 1, text: 'Novo utilizador registado', time: '5 min atrás', read: false, icon: 'user' },
    { id: 2, text: 'Anúncio reportado como spam', time: '15 min atrás', read: false, icon: 'flag' },
    { id: 3, text: 'Sistema atualizado para v2.0', time: '1 hora atrás', read: true, icon: 'update' },
  ];

  const unreadCount = notifications.filter(n => !n.read).length;

  const getPageTitle = () => {
    const path = location.pathname;
    const titles = {
      '/': 'Dashboard',
      '/utilizadores': 'Utilizadores',
      '/anuncios': 'Anúncios',
      '/locais': 'Locais',
      '/estatisticas': 'Estatísticas',
      '/configuracoes': 'Configurações'
    };
    return titles[path] || 'Dashboard';
  };

  const getPageSubtitle = () => {
    const path = location.pathname;
    const subtitles = {
      '/': 'Visão geral da plataforma',
      '/utilizadores': 'Gerir todos os utilizadores',
      '/anuncios': 'Moderar anúncios da plataforma',
      '/locais': 'Gerir infraestruturas e locais',
      '/estatisticas': 'Análise de dados da plataforma',
      '/configuracoes': 'Definições do sistema'
    };
    return subtitles[path] || '';
  };

  const toggleDarkMode = () => {
    setIsDarkMode(!isDarkMode);
    document.body.classList.toggle('dark-mode');
  };

  const handleSearch = (e) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      navigate(`/pesquisa?q=${encodeURIComponent(searchQuery)}`);
      setIsSearchOpen(false);
      setSearchQuery('');
    }
  };

  const markAllAsRead = () => {
    // Marcar todas como lidas
  };

  // Fechar dropdowns ao clicar fora
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (userMenuRef.current && !userMenuRef.current.contains(event.target)) {
        setIsUserMenuOpen(false);
      }
      if (notificationRef.current && !notificationRef.current.contains(event.target)) {
        setShowNotifications(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <header className={`header-profissional ${isDarkMode ? 'dark' : ''}`}>
      {/* ========== LADO ESQUERDO ========== */}
      <div className="header-left">
        <button className="mobile-toggle" onClick={onToggleMobile}>
          <FaBars />
        </button>
        
        <div className="header-breadcrumb">
          <h2 className="header-title">{getPageTitle()}</h2>
          <p className="header-subtitle">{getPageSubtitle()}</p>
        </div>
      </div>

      {/* ========== LADO DIREITO ========== */}
      <div className="header-right">
        {/* Barra de pesquisa */}
        <form className={`search-container ${isSearchOpen ? 'open' : ''}`} onSubmit={handleSearch}>
          <AnimatePresence>
            {isSearchOpen && (
              <motion.div
                initial={{ width: 0, opacity: 0 }}
                animate={{ width: 220, opacity: 1 }}
                exit={{ width: 0, opacity: 0 }}
                transition={{ duration: 0.3 }}
                className="search-input-wrapper"
              >
                <input
                  type="text"
                  placeholder="Pesquisar..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  autoFocus
                  className="search-input"
                />
              </motion.div>
            )}
          </AnimatePresence>
          <button 
            type="button"
            className="search-toggle"
            onClick={() => setIsSearchOpen(!isSearchOpen)}
          >
            {isSearchOpen ? <FaTimes /> : <FaSearch />}
          </button>
        </form>

        {/* Notificações */}
        <div className="notification-wrapper" ref={notificationRef}>
          <button 
            className={`notification-btn ${unreadCount > 0 ? 'has-notification' : ''}`}
            onClick={() => setShowNotifications(!showNotifications)}
          >
            <FaRegBell />
            {unreadCount > 0 && (
              <span className="notification-badge">{unreadCount}</span>
            )}
          </button>

          <AnimatePresence>
            {showNotifications && (
              <motion.div
                initial={{ opacity: 0, y: -10, scale: 0.95 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: -10, scale: 0.95 }}
                transition={{ duration: 0.2 }}
                className="notification-dropdown"
              >
                <div className="notification-header">
                  <span>Notificações</span>
                  {unreadCount > 0 && (
                    <button onClick={markAllAsRead} className="mark-all-read">
                      Marcar todas
                    </button>
                  )}
                </div>
                <div className="notification-list">
                  {notifications.length === 0 ? (
                    <div className="notification-empty">
                      <FaRegBell size={32} />
                      <span>Sem notificações</span>
                    </div>
                  ) : (
                    notifications.map((notif) => (
                      <div key={notif.id} className={`notification-item ${notif.read ? 'read' : 'unread'}`}>
                        <div className="notification-dot"></div>
                        <div className="notification-content">
                          <p className="notification-text">{notif.text}</p>
                          <span className="notification-time">{notif.time}</span>
                        </div>
                      </div>
                    ))
                  )}
                </div>
                <div className="notification-footer">
                  <button className="view-all-btn">Ver todas</button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Toggle Dark Mode */}
        <button className="dark-mode-toggle" onClick={toggleDarkMode}>
          {isDarkMode ? <FaSun /> : <FaMoon />}
        </button>

        {/* Perfil do usuário */}
        <div className="user-profile-wrapper" ref={userMenuRef}>
          <div className="user-profile" onClick={() => setIsUserMenuOpen(!isUserMenuOpen)}>
            <div className="user-avatar-wrapper">
              <FaUserCircle className="user-avatar" />
              <span className="user-status"></span>
            </div>
            <div className="user-info">
              <span className="user-name">Administrador</span>
              <span className="user-role">Super Admin</span>
            </div>
            <FaChevronDown className={`dropdown-arrow ${isUserMenuOpen ? 'open' : ''}`} />
          </div>

          <AnimatePresence>
            {isUserMenuOpen && (
              <motion.div
                initial={{ opacity: 0, y: -10, scale: 0.95 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: -10, scale: 0.95 }}
                transition={{ duration: 0.2 }}
                className="user-dropdown"
              >
                <div className="dropdown-user-info">
                  <FaUserCircle className="dropdown-avatar" />
                  <div>
                    <div className="dropdown-user-name">Administrador</div>
                    <div className="dropdown-user-email">admin@anunciosloc.com</div>
                  </div>
                </div>
                <div className="dropdown-divider"></div>
                <button className="dropdown-item" onClick={() => navigate('/perfil')}>
                  <FaUser />
                  <span>Meu Perfil</span>
                </button>
                <button className="dropdown-item" onClick={() => navigate('/configuracoes')}>
                  <FaCog />
                  <span>Configurações</span>
                </button>
                <div className="dropdown-divider"></div>
                <button className="dropdown-item logout" onClick={onLogout}>
                  <FaSignOutAlt />
                  <span>Sair do Sistema</span>
                </button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </header>
  );
};

export default HeaderProfissional;