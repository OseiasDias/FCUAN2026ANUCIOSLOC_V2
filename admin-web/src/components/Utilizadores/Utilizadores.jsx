import React, { useState, useEffect } from 'react';
import { 
  Container, Row, Col, Card, Table, Form, Button, 
  Spinner, Badge, InputGroup, Modal, Alert, Tooltip,
  OverlayTrigger
} from 'react-bootstrap';
import { 
  FaSearch, FaUserPlus, FaEdit, FaTrash, FaCheck, 
  FaTimes, FaUsers, FaUserCheck, FaUserTimes, 
  FaCoins, FaCalendarAlt, FaFilter, FaEye,
  FaUserCircle, FaEnvelope, FaKey
} from 'react-icons/fa';
import { motion, AnimatePresence } from 'framer-motion';
import { soapClient } from '../../api/soapClient';
import toast from 'react-hot-toast';
import './Utilizadores.css';

const Utilizadores = () => {
  const [utilizadores, setUtilizadores] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [filterStatus, setFilterStatus] = useState('todos');
  const [selectedUser, setSelectedUser] = useState(null);
  const [showDetailModal, setShowDetailModal] = useState(false);
  const [novoUtilizador, setNovoUtilizador] = useState({ 
    email: '', 
    nome: '', 
    password: '',
    confirmPassword: ''
  });
  const [formErrors, setFormErrors] = useState({});

  useEffect(() => {
    carregarUtilizadores();
  }, []);

  const carregarUtilizadores = async () => {
    setLoading(true);
    try {
      const data = await soapClient.listarUtilizadores();
      console.log('📦 Utilizadores recebidos:', data);
      
      // Garantir que os dados são um array
      if (Array.isArray(data)) {
        setUtilizadores(data);
      } else {
        console.warn('⚠️ Dados não são um array:', data);
        setUtilizadores([]);
      }
    } catch (error) {
      console.error('❌ Erro ao carregar utilizadores:', error);
      toast.error('Erro ao carregar utilizadores');
      setUtilizadores([]);
    }
    setLoading(false);
  };

  const handleDesativar = async (email) => {
    if (!window.confirm(`Deseja desativar o utilizador ${email}?`)) return;
    
    try {
      await soapClient.desativarUtilizador(email);
      toast.success('Utilizador desativado com sucesso');
      carregarUtilizadores();
    } catch (error) {
      toast.error('Erro ao desativar utilizador');
    }
  };

  const handleAtivar = async (email) => {
    try {
      await soapClient.ativarUtilizador(email);
      toast.success('Utilizador ativado com sucesso');
      carregarUtilizadores();
    } catch (error) {
      toast.error('Erro ao ativar utilizador');
    }
  };

  const handleEliminar = async (email) => {
    if (!window.confirm(`Deseja eliminar permanentemente o utilizador ${email}?`)) return;
    
    try {
      await soapClient.eliminarUtilizador(email);
      toast.success('Utilizador eliminado com sucesso');
      carregarUtilizadores();
    } catch (error) {
      toast.error('Erro ao eliminar utilizador');
    }
  };

  const handleCriarUtilizador = async (e) => {
    e.preventDefault();
    const errors = {};
    
    if (!novoUtilizador.email) errors.email = 'Email é obrigatório';
    if (!novoUtilizador.nome) errors.nome = 'Nome é obrigatório';
    if (novoUtilizador.password.length < 4) errors.password = 'Mínimo 4 caracteres';
    if (novoUtilizador.password !== novoUtilizador.confirmPassword) {
      errors.confirmPassword = 'Passwords não coincidem';
    }

    if (Object.keys(errors).length > 0) {
      setFormErrors(errors);
      return;
    }

    try {
      await soapClient.ativarUtilizador(novoUtilizador.email, novoUtilizador.password, novoUtilizador.nome);
      toast.success('Utilizador criado com sucesso');
      setShowModal(false);
      setNovoUtilizador({ email: '', nome: '', password: '', confirmPassword: '' });
      setFormErrors({});
      carregarUtilizadores();
    } catch (error) {
      toast.error('Erro ao criar utilizador');
    }
  };

  const handleVerDetalhes = (user) => {
    setSelectedUser(user);
    setShowDetailModal(true);
  };

  // ==================== FILTER USERS (COM VERIFICAÇÃO) ====================
  
  const filteredUsers = utilizadores.filter(user => {
    // ✅ VERIFICAR SE user EXISTE
    if (!user) return false;
    
    // ✅ VERIFICAR SE TEM email E nome
    const email = user.email || '';
    const nome = user.nome || '';
    const searchLower = searchTerm.toLowerCase();
    
    const matchesSearch = email.toLowerCase().includes(searchLower) ||
                          nome.toLowerCase().includes(searchLower);
    
    // ✅ VERIFICAR SE TEM O CAMPO 'ativo'
    const isAtivo = user.ativo !== undefined ? user.ativo : true;
    const matchesStatus = filterStatus === 'todos' || 
                         (filterStatus === 'ativos' && isAtivo) ||
                         (filterStatus === 'inativos' && !isAtivo);
    
    return matchesSearch && matchesStatus;
  });

  // ==================== STATS (COM VERIFICAÇÃO) ====================

  const stats = {
    total: utilizadores.length,
    ativos: utilizadores.filter(u => u && u.ativo !== undefined ? u.ativo : true).length,
    inativos: utilizadores.filter(u => u && !u.ativo).length,
    saldoTotal: utilizadores.reduce((acc, u) => acc + (u?.saldo || 0), 0)
  };

  if (loading) {
    return (
      <div className="utilizadores-loading">
        <div className="loading-spinner"></div>
        <span>Carregando utilizadores...</span>
      </div>
    );
  }

  return (
    <div className="utilizadores-container">
      <Container fluid>
        {/* Cabeçalho */}
        <div className="utilizadores-header">
          <div className="header-left">
            <h2 className="header-title">
              <FaUsers className="header-icon" />
              Utilizadores
            </h2>
            <p className="header-subtitle">
              Gerir todos os utilizadores da plataforma
            </p>
          </div>
          <Button 
            className="btn-new-user"
            onClick={() => setShowModal(true)}
          >
            <FaUserPlus className="me-2" />
            Novo Utilizador
          </Button>
        </div>

        {/* Stats Cards */}
        <Row className="g-3 mb-4">
          <Col xs={6} md={3}>
            <div className="stat-card total">
              <div className="stat-icon">
                <FaUsers />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.total}</span>
                <span className="stat-label">Total</span>
              </div>
            </div>
          </Col>
          <Col xs={6} md={3}>
            <div className="stat-card ativos">
              <div className="stat-icon">
                <FaUserCheck />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.ativos}</span>
                <span className="stat-label">Ativos</span>
              </div>
            </div>
          </Col>
          <Col xs={6} md={3}>
            <div className="stat-card inativos">
              <div className="stat-icon">
                <FaUserTimes />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.inativos}</span>
                <span className="stat-label">Inativos</span>
              </div>
            </div>
          </Col>
          <Col xs={6} md={3}>
            <div className="stat-card saldo">
              <div className="stat-icon">
                <FaCoins />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.saldoTotal}</span>
                <span className="stat-label">Saldo Total</span>
              </div>
            </div>
          </Col>
        </Row>

        {/* Barra de pesquisa e filtros */}
        <Row className="mb-4">
          <Col md={6} lg={5}>
            <InputGroup className="search-input-group">
              <InputGroup.Text>
                <FaSearch />
              </InputGroup.Text>
              <Form.Control
                type="text"
                placeholder="Pesquisar por email ou nome..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
              {searchTerm && (
                <Button 
                  variant="outline-secondary" 
                  onClick={() => setSearchTerm('')}
                  className="clear-search"
                >
                  <FaTimes />
                </Button>
              )}
            </InputGroup>
          </Col>
          <Col md={6} lg={4} className="mt-3 mt-md-0">
            <div className="filter-group">
              <Button 
                variant={filterStatus === 'todos' ? 'primary' : 'outline-secondary'}
                size="sm"
                onClick={() => setFilterStatus('todos')}
              >
                Todos
              </Button>
              <Button 
                variant={filterStatus === 'ativos' ? 'success' : 'outline-secondary'}
                size="sm"
                onClick={() => setFilterStatus('ativos')}
              >
                <FaUserCheck className="me-1" />
                Ativos
              </Button>
              <Button 
                variant={filterStatus === 'inativos' ? 'danger' : 'outline-secondary'}
                size="sm"
                onClick={() => setFilterStatus('inativos')}
              >
                <FaUserTimes className="me-1" />
                Inativos
              </Button>
            </div>
          </Col>
          <Col lg={3} className="mt-3 mt-lg-0 text-end">
            <span className="results-count">
              {filteredUsers.length} utilizadores encontrados
            </span>
          </Col>
        </Row>

        {/* Tabela */}
        <Card className="table-card">
          <Card.Body className="p-0">
            <div className="table-responsive">
              <Table hover className="mb-0">
                <thead>
                  <tr>
                    <th>Utilizador</th>
                    <th>Saldo</th>
                    <th>Status</th>
                    <th>Data Registo</th>
                    <th className="text-center">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  <AnimatePresence>
                    {filteredUsers.map((user, index) => (
                      <motion.tr
                        key={user?.email || index}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.05 }}
                        className="user-row"
                      >
                        <td>
                          <div className="user-info">
                            <div className="user-avatar">
                              {user?.nome?.charAt(0).toUpperCase() || 'U'}
                            </div>
                            <div>
                              <div className="user-name">{user?.nome || 'Sem nome'}</div>
                              <div className="user-email">
                                <FaEnvelope className="email-icon" />
                                {user?.email || 'Sem email'}
                              </div>
                            </div>
                          </div>
                        </td>
                        <td>
                          <span className="user-saldo">
                            <FaCoins className="saldo-icon" />
                            {user?.saldo || 0} pts
                          </span>
                        </td>
                        <td>
                          <Badge 
                            className={`status-badge ${user?.ativo ? 'status-active' : 'status-inactive'}`}
                          >
                            {user?.ativo ? (
                              <>
                                <span className="status-dot active"></span>
                                Ativo
                              </>
                            ) : (
                              <>
                                <span className="status-dot inactive"></span>
                                Inativo
                              </>
                            )}
                          </Badge>
                        </td>
                        <td>
                          <div className="user-data">
                            <FaCalendarAlt className="data-icon" />
                            {user?.dataRegisto || 'N/A'}
                          </div>
                        </td>
                        <td>
                          <div className="actions-group">
                            <OverlayTrigger
                              placement="top"
                              overlay={<Tooltip>Ver detalhes</Tooltip>}
                            >
                              <Button
                                variant="outline-info"
                                size="sm"
                                className="action-btn view-btn"
                                onClick={() => handleVerDetalhes(user)}
                              >
                                <FaEye />
                              </Button>
                            </OverlayTrigger>

                            <OverlayTrigger
                              placement="top"
                              overlay={<Tooltip>{user?.ativo ? 'Desativar' : 'Ativar'}</Tooltip>}
                            >
                              <Button
                                variant={user?.ativo ? 'outline-warning' : 'outline-success'}
                                size="sm"
                                className="action-btn toggle-btn"
                                onClick={() => user?.ativo ? handleDesativar(user.email) : handleAtivar(user.email)}
                              >
                                {user?.ativo ? <FaTimes /> : <FaCheck />}
                              </Button>
                            </OverlayTrigger>

                            <OverlayTrigger
                              placement="top"
                              overlay={<Tooltip>Eliminar</Tooltip>}
                            >
                              <Button
                                variant="outline-danger"
                                size="sm"
                                className="action-btn delete-btn"
                                onClick={() => handleEliminar(user?.email)}
                              >
                                <FaTrash />
                              </Button>
                            </OverlayTrigger>
                          </div>
                        </td>
                      </motion.tr>
                    ))}
                  </AnimatePresence>
                </tbody>
              </Table>
            </div>
            {filteredUsers.length === 0 && (
              <div className="empty-state">
                <FaUsers className="empty-icon" />
                <h5>Nenhum utilizador encontrado</h5>
                <p>Tente ajustar os filtros ou criar um novo utilizador</p>
              </div>
            )}
          </Card.Body>
        </Card>
      </Container>

      {/* Modal Novo Utilizador */}
      <Modal 
        show={showModal} 
        onHide={() => {
          setShowModal(false);
          setFormErrors({});
          setNovoUtilizador({ email: '', nome: '', password: '', confirmPassword: '' });
        }}
        centered
        className="user-modal"
      >
        <Modal.Header closeButton>
          <Modal.Title>
            <FaUserPlus className="modal-icon" />
            Novo Utilizador
          </Modal.Title>
        </Modal.Header>
        <Form onSubmit={handleCriarUtilizador}>
          <Modal.Body>
            <Form.Group className="mb-3">
              <Form.Label>
                <FaEnvelope className="label-icon" />
                Email
              </Form.Label>
              <Form.Control
                type="email"
                placeholder="exemplo@email.com"
                value={novoUtilizador.email}
                onChange={(e) => setNovoUtilizador({...novoUtilizador, email: e.target.value})}
                isInvalid={!!formErrors.email}
                required
              />
              <Form.Control.Feedback type="invalid">
                {formErrors.email}
              </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>
                <FaUserCircle className="label-icon" />
                Nome
              </Form.Label>
              <Form.Control
                type="text"
                placeholder="Nome completo"
                value={novoUtilizador.nome}
                onChange={(e) => setNovoUtilizador({...novoUtilizador, nome: e.target.value})}
                isInvalid={!!formErrors.nome}
                required
              />
              <Form.Control.Feedback type="invalid">
                {formErrors.nome}
              </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>
                <FaKey className="label-icon" />
                Password
              </Form.Label>
              <Form.Control
                type="password"
                placeholder="Mínimo 4 caracteres"
                value={novoUtilizador.password}
                onChange={(e) => setNovoUtilizador({...novoUtilizador, password: e.target.value})}
                isInvalid={!!formErrors.password}
                required
              />
              <Form.Control.Feedback type="invalid">
                {formErrors.password}
              </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>
                <FaKey className="label-icon" />
                Confirmar Password
              </Form.Label>
              <Form.Control
                type="password"
                placeholder="Confirmar password"
                value={novoUtilizador.confirmPassword}
                onChange={(e) => setNovoUtilizador({...novoUtilizador, confirmPassword: e.target.value})}
                isInvalid={!!formErrors.confirmPassword}
                required
              />
              <Form.Control.Feedback type="invalid">
                {formErrors.confirmPassword}
              </Form.Control.Feedback>
            </Form.Group>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={() => setShowModal(false)}>
              Cancelar
            </Button>
            <Button variant="primary" type="submit">
              <FaUserPlus className="me-2" />
              Criar Utilizador
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>

      {/* Modal Detalhes do Utilizador */}
      <Modal
        show={showDetailModal}
        onHide={() => setShowDetailModal(false)}
        centered
        className="user-modal detail-modal"
      >
        <Modal.Header closeButton>
          <Modal.Title>
            <FaUserCircle className="modal-icon" />
            Detalhes do Utilizador
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {selectedUser && (
            <div className="user-detail-content">
              <div className="detail-avatar">
                {selectedUser?.nome?.charAt(0).toUpperCase() || 'U'}
              </div>
              <div className="detail-info">
                <div className="detail-row">
                  <strong>Nome</strong>
                  <span>{selectedUser?.nome || 'N/A'}</span>
                </div>
                <div className="detail-row">
                  <strong>Email</strong>
                  <span>{selectedUser?.email || 'N/A'}</span>
                </div>
                <div className="detail-row">
                  <strong>Saldo</strong>
                  <span className="detail-saldo">{selectedUser?.saldo || 0} pts</span>
                </div>
                <div className="detail-row">
                  <strong>Status</strong>
                  <Badge className={selectedUser?.ativo ? 'status-active' : 'status-inactive'}>
                    {selectedUser?.ativo ? 'Ativo' : 'Inativo'}
                  </Badge>
                </div>
                <div className="detail-row">
                  <strong>Data Registo</strong>
                  <span>{selectedUser?.dataRegisto || 'N/A'}</span>
                </div>
              </div>
            </div>
          )}
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={() => setShowDetailModal(false)}>
            Fechar
          </Button>
        </Modal.Footer>
      </Modal>
    </div>
  );
};

export default Utilizadores;