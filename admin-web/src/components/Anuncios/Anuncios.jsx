import React, { useState, useEffect } from 'react';
import { 
  Container, Row, Col, Card, Table, Spinner, Badge, Button, 
  InputGroup, Form, Modal, OverlayTrigger, Tooltip
} from 'react-bootstrap';
import { 
  FaTrash, FaSearch, FaBullhorn, FaEye, FaFilter, 
  FaTimes, FaCalendarAlt, FaMapMarkerAlt, FaUser,
  FaChartLine, FaClock, FaExclamationTriangle,
  FaCheckCircle, FaInfoCircle
} from 'react-icons/fa';
import { motion, AnimatePresence } from 'framer-motion';
import { soapClient } from '../../api/soapClient';
import toast from 'react-hot-toast';
import './Anuncios.css';

const Anuncios = () => {
  const [anuncios, setAnuncios] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterLocal, setFilterLocal] = useState('todos');
  const [filterStatus, setFilterStatus] = useState('todos');
  const [showDetailModal, setShowDetailModal] = useState(false);
  const [selectedAnuncio, setSelectedAnuncio] = useState(null);
  const [locais, setLocais] = useState([]);

  useEffect(() => {
    carregarDados();
  }, []);

  const carregarDados = async () => {
    setLoading(true);
    try {
      const data = await soapClient.listarAnuncios();
      setAnuncios(data);
      
      // Extrair locais únicos para filtro
      const locaisUnicos = [...new Set(data.map(a => a.local).filter(Boolean))];
      setLocais(locaisUnicos);
    } catch (error) {
      toast.error('Erro ao carregar anúncios');
    }
    setLoading(false);
  };

  const handleRemover = async (id) => {
    if (!window.confirm('Deseja remover este anúncio permanentemente?')) return;
    
    try {
      await soapClient.removerAnuncio(id);
      toast.success('Anúncio removido com sucesso');
      carregarDados();
    } catch (error) {
      toast.error('Erro ao remover anúncio');
    }
  };

  const handleVerDetalhes = (anuncio) => {
    setSelectedAnuncio(anuncio);
    setShowDetailModal(true);
  };

  // Estatísticas
  const stats = {
    total: anuncios.length,
    ativos: anuncios.filter(a => a.status !== 'expirado').length,
    hoje: anuncios.filter(a => {
      const hoje = new Date().toDateString();
      return new Date(a.data).toDateString() === hoje;
    }).length,
    locais: [...new Set(anuncios.map(a => a.local).filter(Boolean))].length
  };

  // Filtrar anúncios
  const filteredAnuncios = anuncios.filter(anuncio => {
    const matchesSearch = 
      anuncio.conteudo?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      anuncio.autor?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      anuncio.local?.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesLocal = filterLocal === 'todos' || anuncio.local === filterLocal;
    const matchesStatus = filterStatus === 'todos' || anuncio.status === filterStatus;
    
    return matchesSearch && matchesLocal && matchesStatus;
  });

  // Função para formatar data
  const formatarData = (data) => {
    if (!data) return 'N/A';
    try {
      const date = new Date(data);
      return date.toLocaleDateString('pt-PT', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch {
      return data;
    }
  };

  // Função para obter cor do status
  const getStatusColor = (status) => {
    const statusMap = {
      'ativo': 'success',
      'entregue': 'info',
      'expirado': 'danger',
      'pendente': 'warning'
    };
    return statusMap[status?.toLowerCase()] || 'secondary';
  };

  if (loading) {
    return (
      <div className="anuncios-loading">
        <div className="loading-spinner"></div>
        <span>Carregando anúncios...</span>
      </div>
    );
  }

  return (
    <div className="anuncios-container">
      <Container fluid>
        {/* Cabeçalho */}
        <div className="anuncios-header">
          <div className="header-left">
            <h2 className="header-title">
              <FaBullhorn className="header-icon" />
              Anúncios
            </h2>
            <p className="header-subtitle">
              Gerir todos os anúncios da plataforma
            </p>
          </div>
          <div className="header-right">
            <Badge className="total-badge">
              <FaBullhorn className="badge-icon" />
              Total: {anuncios.length}
            </Badge>
          </div>
        </div>

        {/* Stats Cards */}
        <Row className="g-3 mb-4">
          <Col xs={6} md={3}>
            <div className="stat-card total">
              <div className="stat-icon">
                <FaBullhorn />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.total}</span>
                <span className="stat-label">Total Anúncios</span>
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
            <div className="stat-card hoje">
              <div className="stat-icon">
                <FaClock />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.hoje}</span>
                <span className="stat-label">Hoje</span>
              </div>
            </div>
          </Col>
          <Col xs={6} md={3}>
            <div className="stat-card locais">
              <div className="stat-icon">
                <FaMapMarkerAlt />
              </div>
              <div className="stat-info">
                <span className="stat-value">{stats.locais}</span>
                <span className="stat-label">Locais</span>
              </div>
            </div>
          </Col>
        </Row>

        {/* Barra de pesquisa e filtros */}
        <Row className="mb-4">
          <Col md={5} lg={4}>
            <InputGroup className="search-input-group">
              <InputGroup.Text>
                <FaSearch />
              </InputGroup.Text>
              <Form.Control
                type="text"
                placeholder="Pesquisar anúncios..."
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
          <Col md={4} lg={3} className="mt-3 mt-md-0">
            <Form.Select 
              value={filterLocal} 
              onChange={(e) => setFilterLocal(e.target.value)}
              className="filter-select"
            >
              <option value="todos">Todos os locais</option>
              {locais.map(local => (
                <option key={local} value={local}>{local}</option>
              ))}
            </Form.Select>
          </Col>
          <Col md={3} lg={2} className="mt-3 mt-md-0">
            <Form.Select 
              value={filterStatus} 
              onChange={(e) => setFilterStatus(e.target.value)}
              className="filter-select"
            >
              <option value="todos">Todos status</option>
              <option value="ativo">Ativo</option>
              <option value="entregue">Entregue</option>
              <option value="expirado">Expirado</option>
            </Form.Select>
          </Col>
          <Col md={12} lg={3} className="mt-3 mt-lg-0 text-end">
            <span className="results-count">
              {filteredAnuncios.length} anúncios encontrados
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
                    <th style={{ width: '35%' }}>Conteúdo</th>
                    <th style={{ width: '15%' }}>Autor</th>
                    <th style={{ width: '15%' }}>Local</th>
                    <th style={{ width: '15%' }}>Data</th>
                    <th style={{ width: '10%' }}>Status</th>
                    <th style={{ width: '10%' }} className="text-center">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  <AnimatePresence>
                    {filteredAnuncios.map((anuncio, index) => (
                      <motion.tr
                        key={anuncio.id || index}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.05 }}
                        className="anuncio-row"
                      >
                        <td>
                          <div className="anuncio-conteudo">
                            <span className="conteudo-text">
                              {anuncio.conteudo || 'Sem conteúdo'}
                            </span>
                          </div>
                        </td>
                        <td>
                          <div className="anuncio-autor">
                            <FaUser className="autor-icon" />
                            {anuncio.autor || 'N/A'}
                          </div>
                        </td>
                        <td>
                          <Badge className="local-badge text-white">
                            <FaMapMarkerAlt className="local-icon" />
                            {anuncio.local || 'N/A'}
                          </Badge>
                        </td>
                        <td>
                          <div className="anuncio-data">
                            <FaCalendarAlt className="data-icon" />
                            {formatarData(anuncio.data)}
                          </div>
                        </td>
                        <td>
                          <Badge 
                            bg={getStatusColor(anuncio.status)}
                            className="status-badge"
                          >
                            {anuncio.status || 'Ativo'}
                          </Badge>
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
                                onClick={() => handleVerDetalhes(anuncio)}
                              >
                                <FaEye />
                              </Button>
                            </OverlayTrigger>

                            <OverlayTrigger
                              placement="top"
                              overlay={<Tooltip>Remover anúncio</Tooltip>}
                            >
                              <Button
                                variant="outline-danger"
                                size="sm"
                                className="action-btn delete-btn"
                                onClick={() => handleRemover(anuncio.id)}
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
            {filteredAnuncios.length === 0 && (
              <div className="empty-state">
                <FaBullhorn className="empty-icon" />
                <h5>Nenhum anúncio encontrado</h5>
                <p>Tente ajustar os filtros ou verifique se há anúncios publicados</p>
              </div>
            )}
          </Card.Body>
        </Card>

        {/* Modal de Detalhes */}
        <Modal
          show={showDetailModal}
          onHide={() => setShowDetailModal(false)}
          centered
          className="detail-modal"
        >
          <Modal.Header closeButton>
            <Modal.Title>
              <FaInfoCircle className="modal-icon" />
              Detalhes do Anúncio
            </Modal.Title>
          </Modal.Header>
          <Modal.Body>
            {selectedAnuncio && (
              <div className="detail-content">
                <div className="detail-section">
                  <label>Conteúdo</label>
                  <p className="detail-conteudo">{selectedAnuncio.conteudo || 'N/A'}</p>
                </div>
                
                <Row>
                  <Col md={6}>
                    <div className="detail-section">
                      <label>Autor</label>
                      <p><FaUser className="detail-icon" /> {selectedAnuncio.autor || 'N/A'}</p>
                    </div>
                  </Col>
                  <Col md={6}>
                    <div className="detail-section">
                      <label>Local</label>
                      <p><FaMapMarkerAlt className="detail-icon" /> {selectedAnuncio.local || 'N/A'}</p>
                    </div>
                  </Col>
                </Row>

                <Row>
                  <Col md={6}>
                    <div className="detail-section">
                      <label>Data de Publicação</label>
                      <p><FaCalendarAlt className="detail-icon" /> {formatarData(selectedAnuncio.data)}</p>
                    </div>
                  </Col>
                  <Col md={6}>
                    <div className="detail-section">
                      <label>Status</label>
                      <Badge bg={getStatusColor(selectedAnuncio.status)} className="detail-status">
                        {selectedAnuncio.status || 'Ativo'}
                      </Badge>
                    </div>
                  </Col>
                </Row>

                {selectedAnuncio.entregas !== undefined && (
                  <div className="detail-section">
                    <label>Entregas</label>
                    <p><FaChartLine className="detail-icon" /> {selectedAnuncio.entregas} vezes</p>
                  </div>
                )}
              </div>
            )}
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={() => setShowDetailModal(false)}>
              Fechar
            </Button>
            {selectedAnuncio && (
              <Button 
                variant="danger" 
                onClick={() => {
                  handleRemover(selectedAnuncio.id);
                  setShowDetailModal(false);
                }}
              >
                <FaTrash className="me-2" />
                Remover Anúncio
              </Button>
            )}
          </Modal.Footer>
        </Modal>
      </Container>
    </div>
  );
};

export default Anuncios;