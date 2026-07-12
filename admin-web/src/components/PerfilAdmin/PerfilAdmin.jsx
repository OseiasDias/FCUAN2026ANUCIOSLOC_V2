import React, { useState, useRef } from 'react';
import {
  Container, Row, Col, Card, Form, Button, Badge,
  Alert, Tab, Nav, Spinner, InputGroup, Modal,
  Tabs
} from 'react-bootstrap';
import {
  FaUserCircle, FaEnvelope, FaLock, FaSave,
  FaCamera, FaUser, FaEdit, FaCheckCircle,
  FaTimesCircle, FaKey, FaIdCard, FaCalendarAlt,
  FaShieldAlt, FaHistory, FaBell, FaGlobe,
  FaPhone, FaMapMarkerAlt, FaBuilding, FaUsers,
  FaBullhorn, FaChartLine, FaCrown, FaStar,
  FaEye, FaEyeSlash, FaTrash, FaInfoCircle
} from 'react-icons/fa';
import { motion, AnimatePresence } from 'framer-motion';
import toast from 'react-hot-toast';
import './PerfilAdmin.css';

const PerfilAdmin = () => {
  const [loading, setLoading] = useState(false);
  const [editando, setEditando] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  // Dados do perfil
  const [perfil, setPerfil] = useState({
    nome: 'Administrador',
    email: 'admin@anunciosloc.com',
    role: 'Super Administrador',
    telefone: '+244 923 456 789',
    localizacao: 'Luanda, Angola',
    empresa: 'AnunciosLoc',
    bio: 'Administrador da plataforma AnunciosLoc, responsável pela gestão de utilizadores, anúncios e infraestruturas.',
    avatar: null,
    dataRegisto: '2026-01-01',
    ultimoAcesso: '2026-07-12 14:30'
  });

  // Estatísticas do admin
  const stats = {
    totalUtilizadores: 142,
    totalAnuncios: 384,
    totalLocais: 12,
    totalEntregas: 892,
    totalInteracoes: 2456,
    avaliacao: 4.8
  };

  // Histórico de atividades
  const historico = [
    { id: 1, acao: 'Publicou um anúncio', data: '2026-07-12 14:30', tipo: 'success' },
    { id: 2, acao: 'Desativou utilizador joao@email.com', data: '2026-07-12 10:15', tipo: 'warning' },
    { id: 3, acao: 'Criou novo local: Zango 0', data: '2026-07-11 16:45', tipo: 'info' },
    { id: 4, acao: 'Removeu anúncio spam', data: '2026-07-11 09:00', tipo: 'danger' },
    { id: 5, acao: 'Ativou utilizador maria@email.com', data: '2026-07-10 22:30', tipo: 'success' },
  ];

  // Notificações
  const notificacoes = [
    { id: 1, texto: 'Novo utilizador registado', data: '5 min atrás', lido: false },
    { id: 2, texto: 'Anúncio reportado como spam', data: '15 min atrás', lido: false },
    { id: 3, texto: 'Sistema atualizado para v2.0', data: '1 hora atrás', lido: true },
  ];

  const [senhaAtual, setSenhaAtual] = useState('');
  const [novaSenha, setNovaSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');
  const [erros, setErros] = useState({});
  const [tabAtiva, setTabAtiva] = useState('perfil');

  const fileInputRef = useRef(null);

  // ==================== HANDLERS ====================

  const handleEditar = () => {
    setEditando(!editando);
    if (editando) {
      toast.success('Perfil atualizado com sucesso!');
    }
  };

  const handleAvatarClick = () => {
    fileInputRef.current?.click();
  };

  const handleAvatarChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        setPerfil({ ...perfil, avatar: event.target.result });
        toast.success('Foto atualizada com sucesso!');
      };
      reader.readAsDataURL(file);
    }
  };

  const handleAlterarSenha = (e) => {
    e.preventDefault();
    const errors = {};

    if (!senhaAtual) errors.senhaAtual = 'Password atual é obrigatória';
    if (novaSenha.length < 6) errors.novaSenha = 'A nova password deve ter no mínimo 6 caracteres';
    if (novaSenha !== confirmarSenha) errors.confirmarSenha = 'As passwords não coincidem';

    if (Object.keys(errors).length > 0) {
      setErros(errors);
      return;
    }

    setLoading(true);
    setTimeout(() => {
      toast.success('Password alterada com sucesso!');
      setShowPasswordModal(false);
      setSenhaAtual('');
      setNovaSenha('');
      setConfirmarSenha('');
      setErros({});
      setLoading(false);
    }, 1000);
  };

  const handleDeleteAccount = () => {
    toast.success('Conta eliminada com sucesso! (Simulação)');
    setShowDeleteModal(false);
  };

  const marcarComoLido = (id) => {
    toast.success('Notificação marcada como lida');
  };

  // ==================== RENDER ====================

  const getTipoIcon = (tipo) => {
    const icons = {
      success: <FaCheckCircle className="historico-icon-success" />,
      warning: <FaTimesCircle className="historico-icon-warning" />,
      danger: <FaTrash className="historico-icon-danger" />,
      info: <FaInfoCircle className="historico-icon-info" />
    };
    return icons[tipo] || icons.info;
  };

  if (loading) {
    return (
      <div className="perfil-loading">
        <div className="loading-spinner"></div>
        <span>Carregando perfil...</span>
      </div>
    );
  }

  return (
    <div className="perfil-admin-container">
      <Container fluid>
        {/* Cabeçalho */}
        <div className="perfil-header">
          <div>
            <h2 className="perfil-title">
              <FaUserCircle className="perfil-icon" />
              Meu Perfil
            </h2>
            <p className="perfil-subtitle">Gerir as suas informações e preferências</p>
          </div>
          <div className="perfil-actions">
            <Button
              variant={editando ? 'success' : 'primary'}
              onClick={handleEditar}
              className="btn-edit-profile"
            >
              {editando ? (
                <>
                  <FaSave className="me-2" />
                  Salvar
                </>
              ) : (
                <>
                  <FaEdit className="me-2" />
                  Editar Perfil
                </>
              )}
            </Button>
          </div>
        </div>

        <Row className="g-4">
          {/* Coluna Esquerda - Perfil */}
          <Col lg={4}>
            <Card className="perfil-card profile-card">
              <Card.Body>
                {/* Avatar */}
                <div className="profile-avatar-container">
                  <div className="profile-avatar" onClick={handleAvatarClick}>
                    {perfil.avatar ? (
                      <img src={perfil.avatar} alt="Avatar" />
                    ) : (
                      <FaUserCircle className="avatar-icon" />
                    )}
                    <div className="avatar-overlay">
                      <FaCamera />
                      <span>Alterar</span>
                    </div>
                  </div>
                  <input
                    type="file"
                    ref={fileInputRef}
                    onChange={handleAvatarChange}
                    accept="image/*"
                    style={{ display: 'none' }}
                  />
                </div>

                {/* Informações */}
                <div className="profile-info">
                  <h4 className="profile-name">{perfil.nome}</h4>
                  <div className="profile-role">
                    <FaCrown className="role-icon" />
                    {perfil.role}
                  </div>
                  <Badge className="profile-badge">
                    <FaShieldAlt className="badge-icon" />
                    Verificado
                  </Badge>
                </div>

                {/* Stats do Admin */}
                <div className="profile-stats">
                  <div className="stat-item">
                    <span className="stat-number">{stats.totalUtilizadores}</span>
                    <span className="stat-label">
                      <FaUsers />
                      Utilizadores
                    </span>
                  </div>
                  <div className="stat-divider"></div>
                  <div className="stat-item">
                    <span className="stat-number">{stats.totalAnuncios}</span>
                    <span className="stat-label">
                      <FaBullhorn />
                      Anúncios
                    </span>
                  </div>
                  <div className="stat-divider"></div>
                  <div className="stat-item">
                    <span className="stat-number">{stats.totalLocais}</span>
                    <span className="stat-label">
                      <FaMapMarkerAlt />
                      Locais
                    </span>
                  </div>
                </div>

                {/* Avaliação */}
                <div className="profile-rating">
                  <FaStar className="star-icon" />
                  <FaStar className="star-icon" />
                  <FaStar className="star-icon" />
                  <FaStar className="star-icon" />
                  <FaStar className="star-icon-half" />
                  <span className="rating-value">{stats.avaliacao}</span>
                  <span className="rating-label">Avaliação</span>
                </div>

                {/* Detalhes */}
                <div className="profile-details">
                  <div className="detail-item">
                    <FaEnvelope className="detail-icon" />
                    <div>
                      <span className="detail-label">Email</span>
                      <span className="detail-value">{perfil.email}</span>
                    </div>
                  </div>
                  <div className="detail-item">
                    <FaPhone className="detail-icon" />
                    <div>
                      <span className="detail-label">Telefone</span>
                      <span className="detail-value">{perfil.telefone}</span>
                    </div>
                  </div>
                  <div className="detail-item">
                    <FaMapMarkerAlt className="detail-icon" />
                    <div>
                      <span className="detail-label">Localização</span>
                      <span className="detail-value">{perfil.localizacao}</span>
                    </div>
                  </div>
                  <div className="detail-item">
                    <FaBuilding className="detail-icon" />
                    <div>
                      <span className="detail-label">Empresa</span>
                      <span className="detail-value">{perfil.empresa}</span>
                    </div>
                  </div>
                  <div className="detail-item">
                    <FaCalendarAlt className="detail-icon" />
                    <div>
                      <span className="detail-label">Registo</span>
                      <span className="detail-value">{perfil.dataRegisto}</span>
                    </div>
                  </div>
                  <div className="detail-item">
                    <FaHistory className="detail-icon" />
                    <div>
                      <span className="detail-label">Último Acesso</span>
                      <span className="detail-value">{perfil.ultimoAcesso}</span>
                    </div>
                  </div>
                </div>

                {/* Botões de ação */}
                <div className="profile-actions">
                  <Button
                    variant="outline-primary"
                    className="action-btn"
                    onClick={() => setShowPasswordModal(true)}
                  >
                    <FaKey className="me-2" />
                    Alterar Password
                  </Button>
                  <Button
                    variant="outline-danger"
                    className="action-btn"
                    onClick={() => setShowDeleteModal(true)}
                  >
                    <FaTrash className="me-2" />
                    Eliminar Conta
                  </Button>
                </div>
              </Card.Body>
            </Card>
          </Col>

          {/* Coluna Direita - Tabs */}
          <Col lg={8}>
            <Card className="perfil-card tabs-card">
              <Card.Body>
                <Tabs
                  activeKey={tabAtiva}
                  onSelect={(k) => setTabAtiva(k)}
                  className="perfil-tabs"
                >
                  {/* Tab: Editar Perfil */}
                  <Tab eventKey="perfil" title={
                    <span><FaUser className="me-2" />Editar Perfil</span>
                  }>
                    <div className="tab-content">
                      <Form>
                        <Row>
                          <Col md={6}>
                            <Form.Group className="mb-3">
                              <Form.Label>Nome Completo</Form.Label>
                              <Form.Control
                                type="text"
                                value={perfil.nome}
                                onChange={(e) => setPerfil({...perfil, nome: e.target.value})}
                                disabled={!editando}
                                className={editando ? 'editable' : ''}
                              />
                            </Form.Group>
                          </Col>
                          <Col md={6}>
                            <Form.Group className="mb-3">
                              <Form.Label>Email</Form.Label>
                              <Form.Control
                                type="email"
                                value={perfil.email}
                                disabled
                                className="disabled-field"
                              />
                            </Form.Group>
                          </Col>
                        </Row>

                        <Row>
                          <Col md={6}>
                            <Form.Group className="mb-3">
                              <Form.Label>Telefone</Form.Label>
                              <Form.Control
                                type="text"
                                value={perfil.telefone}
                                onChange={(e) => setPerfil({...perfil, telefone: e.target.value})}
                                disabled={!editando}
                                className={editando ? 'editable' : ''}
                              />
                            </Form.Group>
                          </Col>
                          <Col md={6}>
                            <Form.Group className="mb-3">
                              <Form.Label>Localização</Form.Label>
                              <Form.Control
                                type="text"
                                value={perfil.localizacao}
                                onChange={(e) => setPerfil({...perfil, localizacao: e.target.value})}
                                disabled={!editando}
                                className={editando ? 'editable' : ''}
                              />
                            </Form.Group>
                          </Col>
                        </Row>

                        <Form.Group className="mb-3">
                          <Form.Label>Biografia</Form.Label>
                          <Form.Control
                            as="textarea"
                            rows={4}
                            value={perfil.bio}
                            onChange={(e) => setPerfil({...perfil, bio: e.target.value})}
                            disabled={!editando}
                            className={editando ? 'editable' : ''}
                          />
                        </Form.Group>

                        {editando && (
                          <Alert variant="info" className="edit-alert">
                            <FaInfoCircle className="alert-icon" />
                            As alterações serão salvas ao clicar em "Salvar"
                          </Alert>
                        )}
                      </Form>
                    </div>
                  </Tab>

                  {/* Tab: Notificações */}
                  <Tab eventKey="notificacoes" title={
                    <span><FaBell className="me-2" />Notificações</span>
                  }>
                    <div className="tab-content">
                      <div className="notificacoes-header">
                        <h6>Suas Notificações</h6>
                        <span className="notificacoes-count">
                          {notificacoes.filter(n => !n.lido).length} não lidas
                        </span>
                      </div>
                      <div className="notificacoes-list">
                        {notificacoes.map((notif) => (
                          <motion.div
                            key={notif.id}
                            initial={{ opacity: 0, x: -20 }}
                            animate={{ opacity: 1, x: 0 }}
                            className={`notificacao-item ${notif.lido ? 'lida' : 'nao-lida'}`}
                          >
                            <div className="notificacao-content">
                              <p className="notificacao-text">{notif.texto}</p>
                              <span className="notificacao-data">{notif.data}</span>
                            </div>
                            {!notif.lido && (
                              <Button
                                variant="outline-primary"
                                size="sm"
                                className="notificacao-btn"
                                onClick={() => marcarComoLido(notif.id)}
                              >
                                Marcar como lida
                              </Button>
                            )}
                          </motion.div>
                        ))}
                      </div>
                    </div>
                  </Tab>

                  {/* Tab: Histórico */}
                  <Tab eventKey="historico" title={
                    <span><FaHistory className="me-2" />Histórico</span>
                  }>
                    <div className="tab-content">
                      <div className="historico-timeline">
                        {historico.map((item) => (
                          <motion.div
                            key={item.id}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="historico-item"
                          >
                            <div className="historico-marker">
                              {getTipoIcon(item.tipo)}
                            </div>
                            <div className="historico-content">
                              <p className="historico-acao">{item.acao}</p>
                              <span className="historico-data">{item.data}</span>
                            </div>
                          </motion.div>
                        ))}
                      </div>
                    </div>
                  </Tab>

                  {/* Tab: Estatísticas */}
                  <Tab eventKey="estatisticas" title={
                    <span><FaChartLine className="me-2" />Estatísticas</span>
                  }>
                    <div className="tab-content">
                      <Row className="g-3">
                        <Col md={4}>
                          <div className="stat-card-mini">
                            <div className="stat-icon-mini" style={{ background: '#EEF2FF', color: '#6366F1' }}>
                              <FaUsers />
                            </div>
                            <div>
                              <span className="stat-value-mini">{stats.totalUtilizadores}</span>
                              <span className="stat-label-mini">Utilizadores</span>
                            </div>
                          </div>
                        </Col>
                        <Col md={4}>
                          <div className="stat-card-mini">
                            <div className="stat-icon-mini" style={{ background: '#ECFDF5', color: '#22C55E' }}>
                              <FaBullhorn />
                            </div>
                            <div>
                              <span className="stat-value-mini">{stats.totalAnuncios}</span>
                              <span className="stat-label-mini">Anúncios</span>
                            </div>
                          </div>
                        </Col>
                        <Col md={4}>
                          <div className="stat-card-mini">
                            <div className="stat-icon-mini" style={{ background: '#FEF3C7', color: '#F59E0B' }}>
                              <FaMapMarkerAlt />
                            </div>
                            <div>
                              <span className="stat-value-mini">{stats.totalLocais}</span>
                              <span className="stat-label-mini">Locais</span>
                            </div>
                          </div>
                        </Col>
                        <Col md={4}>
                          <div className="stat-card-mini">
                            <div className="stat-icon-mini" style={{ background: '#FCE4EC', color: '#EC4899' }}>
                              <FaEye />
                            </div>
                            <div>
                              <span className="stat-value-mini">{stats.totalEntregas}</span>
                              <span className="stat-label-mini">Entregas</span>
                            </div>
                          </div>
                        </Col>
                        <Col md={4}>
                          <div className="stat-card-mini">
                            <div className="stat-icon-mini" style={{ background: '#E0F2FE', color: '#06B6D4' }}>
                              <FaShieldAlt />
                            </div>
                            <div>
                              <span className="stat-value-mini">{stats.totalInteracoes}</span>
                              <span className="stat-label-mini">Interações</span>
                            </div>
                          </div>
                        </Col>
                        <Col md={4}>
                          <div className="stat-card-mini">
                            <div className="stat-icon-mini" style={{ background: '#F3E8FF', color: '#8B5CF6' }}>
                              <FaStar />
                            </div>
                            <div>
                              <span className="stat-value-mini">{stats.avaliacao}</span>
                              <span className="stat-label-mini">Avaliação</span>
                            </div>
                          </div>
                        </Col>
                      </Row>
                    </div>
                  </Tab>
                </Tabs>
              </Card.Body>
            </Card>
          </Col>
        </Row>
      </Container>

      {/* ========== MODAL ALTERAR PASSWORD ========== */}
      <Modal
        show={showPasswordModal}
        onHide={() => {
          setShowPasswordModal(false);
          setErros({});
          setSenhaAtual('');
          setNovaSenha('');
          setConfirmarSenha('');
        }}
        centered
        className="password-modal"
      >
        <Modal.Header closeButton>
          <Modal.Title>
            <FaKey className="modal-icon" />
            Alterar Password
          </Modal.Title>
        </Modal.Header>
        <Form onSubmit={handleAlterarSenha}>
          <Modal.Body>
            <Form.Group className="mb-3">
              <Form.Label>Password Atual</Form.Label>
              <div className="password-input-wrapper">
                <Form.Control
                  type={showPassword ? 'text' : 'password'}
                  value={senhaAtual}
                  onChange={(e) => setSenhaAtual(e.target.value)}
                  isInvalid={!!erros.senhaAtual}
                  placeholder="Digite sua password atual"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? <FaEyeSlash /> : <FaEye />}
                </button>
              </div>
              <Form.Control.Feedback type="invalid">
                {erros.senhaAtual}
              </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Nova Password</Form.Label>
              <div className="password-input-wrapper">
                <Form.Control
                  type={showNewPassword ? 'text' : 'password'}
                  value={novaSenha}
                  onChange={(e) => setNovaSenha(e.target.value)}
                  isInvalid={!!erros.novaSenha}
                  placeholder="Mínimo 6 caracteres"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowNewPassword(!showNewPassword)}
                >
                  {showNewPassword ? <FaEyeSlash /> : <FaEye />}
                </button>
              </div>
              <Form.Control.Feedback type="invalid">
                {erros.novaSenha}
              </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Confirmar Nova Password</Form.Label>
              <div className="password-input-wrapper">
                <Form.Control
                  type={showConfirmPassword ? 'text' : 'password'}
                  value={confirmarSenha}
                  onChange={(e) => setConfirmarSenha(e.target.value)}
                  isInvalid={!!erros.confirmarSenha}
                  placeholder="Confirme sua nova password"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                >
                  {showConfirmPassword ? <FaEyeSlash /> : <FaEye />}
                </button>
              </div>
              <Form.Control.Feedback type="invalid">
                {erros.confirmarSenha}
              </Form.Control.Feedback>
            </Form.Group>

            <Alert variant="info" className="password-info">
              <FaLock className="info-icon" />
              A password deve ter no mínimo 6 caracteres e incluir letras e números.
            </Alert>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={() => setShowPasswordModal(false)}>
              Cancelar
            </Button>
            <Button variant="primary" type="submit">
              <FaSave className="me-2" />
              Alterar Password
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>

      {/* ========== MODAL ELIMINAR CONTA ========== */}
      <Modal
        show={showDeleteModal}
        onHide={() => setShowDeleteModal(false)}
        centered
        className="delete-modal"
      >
        <Modal.Header closeButton>
          <Modal.Title className="text-danger">
            <FaTrash className="modal-icon text-danger" />
            Eliminar Conta
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="delete-content">
            <FaTimesCircle className="delete-icon" />
            <h5>Tem certeza que deseja eliminar sua conta?</h5>
            <p>
              Esta ação é <strong>irreversível</strong> e todos os seus dados serão
              permanentemente removidos da plataforma.
            </p>
            <ul className="delete-list">
              <li>Seus anúncios serão removidos</li>
              <li>Seus dados de perfil serão apagados</li>
              <li>Você não poderá recuperar sua conta</li>
            </ul>
          </div>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={() => setShowDeleteModal(false)}>
            Cancelar
          </Button>
          <Button variant="danger" onClick={handleDeleteAccount}>
            <FaTrash className="me-2" />
            Sim, Eliminar Conta
          </Button>
        </Modal.Footer>
      </Modal>
    </div>
  );
};

export default PerfilAdmin;