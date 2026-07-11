import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Form, Button, Alert } from 'react-bootstrap';
import { 
  FaEnvelope, 
  FaLock, 
  FaEye, 
  FaEyeSlash, 
  FaShieldAlt, 
  FaArrowRight, 
  FaUserCircle,
  FaBuilding,
  FaUsers,
  FaBullhorn,
  FaMapMarkerAlt,
  FaChartLine
} from 'react-icons/fa';
import { motion } from 'framer-motion';
import toast from 'react-hot-toast';
import './Login.css';

const Login = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    if (!email || !password) {
      toast.error('Preencha todos os campos');
      return;
    }

    setLoading(true);

    // Simular login - substituir com chamada real
    if (email === 'admin@anunciosloc.com' && password === 'admin123') {
      toast.success('Login realizado com sucesso!');
      setTimeout(() => {
        onLogin(email);
      }, 500);
    } else {
      setError('Credenciais inválidas');
      toast.error('Credenciais inválidas');
      setLoading(false);
    }
  };

  // Animações
  const containerVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: { 
      opacity: 1, 
      y: 0,
      transition: { duration: 0.8, ease: "easeOut" }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, x: -20 },
    visible: { 
      opacity: 1, 
      x: 0,
      transition: { duration: 0.4, delay: 0.1 }
    }
  };

  const heroVariants = {
    hidden: { opacity: 0, x: -50 },
    visible: { 
      opacity: 1, 
      x: 0,
      transition: { duration: 1, ease: "easeOut" }
    }
  };

  const features = [
    { icon: <FaUsers />, label: 'Utilizadores', value: '150+' },
    { icon: <FaBullhorn />, label: 'Anúncios', value: '320' },
    { icon: <FaMapMarkerAlt />, label: 'Locais', value: '12' },
    { icon: <FaChartLine />, label: 'Entregas', value: '1.2k' },
  ];

  return (
    <div className="login-page">
      {/* Overlay animado */}
      <div className="login-overlay">
        <div className="floating-shapes">
          <div className="shape shape-1"></div>
          <div className="shape shape-2"></div>
          <div className="shape shape-3"></div>
          <div className="shape shape-4"></div>
        </div>
      </div>

      <Container fluid className="login-container">
        <Row className="min-vh-100 align-items-center">
          {/* HERO - Lado Esquerdo */}
          <Col lg={6} className="d-none d-lg-block login-hero">
            <motion.div
              variants={heroVariants}
              initial="hidden"
              animate="visible"
              className="hero-content"
            >
              <div className="hero-badge">
                <FaShieldAlt className="hero-icon" />
                <span>Painel Administrativo v2.0</span>
              </div>
              
              <h1 className="hero-title">
                Gestão <br />
                <span className="hero-highlight">AnunciosLoc</span>
              </h1>
              
              <p className="hero-text">
                Controla todos os anúncios, utilizadores e locais da plataforma num só lugar, com total segurança e eficiência.
              </p>

              <div className="hero-features">
                <div className="hero-feature">
                  <span className="feature-dot"></span>
                  Gestão completa de utilizadores
                </div>
                <div className="hero-feature">
                  <span className="feature-dot"></span>
                  Moderação inteligente de anúncios
                </div>
                <div className="hero-feature">
                  <span className="feature-dot"></span>
                  Estatísticas em tempo real
                </div>
                <div className="hero-feature">
                  <span className="feature-dot"></span>
                  Relatórios personalizados
                </div>
              </div>

              <div className="hero-stats">
                {features.map((feature, index) => (
                  <React.Fragment key={index}>
                    <div className="stat-item">
                      <span className="stat-number">{feature.value}</span>
                      <span className="stat-label">
                        {feature.icon} {feature.label}
                      </span>
                    </div>
                    {index < features.length - 1 && <div className="stat-divider"></div>}
                  </React.Fragment>
                ))}
              </div>

              <div className="hero-trust">
                <div className="trust-item">
                  <span className="trust-dot"></span>
                  SSL Seguro
                </div>
                <div className="trust-item">
                  <span className="trust-dot"></span>
                  Dados Encriptados
                </div>
                <div className="trust-item">
                  <span className="trust-dot"></span>
                  Autenticação 2FA
                </div>
              </div>
            </motion.div>
          </Col>

          {/* FORMULÁRIO - Lado Direito */}
          <Col lg={6} className="login-form-col">
            <motion.div
              initial="hidden"
              animate={isVisible ? "visible" : "hidden"}
              variants={containerVariants}
              className="login-card-wrapper"
            >
              <div className="login-card">
                {/* Logo e título */}
                <motion.div variants={itemVariants} className="login-header">
                  <div className="login-logo">
                    <span className="logo-icon">📍</span>
                    <span className="logo-text">
                      <span className="logo-highlight">Anuncios</span>Loc
                    </span>
                  </div>
                  <h2 className="login-welcome">Bem-vindo de volta</h2>
                  <p className="login-subtitle">Acesse o painel administrativo</p>
                </motion.div>

                {error && (
                  <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                  >
                    <Alert variant="danger" className="login-alert">
                      <FaShieldAlt className="alert-icon" />
                      {error}
                    </Alert>
                  </motion.div>
                )}

                <Form onSubmit={handleSubmit} className="login-form">
                  <motion.div variants={itemVariants}>
                    <Form.Group className="form-group-custom">
                      <Form.Label className="form-label-custom">
                        <FaEnvelope className="label-icon" />
                        Email
                      </Form.Label>
                      <div className="input-wrapper">
                        <FaEnvelope className="input-icon-left" />
                        <Form.Control
                          type="email"
                          placeholder="admin@anunciosloc.com"
                          value={email}
                          onChange={(e) => setEmail(e.target.value)}
                          className="input-custom"
                          disabled={loading}
                        />
                        <div className="input-glow"></div>
                      </div>
                    </Form.Group>
                  </motion.div>

                  <motion.div variants={itemVariants}>
                    <Form.Group className="form-group-custom">
                      <Form.Label className="form-label-custom">
                        <FaLock className="label-icon" />
                        Password
                      </Form.Label>
                      <div className="input-wrapper">
                        <FaLock className="input-icon-left" />
                        <Form.Control
                          type={showPassword ? 'text' : 'password'}
                          placeholder="••••••••"
                          value={password}
                          onChange={(e) => setPassword(e.target.value)}
                          className="input-custom"
                          disabled={loading}
                        />
                        <button
                          type="button"
                          className="password-toggle-btn"
                          onClick={() => setShowPassword(!showPassword)}
                        >
                          {showPassword ? <FaEyeSlash /> : <FaEye />}
                        </button>
                        <div className="input-glow"></div>
                      </div>
                    </Form.Group>
                  </motion.div>

                  <motion.div variants={itemVariants}>
                    <div className="form-options">
                      <div className="remember-me">
                        <input type="checkbox" id="remember" />
                        <label htmlFor="remember">Lembrar-me</label>
                      </div>
                      <a href="#" className="forgot-password">
                        Esqueceu a password?
                      </a>
                    </div>
                  </motion.div>

                  <motion.div variants={itemVariants}>
                    <Button
                      variant="primary"
                      type="submit"
                      className={`login-btn ${loading ? 'loading' : ''}`}
                      disabled={loading}
                    >
                      {loading ? (
                        <>
                          <span className="spinner-border spinner-border-sm me-2" />
                          A entrar...
                        </>
                      ) : (
                        <>
                          Entrar
                          <FaArrowRight className="btn-icon" />
                        </>
                      )}
                    </Button>
                  </motion.div>
                </Form>

                <motion.div variants={itemVariants} className="login-footer">
                  <p className="footer-text">
                    <FaUserCircle className="footer-icon" />
                    Credenciais de teste:
                    <span className="credential"> admin@anunciosloc.com</span>
                    <span className="credential-sep">/</span>
                    <span className="credential">admin123</span>
                  </p>
                </motion.div>

                <motion.div 
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 1.2 }}
                  className="security-badge"
                >
                  <FaShieldAlt />
                  <span>Conexão segura</span>
                  <span className="security-sep">•</span>
                  <span>SSL 256-bit</span>
                </motion.div>
              </div>
            </motion.div>
          </Col>
        </Row>
      </Container>
    </div>
  );
};

export default Login;