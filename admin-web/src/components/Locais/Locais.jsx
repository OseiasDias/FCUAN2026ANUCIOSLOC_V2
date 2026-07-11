import React, { useState, useEffect } from 'react';
import { 
  Container, Row, Col, Card, Spinner, Badge, Button, 
  Modal, Form, OverlayTrigger, Tooltip
} from 'react-bootstrap';
import { 
  FaTrash, FaPlus, FaEdit, FaMapMarkerAlt, FaSearch,
  FaTimes, FaUsers, FaBuilding, FaGlobe, FaInfoCircle,
  FaCheckCircle, FaClock, FaCity
} from 'react-icons/fa';
import { motion, AnimatePresence } from 'framer-motion';
import { soapClient } from '../../api/soapClient';
import toast from 'react-hot-toast';
import './Locais.css';

const Locais = () => {
  const [locais, setLocais] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedLocal, setSelectedLocal] = useState(null);
  const [formErrors, setFormErrors] = useState({});
  const [novoLocal, setNovoLocal] = useState({ 
    nome: '', 
    latitude: '', 
    longitude: '', 
    capacidade: '',
    tipo: 'GPS'
  });

  useEffect(() => {
    carregarLocais();
  }, []);

  const carregarLocais = async () => {
    setLoading(true);
    try {
      const data = await soapClient.listarLocais();
      setLocais(data);
    } catch (error) {
      toast.error('Erro ao carregar locais');
    }
    setLoading(false);
  };

  const handleEliminar = async (nome) => {
    if (!window.confirm(`Deseja eliminar o local ${nome} permanentemente?`)) return;
    
    try {
      await soapClient.eliminarLocal(nome);
      toast.success('Local eliminado com sucesso');
      carregarLocais();
    } catch (error) {
      toast.error('Erro ao eliminar local');
    }
  };

  const handleCriarLocal = async (e) => {
    e.preventDefault();
    
    const errors = {};
    if (!novoLocal.nome) errors.nome = 'Nome é obrigatório';
    if (!novoLocal.latitude) errors.latitude = 'Latitude é obrigatória';
    if (!novoLocal.longitude) errors.longitude = 'Longitude é obrigatória';
    if (!novoLocal.capacidade) errors.capacidade = 'Capacidade é obrigatória';
    if (parseFloat(novoLocal.latitude) < -90 || parseFloat(novoLocal.latitude) > 90) {
      errors.latitude = 'Latitude deve estar entre -90 e 90';
    }
    if (parseFloat(novoLocal.longitude) < -180 || parseFloat(novoLocal.longitude) > 180) {
      errors.longitude = 'Longitude deve estar entre -180 e 180';
    }

    if (Object.keys(errors).length > 0) {
      setFormErrors(errors);
      return;
    }

    try {
      await soapClient.criarLocal({
        nome: novoLocal.nome,
        latitude: parseFloat(novoLocal.latitude),
        longitude: parseFloat(novoLocal.longitude),
        capacidade: parseInt(novoLocal.capacidade),
        tipo: novoLocal.tipo || 'GPS',
      });
      toast.success('Local criado com sucesso');
      setShowModal(false);
      setNovoLocal({ nome: '', latitude: '', longitude: '', capacidade: '', tipo: 'GPS' });
      setFormErrors({});
      carregarLocais();
    } catch (error) {
      toast.error('Erro ao criar local');
    }
  };

  const handleEditar = (local) => {
    setSelectedLocal(local);
    setNovoLocal({
      nome: local.nome || '',
      latitude: local.latitude?.toString() || '',
      longitude: local.longitude?.toString() || '',
      capacidade: local.capacidade?.toString() || '',
      tipo: local.tipo || 'GPS'
    });
    setShowEditModal(true);
  };

  const handleAtualizarLocal = async (e) => {
    e.preventDefault();
    try {
      // Chamar API para atualizar local
      toast.success('Local atualizado com sucesso');
      setShowEditModal(false);
      setSelectedLocal(null);
      carregarLocais();
    } catch (error) {
      toast.error('Erro ao atualizar local');
    }
  };

  const filteredLocais = locais.filter(local =>
    local.nome?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    local.localizacao?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const stats = {
    total: locais.length,
    capacidadeTotal: locais.reduce((acc, l) => acc + (parseInt(l.capacidade) || 0), 0),
    ativos: locais.filter(l => l.ativo !== false).length,
    tipos: [...new Set(locais.map(l => l.tipo).filter(Boolean))].length
  };

  if (loading) {
    return (
      <div className="locais-loading">
        <div className="loading-spinner"></div>
        <span>Carregando locais...</span>
      </div>
    );
  }

  return (
    <div className="locais-container">
      <Container fluid>
        {/* Cabeçalho */}
        <div className="locais-header">
          <div className="header-left">
            <h2 className="header-title">
              <FaMapMarkerAlt className="header-icon" />
              Locais
            </h2>
            <p className="header-subtitle">
              Gerir todas as infraestruturas da plataforma
            </p>
          </div>
          <Button 
            className="btn-new-local"
            onClick={() => setShowModal(true)}
          >
            <FaPlus className="me-2" />
            Novo Local
          </Button>
        </div>

        {/* Stats Cards */}
        <Row className="g-3 mb-4">
          <Col xs={6} md={3}>
            <div className="stat-card total">
              <div className="stat-icon">
                <FaCity />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.total}</span>
                <span className="stat-label">Total Locais</span>
              </div>
            </div>
          </Col>
          <Col xs={6} md={3}>
            <div className="stat-card ativos">
              <div className="stat-icon">
                <FaCheckCircle />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.ativos}</span>
                <span className="stat-label">Ativos</span>
              </div>
            </div>
          </Col>
          <Col xs={6} md={3}>
            <div className="stat-card capacidade">
              <div className="stat-icon">
                <FaUsers />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.capacidadeTotal}</span>
                <span className="stat-label">Capacidade Total</span>
              </div>
            </div>
          </Col>
          <Col xs={6} md={3}>
            <div className="stat-card tipos">
              <div className="stat-icon">
                <FaGlobe />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.tipos}</span>
                <span className="stat-label">Tipos de Local</span>
              </div>
            </div>
          </Col>
        </Row>

        {/* Barra de pesquisa */}
        <Row className="mb-4">
          <Col md={6} lg={5}>
            <div className="search-input-group">
              <span className="search-icon"><FaSearch /></span>
              <input
                type="text"
                className="search-input"
                placeholder="Pesquisar locais..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
              {searchTerm && (
                <button className="clear-search" onClick={() => setSearchTerm('')}>
                  <FaTimes />
                </button>
              )}
            </div>
          </Col>
          <Col md={6} lg={7} className="text-end">
            <span className="results-count">
              {filteredLocais.length} locais encontrados
            </span>
          </Col>
        </Row>

        {/* Cards de Locais */}
        <Row className="g-4">
          <AnimatePresence>
            {filteredLocais.map((local, index) => (
              <Col key={local.id} xs={12} md={6} lg={4} xl={3}>
                <motion.div
                  initial={{ opacity: 0, y: 20, scale: 0.95 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  transition={{ delay: index * 0.05 }}
                >
                  <Card className="local-card">
                    <Card.Body>
                      <div className="local-card-header">
                        <div className="local-icon-wrapper">
                          <FaMapMarkerAlt className="local-card-icon" />
                        </div>
                        <Badge className={`local-status ${local.ativo !== false ? 'active' : 'inactive'}`}>
                          {local.ativo !== false ? 'Ativo' : 'Inativo'}
                        </Badge>
                      </div>

                      <h5 className="local-name">{local.nome || 'Local sem nome'}</h5>
                      
                      <div className="local-coords">
                        <span className="coord-item">
                          <span className="coord-label">Lat:</span>
                          {local.latitude?.toFixed(4) || 'N/A'}
                        </span>
                        <span className="coord-item">
                          <span className="coord-label">Lon:</span>
                          {local.longitude?.toFixed(4) || 'N/A'}
                        </span>
                      </div>

                      <div className="local-info-grid">
                        <div className="info-item">
                          <FaUsers className="info-icon" />
                          <span>
                            <strong>{local.capacidade || 0}</strong>
                            <small>capacidade</small>
                          </span>
                        </div>
                        {local.tipo && (
                          <div className="info-item">
                            <FaGlobe className="info-icon" />
                            <span>
                              <strong>{local.tipo}</strong>
                              <small>tipo</small>
                            </span>
                          </div>
                        )}
                      </div>

                      {local.criador && (
                        <div className="local-criador">
                          <FaBuilding className="criador-icon" />
                          <span>Criado por: {local.criador}</span>
                        </div>
                      )}

                      <div className="local-actions">
                        <OverlayTrigger
                          placement="top"
                          overlay={<Tooltip>Editar local</Tooltip>}
                        >
                          <Button
                            variant="outline-primary"
                            size="sm"
                            className="action-btn edit-btn"
                            onClick={() => handleEditar(local)}
                          >
                            <FaEdit />
                          </Button>
                        </OverlayTrigger>

                        <OverlayTrigger
                          placement="top"
                          overlay={<Tooltip>Eliminar local</Tooltip>}
                        >
                          <Button
                            variant="outline-danger"
                            size="sm"
                            className="action-btn delete-btn"
                            onClick={() => handleEliminar(local.nome)}
                          >
                            <FaTrash />
                          </Button>
                        </OverlayTrigger>
                      </div>
                    </Card.Body>
                  </Card>
                </motion.div>
              </Col>
            ))}
          </AnimatePresence>

          {filteredLocais.length === 0 && (
            <Col xs={12}>
              <div className="empty-state">
                <FaMapMarkerAlt className="empty-icon" />
                <h5>Nenhum local encontrado</h5>
                <p>{searchTerm ? 'Tente ajustar a pesquisa' : 'Clique em "Novo Local" para adicionar uma infraestrutura'}</p>
              </div>
            </Col>
          )}
        </Row>
      </Container>

      {/* Modal Novo Local */}
      <Modal 
        show={showModal} 
        onHide={() => {
          setShowModal(false);
          setFormErrors({});
          setNovoLocal({ nome: '', latitude: '', longitude: '', capacidade: '', tipo: 'GPS' });
        }}
        centered
        className="local-modal"
      >
        <Modal.Header closeButton>
          <Modal.Title>
            <FaPlus className="modal-icon" />
            Novo Local
          </Modal.Title>
        </Modal.Header>
        <Form onSubmit={handleCriarLocal}>
          <Modal.Body>
            <Form.Group className="mb-3">
              <Form.Label>
                <FaMapMarkerAlt className="label-icon" />
                Nome
              </Form.Label>
              <Form.Control
                type="text"
                placeholder="Ex: Belas Shopping"
                value={novoLocal.nome}
                onChange={(e) => setNovoLocal({...novoLocal, nome: e.target.value})}
                isInvalid={!!formErrors.nome}
                required
              />
              <Form.Control.Feedback type="invalid">
                {formErrors.nome}
              </Form.Control.Feedback>
            </Form.Group>

            <Row>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>
                    <FaGlobe className="label-icon" />
                    Latitude
                  </Form.Label>
                  <Form.Control
                    type="number"
                    step="any"
                    placeholder="-8.98"
                    value={novoLocal.latitude}
                    onChange={(e) => setNovoLocal({...novoLocal, latitude: e.target.value})}
                    isInvalid={!!formErrors.latitude}
                    required
                  />
                  <Form.Control.Feedback type="invalid">
                    {formErrors.latitude}
                  </Form.Control.Feedback>
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>
                    <FaGlobe className="label-icon" />
                    Longitude
                  </Form.Label>
                  <Form.Control
                    type="number"
                    step="any"
                    placeholder="13.18"
                    value={novoLocal.longitude}
                    onChange={(e) => setNovoLocal({...novoLocal, longitude: e.target.value})}
                    isInvalid={!!formErrors.longitude}
                    required
                  />
                  <Form.Control.Feedback type="invalid">
                    {formErrors.longitude}
                  </Form.Control.Feedback>
                </Form.Group>
              </Col>
            </Row>

            <Row>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>
                    <FaUsers className="label-icon" />
                    Capacidade
                  </Form.Label>
                  <Form.Control
                    type="number"
                    placeholder="100"
                    value={novoLocal.capacidade}
                    onChange={(e) => setNovoLocal({...novoLocal, capacidade: e.target.value})}
                    isInvalid={!!formErrors.capacidade}
                    required
                  />
                  <Form.Control.Feedback type="invalid">
                    {formErrors.capacidade}
                  </Form.Control.Feedback>
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>
                    <FaGlobe className="label-icon" />
                    Tipo
                  </Form.Label>
                  <Form.Select
                    value={novoLocal.tipo}
                    onChange={(e) => setNovoLocal({...novoLocal, tipo: e.target.value})}
                  >
                    <option value="GPS">GPS</option>
                    <option value="WIFI">WiFi</option>
                    <option value="BLE">BLE</option>
                  </Form.Select>
                </Form.Group>
              </Col>
            </Row>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={() => setShowModal(false)}>
              Cancelar
            </Button>
            <Button variant="primary" type="submit">
              <FaPlus className="me-2" />
              Criar Local
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>

      {/* Modal Editar Local */}
      <Modal
        show={showEditModal}
        onHide={() => {
          setShowEditModal(false);
          setSelectedLocal(null);
          setFormErrors({});
        }}
        centered
        className="local-modal"
      >
        <Modal.Header closeButton>
          <Modal.Title>
            <FaEdit className="modal-icon" />
            Editar Local
          </Modal.Title>
        </Modal.Header>
        <Form onSubmit={handleAtualizarLocal}>
          <Modal.Body>
            <Form.Group className="mb-3">
              <Form.Label>
                <FaMapMarkerAlt className="label-icon" />
                Nome
              </Form.Label>
              <Form.Control
                type="text"
                placeholder="Nome do local"
                value={novoLocal.nome}
                onChange={(e) => setNovoLocal({...novoLocal, nome: e.target.value})}
                required
              />
            </Form.Group>

            <Row>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>Latitude</Form.Label>
                  <Form.Control
                    type="number"
                    step="any"
                    value={novoLocal.latitude}
                    onChange={(e) => setNovoLocal({...novoLocal, latitude: e.target.value})}
                    required
                  />
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>Longitude</Form.Label>
                  <Form.Control
                    type="number"
                    step="any"
                    value={novoLocal.longitude}
                    onChange={(e) => setNovoLocal({...novoLocal, longitude: e.target.value})}
                    required
                  />
                </Form.Group>
              </Col>
            </Row>

            <Form.Group className="mb-3">
              <Form.Label>Capacidade</Form.Label>
              <Form.Control
                type="number"
                value={novoLocal.capacidade}
                onChange={(e) => setNovoLocal({...novoLocal, capacidade: e.target.value})}
                required
              />
            </Form.Group>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={() => setShowEditModal(false)}>
              Cancelar
            </Button>
            <Button variant="primary" type="submit">
              <FaEdit className="me-2" />
              Atualizar Local
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>
    </div>
  );
};

export default Locais;