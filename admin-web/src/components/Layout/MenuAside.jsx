import { useState, useEffect } from "react";
import { AnimatePresence, motion } from "framer-motion";
import { NavLink, useNavigate, useLocation } from "react-router-dom";
import {
  FaHome,
  FaUsers,
  FaBullhorn,
  FaMapMarkedAlt,
  FaCog,
  FaChevronLeft,
  FaChevronRight,
  FaSignOutAlt,
  FaUserCircle,
  FaChartLine
} from "react-icons/fa";
import { Modal } from "react-bootstrap";
import { toast } from "react-hot-toast";
import "./MenuAside.css";

// Componentes do layout
import HeaderProfissional from "./HeaderProfissional";
import FooterProfissional from "./FooterProfissional";

const menuItems = [
  { name: "Dashboard", path: "/", icon: <FaHome />, badge: null },
  { name: "Utilizadores", path: "/utilizadores", icon: <FaUsers />, badge: "12" },
  { name: "Anúncios", path: "/anuncios", icon: <FaBullhorn />, badge: "5" },
  { name: "Locais", path: "/locais", icon: <FaMapMarkedAlt />, badge: null },
  { name: "Estatísticas", path: "/estatisticas", icon: <FaChartLine />, badge: null },
  { name: "Configurações", path: "/configuracoes", icon: <FaCog />, badge: null },
];

const MenuAside = ({ conteudoPrincipal }) => {
  const [isOpen, setIsOpen] = useState(true);
  const [isMobileOpen, setIsMobileOpen] = useState(false);
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  const navigate = useNavigate();
  const location = useLocation();

  // Dados do usuário (simulados)
  const userData = {
    name: localStorage.getItem("adminName") || "Administrador",
    email: localStorage.getItem("adminEmail") || "admin@anunciosloc.com",
    role: "Super Administrador",
    avatar: null
  };

  // Fechar menu mobile ao mudar de página
  useEffect(() => {
    setIsMobileOpen(false);
  }, [location.pathname]);

  // Função de logout
  const handleLogout = () => {
    const keysToRemove = ['authToken', 'adminName', 'adminEmail', 'adminRole'];
    keysToRemove.forEach(key => localStorage.removeItem(key));
    sessionStorage.clear();

    toast.success('Logout realizado com sucesso!');
    navigate('/login');

    setTimeout(() => {
      window.location.reload();
    }, 100);
  };

  // Toggle do menu mobile
  const toggleMobileMenu = () => {
    setIsMobileOpen(!isMobileOpen);
  };

  return (
    <div className="layout-container">
      {/* Overlay para mobile */}
      <div
        className={`mobile-overlay ${isMobileOpen ? 'active' : ''}`}
        onClick={toggleMobileMenu}
      />

        {/* ========== SIDEBAR ========== */}
        <motion.aside
          initial={{ width: 280 }}
          animate={{
            width: isOpen ? 280 : 80,
            x: isMobileOpen ? 0 : -280
          }}
          transition={{ duration: 0.3, ease: "easeInOut" }}
          className={`sidebar ${isOpen ? 'open' : 'collapsed'} ${isMobileOpen ? 'mobile-open' : ''}`}
        >
          {/* TOPO COM LOGO */}
          <div className="sidebar-top">
            <motion.div
              className="logo-area"
              animate={{ justifyContent: isOpen ? "flex-start" : "center" }}
            >
              <AnimatePresence mode="wait">
                {isOpen && (
                  <motion.div
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    transition={{ duration: 0.3 }}
                    className="logo-wrapper"
                  >
                    <span className="logo-emoji">📍</span>
                    <h4 className="logo-text">
                      <span className="logo-highlight">Anuncios</span>Loc
                    </h4>
                  </motion.div>
                )}
              </AnimatePresence>
              {!isOpen && (
                <motion.span
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  className="logo-mini"
                >
                  📍
                </motion.span>
              )}
            </motion.div>

            <motion.button
              className="toggle-btn"
              onClick={() => setIsOpen(!isOpen)}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              title={isOpen ? "Recolher menu" : "Expandir menu"}
            >
              {isOpen ? <FaChevronLeft /> : <FaChevronRight />}
            </motion.button>
          </div>

          {/* PERFIL DO USUÁRIO */}
          <div className="sidebar-profile">
            <div className="profile-content">
              <div className="avatar-wrapper">
                {userData.avatar ? (
                  <img src={userData.avatar} alt={userData.name} className="avatar" />
                ) : (
                  <FaUserCircle className="avatar-icon text-white" />
                )}
                <div className="avatar-status"></div>
              </div>

              <AnimatePresence>
                {isOpen && (
                  <motion.div
                    className="profile-info"
                    initial={{ opacity: 0, x: -10 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -10 }}
                    transition={{ duration: 0.2 }}
                  >
                    <span className="profile-name text-white">{userData.name}</span>
                    <span className="profile-role text-white">{userData.role}</span>
                    <span className="profile-email text-white">{userData.email}</span>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>

          {/* MENU ITEMS */}
          <nav className="sidebar-nav">
            {menuItems.map((item, index) => {
              const isActive = location.pathname === item.path;

              return (
                <NavLink
                  to={item.path}
                  key={index}
                  className={`menu-link ${isActive ? 'active' : ''}`}
                  onClick={() => setIsMobileOpen(false)}
                >
                  <motion.div
                    className="icon-wrapper text-white"
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.95 }}
                  >
                    {item.icon}
                    {isActive && <span className="active-dot"></span>}
                  </motion.div>

                  <AnimatePresence mode="wait">
                    {isOpen && (
                      <motion.span
                        className="link-text text-white"
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -10 }}
                        transition={{ duration: 0.2, delay: index * 0.02 }}
                      >
                        {item.name}
                      </motion.span>
                    )}
                  </AnimatePresence>

                  {item.badge && (
                    <motion.span
                      className="menu-badge"
                      animate={{
                        opacity: isOpen ? 1 : 0,
                        scale: isOpen ? 1 : 0.8
                      }}
                      transition={{ duration: 0.2 }}
                    >
                      {item.badge}
                    </motion.span>
                  )}
                </NavLink>
              );
            })}
          </nav>

          {/* FOOTER COM LOGOUT */}
          <motion.div
            className="sidebar-footer"
            animate={{ opacity: isOpen ? 1 : 0.9 }}
          >
            {isOpen ? (
              <motion.div
                className="footer-content"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.3 }}
              >
                <div className="footer-version">
                  <span className="text-white">v2.0.0</span>
                </div>
                <motion.button
                  className="logout-btn"
                  onClick={() => setShowLogoutModal(true)}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <FaSignOutAlt className="logout-icon text-white" />
                  <span className="text-white">Sair do Sistema</span>
                </motion.button>
              </motion.div>
            ) : (
              <motion.button
                className="logout-btn-mini "
                onClick={() => setShowLogoutModal(true)}
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                title="Sair do Sistema"
              >
                <FaSignOutAlt />
              </motion.button>
            )}
          </motion.div>
        </motion.aside>
      
      {/* ========== CONTEÚDO PRINCIPAL ========== */}
      <main className={`main-content ${isOpen ? 'with-sidebar' : 'with-sidebar-collapsed'}`}>

        <HeaderProfissional
          onToggleMobile={toggleMobileMenu}
          isMobileOpen={isMobileOpen}
          onLogout={() => setShowLogoutModal(true)}
        />
        <div className="content-area">

          {conteudoPrincipal}
        </div>

        <FooterProfissional />
      </main>

      {/* ========== MODAL DE LOGOUT ========== */}
      <Modal
        show={showLogoutModal}
        onHide={() => setShowLogoutModal(false)}
        centered
        className="logout-modal"
      >
        <Modal.Header closeButton>
          <Modal.Title>
            <FaSignOutAlt className="modal-icon" />
            Confirmar Saída
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="logout-modal-body">
            <p>Tem certeza que deseja sair do sistema?</p>
            <p className="text-muted small">
              Ao sair, você será redirecionado para a página de login.
            </p>
          </div>
        </Modal.Body>
        <Modal.Footer>
          <button
            className="btn-cancel"
            onClick={() => setShowLogoutModal(false)}
          >
            Cancelar
          </button>
          <button
            className="btn-logout-confirm"
            onClick={handleLogout}
          >
            <FaSignOutAlt />
            Sim, Sair
          </button>
        </Modal.Footer>
      </Modal>
    </div >
  );
};

export default MenuAside;