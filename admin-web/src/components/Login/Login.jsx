import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Form, Button, Alert, Modal } from 'react-bootstrap';
import {
  FaEnvelope, FaLock, FaEye, FaEyeSlash, FaShieldAlt,
  FaArrowRight, FaUserCircle, FaKey, FaCheckCircle,
  FaTimesCircle, FaSpinner, FaArrowLeft, FaPaperPlane,  // ← CORRIGIDO
  FaInfoCircle, FaLockOpen
} from 'react-icons/fa';
import { motion, AnimatePresence } from 'framer-motion';
import toast from 'react-hot-toast';
import './Login.css';

const Login = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [isVisible, setIsVisible] = useState(false);

  // ==================== RECUPERAÇÃO DE SENHA ====================
  const [showForgotPassword, setShowForgotPassword] = useState(false);
  const [resetEmail, setResetEmail] = useState('');
  const [resetStep, setResetStep] = useState(1); // 1 = enviar email, 2 = codigo, 3 = nova senha
  const [resetCode, setResetCode] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [resetLoading, setResetLoading] = useState(false);
  const [resetError, setResetError] = useState('');
  const [resetSuccess, setResetSuccess] = useState(false);
  const [resendTimer, setResendTimer] = useState(0);
  const [securityQuestion, setSecurityQuestion] = useState('');
  const [securityAnswer, setSecurityAnswer] = useState('');

  useEffect(() => {
    setIsVisible(true);
  }, []);

  // Timer para reenviar código
  useEffect(() => {
    let timer;
    if (resendTimer > 0) {
      timer = setInterval(() => {
        setResendTimer(prev => prev - 1);
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [resendTimer]);

  // ==================== HANDLERS ====================

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

  // ==================== RECUPERAÇÃO DE SENHA ====================

  const handleForgotPassword = () => {
    setShowForgotPassword(true);
    setResetStep(1);
    setResetEmail(email || '');
    setResetError('');
    setResetSuccess(false);
  };

  const handleSendResetCode = async (e) => {
    e.preventDefault();
    setResetError('');
    
    if (!resetEmail) {
      setResetError('Digite seu email');
      return;
    }

    setResetLoading(true);

    // Simular envio de código
    setTimeout(() => {
      toast.success('Código enviado para ' + resetEmail);
      setResetStep(2);
      setResetLoading(false);
      setResendTimer(60);
    }, 1500);
  };

  const handleVerifyCode = async (e) => {
    e.preventDefault();
    setResetError('');

    if (!resetCode || resetCode.length < 6) {
      setResetError('Digite o código de 6 dígitos');
      return;
    }

    setResetLoading(true);

    // Simular verificação do código
    setTimeout(() => {
      if (resetCode === '123456') {
        toast.success('Código verificado!');
        setResetStep(3);
        setResetLoading(false);
      } else {
        setResetError('Código inválido');
        setResetLoading(false);
      }
    }, 1000);
  };

  const handleResetPassword = async (e) => {
    e.preventDefault();
    setResetError('');

    if (newPassword.length < 6) {
      setResetError('A nova password deve ter no mínimo 6 caracteres');
      return;
    }

    if (newPassword !== confirmPassword) {
      setResetError('As passwords não coincidem');
      return;
    }

    setResetLoading(true);

    // Simular alteração de password
    setTimeout(() => {
      setResetSuccess(true);
      setResetLoading(false);
      toast.success('Password alterada com sucesso!');

      setTimeout(() => {
        setShowForgotPassword(false);
        setResetStep(1);
        setResetEmail('');
        setResetCode('');
        setNewPassword('');
        setConfirmPassword('');
        setResetSuccess(false);
        setSecurityQuestion('');
        setSecurityAnswer('');
      }, 2000);
    }, 1500);
  };

  const handleResendCode = () => {
    if (resendTimer > 0) return;
    setResendTimer(60);
    toast.success('Novo código enviado!');
  };

  const handleBackToLogin = () => {
    setShowForgotPassword(false);
    setResetStep(1);
    setResetEmail('');
    setResetCode('');
    setNewPassword('');
    setConfirmPassword('');
    setResetError('');
    setResetSuccess(false);
  };

  // ==================== ANIMAÇÕES ====================

  const containerVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.8, ease: 'easeOut' }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, x: -20 },
    visible: {
      opacity: 1,
      x: 0,
      transition: { duration: 0.4 }
    }
  };

  // ==================== RENDERIZAR PASSOS ====================

  const renderResetStep = () => {
    switch (resetStep) {
      case 1:
        return (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
          >
            <div className="reset-header">
              <div className="reset-icon-wrapper">
                <FaKey className="reset-icon" />
              </div>
              <h4 className="reset-title">Recuperar Password</h4>
              <p className="reset-subtitle">
                Digite seu email para receber um código de recuperação
              </p>
            </div>

            {resetError && (
              <Alert variant="danger" className="reset-alert">
                <FaTimesCircle className="alert-icon" />
                {resetError}
              </Alert>
            )}

            <Form onSubmit={handleSendResetCode}>
              <Form.Group className="mb-3">
                <Form.Label>
                  <FaEnvelope className="label-icon" />
                  Email
                </Form.Label>
                <div className="input-wrapper">
                  <FaEnvelope className="input-icon-left" />
                  <Form.Control
                    type="email"
                    placeholder="seu@email.com"
                    value={resetEmail}
                    onChange={(e) => setResetEmail(e.target.value)}
                    className="input-custom"
                    disabled={resetLoading}
                    autoFocus
                  />
                </div>
              </Form.Group>

              <div className="reset-hint">
                <FaInfoCircle className="hint-icon" />
                <span>Enviaremos um código de 6 dígitos para seu email</span>
              </div>

              <Button
                type="submit"
                className="reset-btn"
                disabled={resetLoading}
              >
                {resetLoading ? (
                  <>
                    <FaSpinner className="spinner-icon" />
                    Enviando...
                  </>
                ) : (
                  <>
                    <FaPaperPlane />
                    Enviar Código
                  </>
                )}
              </Button>
            </Form>
          </motion.div>
        );

      case 2:
        return (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
          >
            <div className="reset-header">
              <div className="reset-icon-wrapper">
                <FaShieldAlt className="reset-icon" />
              </div>
              <h4 className="reset-title">Verificar Código</h4>
              <p className="reset-subtitle">
                Digite o código de 6 dígitos enviado para <strong>{resetEmail}</strong>
              </p>
            </div>

            {resetError && (
              <Alert variant="danger" className="reset-alert">
                <FaTimesCircle className="alert-icon" />
                {resetError}
              </Alert>
            )}

            <Form onSubmit={handleVerifyCode}>
              <Form.Group className="mb-3">
                <Form.Label>
                  <FaShieldAlt className="label-icon" />
                  Código de Verificação
                </Form.Label>
                <div className="input-wrapper">
                  <Form.Control
                    type="text"
                    placeholder="Digite o código de 6 dígitos"
                    value={resetCode}
                    onChange={(e) => setResetCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                    className="input-custom code-input"
                    disabled={resetLoading}
                    maxLength={6}
                    autoFocus
                  />
                </div>
                <div className="code-hint">
                  <span>Código: <strong>123456</strong> (para teste)</span>
                </div>
              </Form.Group>

              <div className="reset-actions">
                <Button
                  type="button"
                  variant="link"
                  className="resend-btn"
                  onClick={handleResendCode}
                  disabled={resendTimer > 0}
                >
                  {resendTimer > 0 ? `Reenviar em ${resendTimer}s` : 'Reenviar código'}
                </Button>
              </div>

              <Button
                type="submit"
                className="reset-btn"
                disabled={resetLoading}
              >
                {resetLoading ? (
                  <>
                    <FaSpinner className="spinner-icon" />
                    Verificando...
                  </>
                ) : (
                  <>
                    <FaCheckCircle />
                    Verificar Código
                  </>
                )}
              </Button>
            </Form>
          </motion.div>
        );

      case 3:
        return (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
          >
            <div className="reset-header">
              <div className="reset-icon-wrapper success">
                <FaLockOpen className="reset-icon" />
              </div>
              <h4 className="reset-title">Nova Password</h4>
              <p className="reset-subtitle">
                Crie uma nova password para sua conta
              </p>
            </div>

            {resetError && (
              <Alert variant="danger" className="reset-alert">
                <FaTimesCircle className="alert-icon" />
                {resetError}
              </Alert>
            )}

            {resetSuccess && (
              <Alert variant="success" className="reset-success">
                <FaCheckCircle className="alert-icon" />
                Password alterada com sucesso!
              </Alert>
            )}

            <Form onSubmit={handleResetPassword}>
              <Form.Group className="mb-3">
                <Form.Label>
                  <FaLock className="label-icon" />
                  Nova Password
                </Form.Label>
                <div className="input-wrapper">
                  <FaLock className="input-icon-left" />
                  <Form.Control
                    type={showNewPassword ? 'text' : 'password'}
                    placeholder="Mínimo 6 caracteres"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    className="input-custom"
                    disabled={resetLoading || resetSuccess}
                  />
                  <button
                    type="button"
                    className="password-toggle-btn"
                    onClick={() => setShowNewPassword(!showNewPassword)}
                  >
                    {showNewPassword ? <FaEyeSlash /> : <FaEye />}
                  </button>
                </div>
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>
                  <FaLock className="label-icon" />
                  Confirmar Password
                </Form.Label>
                <div className="input-wrapper">
                  <FaLock className="input-icon-left" />
                  <Form.Control
                    type={showConfirmPassword ? 'text' : 'password'}
                    placeholder="Confirme sua nova password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className="input-custom"
                    disabled={resetLoading || resetSuccess}
                  />
                  <button
                    type="button"
                    className="password-toggle-btn"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  >
                    {showConfirmPassword ? <FaEyeSlash /> : <FaEye />}
                  </button>
                </div>
              </Form.Group>

              <div className="password-requirements">
                <span className="requirement-title">Requisitos:</span>
                <ul>
                  <li className={newPassword.length >= 6 ? 'met' : ''}>
                    • Mínimo 6 caracteres
                  </li>
                  <li className={/[A-Z]/.test(newPassword) ? 'met' : ''}>
                    • Pelo menos 1 letra maiúscula
                  </li>
                  <li className={/[0-9]/.test(newPassword) ? 'met' : ''}>
                    • Pelo menos 1 número
                  </li>
                </ul>
              </div>

              <Button
                type="submit"
                className="reset-btn"
                disabled={resetLoading || resetSuccess}
              >
                {resetLoading ? (
                  <>
                    <FaSpinner className="spinner-icon" />
                    Alterando...
                  </>
                ) : resetSuccess ? (
                  <>
                    <FaCheckCircle />
                    Concluído!
                  </>
                ) : (
                  <>
                    <FaLock />
                    Alterar Password
                  </>
                )}
              </Button>
            </Form>
          </motion.div>
        );

      default:
        return null;
    }
  };

  // ==================== RENDER PRINCIPAL ====================

  return (
    <div className="login-page">
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
          {/* Hero Section */}
          <Col lg={6} className="d-none d-lg-block login-hero">
            <motion.div
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 1 }}
              className="hero-content"
            >
              <div className="hero-badge">
                <FaShieldAlt className="hero-icon" />
                <span>Admin Panel v2.0</span>
              </div>
              <h1 className="hero-title">
                Gestão <span className="hero-highlight">AnunciosLoc</span>
              </h1>
              <p className="hero-text">
                Controla todos os anúncios, utilizadores e locais da plataforma num só lugar.
              </p>
              <div className="hero-features">
                <div className="hero-feature">
                  <span className="feature-dot"></span>
                  Gestão de utilizadores
                </div>
                <div className="hero-feature">
                  <span className="feature-dot"></span>
                  Moderação de anúncios
                </div>
                <div className="hero-feature">
                  <span className="feature-dot"></span>
                  Estatísticas em tempo real
                </div>
              </div>
              <div className="hero-stats">
                <div className="stat-item">
                  <span className="stat-number">150+</span>
                  <span className="stat-label">Utilizadores</span>
                </div>
                <div className="stat-divider"></div>
                <div className="stat-item">
                  <span className="stat-number">320</span>
                  <span className="stat-label">Anúncios</span>
                </div>
                <div className="stat-divider"></div>
                <div className="stat-item">
                  <span className="stat-number">12</span>
                  <span className="stat-label">Locais</span>
                </div>
              </div>
            </motion.div>
          </Col>

          {/* Formulário de Login */}
          {!showForgotPassword ? (
            <Col lg={6} className="login-form-col">
              <motion.div
                initial="hidden"
                animate={isVisible ? 'visible' : 'hidden'}
                variants={containerVariants}
                className="login-card-wrapper"
              >
                <div className="login-card">
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
                        </div>
                      </Form.Group>
                    </motion.div>

                    <motion.div variants={itemVariants}>
                      <div className="form-options">
                        <div className="remember-me">
                          <input type="checkbox" id="remember" />
                          <label htmlFor="remember">Lembrar-me</label>
                        </div>
                        <button
                          type="button"
                          className="forgot-password-btn"
                          onClick={handleForgotPassword}
                        >
                          Esqueceu a password?
                        </button>
                      </div>
                    </motion.div>

                    <motion.div variants={itemVariants}>
                      <Button
                        type="submit"
                        className="login-btn"
                        disabled={loading}
                      >
                        {loading ? (
                          <>
                            <FaSpinner className="spinner-icon" />
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
                  </motion.div>
                </div>
              </motion.div>
            </Col>
          ) : (
            /* ==================== RECUPERAÇÃO DE SENHA ==================== */
            <Col lg={6} className="login-form-col">
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="login-card-wrapper"
              >
                <div className="login-card reset-card">
                  <button
                    className="back-to-login"
                    onClick={handleBackToLogin}
                    title="Voltar ao login"
                  >
                    <FaArrowLeft />
                  </button>

                  <AnimatePresence mode="wait">
                    {renderResetStep()}
                  </AnimatePresence>

                  <div className="reset-footer">
                    <button
                      className="back-to-login-link"
                      onClick={handleBackToLogin}
                    >
                      <FaArrowLeft />
                      Voltar ao login
                    </button>
                  </div>
                </div>
              </motion.div>
            </Col>
          )}
        </Row>
      </Container>
    </div>
  );
};

export default Login;