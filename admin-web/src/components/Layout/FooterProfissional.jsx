import React from 'react';
import { 
  FaHeart, 
  FaArrowUp,
  FaShieldAlt,
  FaLock,
  FaUsers,
  FaBullhorn,
  FaMapMarkerAlt,
  FaCoins,
  FaServer,
  FaWifi,
  FaRoute,
  FaUserShield
} from 'react-icons/fa';
import './FooterProfissional.css';

const FooterDashboard = () => {
  const year = new Date().getFullYear();

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <footer className="footer-dashboard">
      <div className="footer-container">
        {/* Grid Principal */}
        <div className="footer-grid">
          {/* Coluna 1 - Logo e Sobre */}
          <div className="footer-col">
            <div className="footer-logo">
              <span className="logo-emoji">📍</span>
              <span className="logo-text">
                <span className="logo-highlight">Anuncios</span>Loc
              </span>
            </div>
            <p className="footer-description">
              Sistema distribuído de anúncios baseados em localização para centros urbanos.
              Permite publicar e receber mensagens contextualizadas por geolocalização.
            </p>
            <div className="footer-badges">
              <span className="badge-version">v2.0.0</span>
              <span className="badge-status">
                <span className="status-dot"></span>
                Online
              </span>
            </div>
          </div>

          {/* Coluna 2 - Entidades do Sistema */}
          <div className="footer-col">
            <h4 className="footer-title"> Entidades do Sistema</h4>
            <ul className="footer-entities">
              <li>
                <FaUsers className="entity-icon" />
                <div>
                  <strong>Utilizadores</strong>
                  <span>Geridos com autenticação Kerberos</span>
                </div>
              </li>
              <li>
                <FaBullhorn className="entity-icon" />
                <div>
                  <strong>Anúncios</strong>
                  <span>Publicados por localização geográfica</span>
                </div>
              </li>
              <li>
                <FaMapMarkerAlt className="entity-icon" />
                <div>
                  <strong>Locais</strong>
                  <span>Infraestruturas com coordenadas GPS/WiFi</span>
                </div>
              </li>
              <li>
                <FaCoins className="entity-icon" />
                <div>
                  <strong>Saldo</strong>
                  <span>Pontos por publicar/receber anúncios</span>
                </div>
              </li>
            </ul>
          </div>

          {/* Coluna 3 - Modos de Entrega */}
          <div className="footer-col">
            <h4 className="footer-title">Modos de Entrega</h4>
            <ul className="footer-modes">
              <li>
                <FaServer className="mode-icon" style={{ color: '#6366F1' }} />
                <div>
                  <strong>Centralizado</strong>
                  <span>Via servidor SOAP com persistência</span>
                </div>
              </li>
              <li>
                <FaWifi className="mode-icon" style={{ color: '#22C55E' }} />
                <div>
                  <strong>Descentralizado</strong>
                  <span>WiFi Direct entre dispositivos</span>
                </div>
              </li>
              <li>
                <FaRoute className="mode-icon" style={{ color: '#F59E0B' }} />
                <div>
                  <strong>Modo MULA</strong>
                  <span>Roteamento store-and-forward</span>
                </div>
              </li>
              <li>
                <FaUserShield className="mode-icon" style={{ color: '#EC4899' }} />
                <div>
                  <strong>Segurança</strong>
                  <span>Autenticação Kerberos</span>
                </div>
              </li>
            </ul>
          </div>

          {/* Coluna 4 - Links Úteis */}
          <div className="footer-col">
            <h4 className="footer-title">Links Úteis</h4>
            <ul className="footer-links">
              <li><a href="#">Dashboard</a></li>
              <li><a href="#">Utilizadores</a></li>
              <li><a href="#">Anúncios</a></li>
              <li><a href="#">Locais</a></li>
              <li><a href="#">Assistência interativa</a></li>
            </ul>
          </div>
        </div>

        {/* Divider */}
        <div className="footer-divider"></div>

        {/* Footer Bottom */}
        <div className="footer-bottom">
          <div className="footer-bottom-left">
            <p>
              &copy; {year} <span className="footer-highlight">AnunciosLoc</span>.
              Todos os direitos reservados.
            </p>
            <div className="footer-bottom-links">
              <a href="#">Termos de Uso</a>
              <span className="footer-dot">•</span>
              <a href="#">Privacidade</a>
              <span className="footer-dot">•</span>
              <a href="#">Segurança</a>
            </div>
          </div>
          <div className="footer-bottom-right">
            <div className="footer-security-badge">
              <FaLock className="security-icon" />
              <span>Conexão Segura</span>
              <FaShieldAlt className="shield-icon" />
            </div>
            <p className="footer-credit">
              Feito com <FaHeart className="footer-heart" /> pela equipa AnunciosLoc
            </p>
            <button className="footer-back-top" onClick={scrollToTop} title="Voltar ao topo">
              <FaArrowUp />
              <span>Topo</span>
            </button>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default FooterDashboard;