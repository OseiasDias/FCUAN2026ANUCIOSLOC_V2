import React, { useState } from 'react';
import {
  Container, Row, Col, Card, Form, Button, Badge,
  Alert, Tab, Nav, Spinner, InputGroup
} from 'react-bootstrap';
import {
  FaCog, FaPalette, FaBell, FaLock, FaGlobe,
  FaDatabase, FaServer, FaShieldAlt, FaUserShield,
  FaEnvelope, FaMobile, FaDesktop, FaCloud,
  FaLanguage, FaClock, FaSave, FaUndo,
  FaWifi, FaBluetooth, FaMapMarkerAlt,
  FaMoon, FaSun, FaEye, FaEyeSlash,
  FaCheckCircle, FaExclamationTriangle,
  FaInfoCircle, FaQuestionCircle
} from 'react-icons/fa';
import { motion, AnimatePresence } from 'framer-motion';
import toast from 'react-hot-toast';
import './Configuracoes.css';

const Configuracoes = () => {
  const [loading, setLoading] = useState(false);
  const [tabAtiva, setTabAtiva] = useState('geral');
  const [salvo, setSalvo] = useState(false);

  // ==================== CONFIGURAÇÕES ====================

  // Configurações Gerais
  const [configGeral, setConfigGeral] = useState({
    nomeApp: 'AnunciosLoc',
    descricao: 'Sistema de Anúncios por Localização',
    versao: '2.0.0',
    ambiente: 'producao',
    idioma: 'pt',
    fusoHorario: 'Africa/Luanda',
  });

  // Configurações de Aparência
  const [configAparencia, setConfigAparencia] = useState({
    tema: 'claro',
    corPrimaria: '#6366F1',
    corSecundaria: '#8B5CF6',
    fonte: 'Poppins',
    tamanhoFonte: 'medio',
    animacoes: true,
    sidebarColapsada: false,
  });

  // Configurações de Notificações
  const [configNotificacoes, setConfigNotificacoes] = useState({
    email: true,
    push: true,
    sms: false,
    novosUtilizadores: true,
    novosAnuncios: true,
    reports: true,
    sistema: true,
    marketing: false,
  });

  // Configurações de Segurança
  const [configSeguranca, setConfigSeguranca] = useState({
    doisFatores: false,
    sessaoDuracao: 60,
    tentativasMaximas: 5,
    bloqueioTempo: 30,
    ipRestrito: false,
    logsAtivos: true,
    sslForcado: true,
  });

  // Configurações de Sistema
  const [configSistema, setConfigSistema] = useState({
    cacheAtivo: true,
    cacheTempo: 3600,
    maxAnuncios: 1000,
    maxUtilizadores: 10000,
    manutencao: false,
    backupAutomatico: true,
    backupFrequencia: 'diario',
  });

  // Configurações de Comunicação
  const [configComunicacao, setConfigComunicacao] = useState({
    modoCentralizado: true,
    modoDescentralizado: true,
    modoMULA: true,
    wifiDirect: true,
    bluetooth: false,
    gps: true,
    timeout: 30,
    maxTentativas: 3,
  });

  // ==================== HANDLERS ====================

  const handleSalvar = () => {
    setLoading(true);
    setTimeout(() => {
      toast.success('Configurações salvas com sucesso!');
      setSalvo(true);
      setLoading(false);
      setTimeout(() => setSalvo(false), 3000);
    }, 1000);
  };

  const handleReset = () => {
    if (window.confirm('Deseja restaurar as configurações padrão?')) {
      toast.success('Configurações restauradas!');
    }
  };

  const handleToggle = (config, field) => {
    const setConfig = {
      geral: setConfigGeral,
      aparencia: setConfigAparencia,
      notificacoes: setConfigNotificacoes,
      seguranca: setConfigSeguranca,
      sistema: setConfigSistema,
      comunicacao: setConfigComunicacao,
    }[config];

    setConfig(prev => ({
      ...prev,
      [field]: !prev[field]
    }));
  };

  // ==================== RENDER ====================

  if (loading) {
    return (
      <div className="config-loading">
        <div className="loading-spinner"></div>
        <span>A salvar configurações...</span>
      </div>
    );
  }

  return (
    <div className="config-container">
      <Container fluid>
        {/* Cabeçalho */}
        <div className="config-header">
          <div>
            <h2 className="config-title">
              <FaCog className="config-icon" />
              Configurações
            </h2>
            <p className="config-subtitle">Gerir as configurações da plataforma</p>
          </div>
          <div className="config-actions">
            <Button
              variant="outline-secondary"
              className="btn-reset"
              onClick={handleReset}
            >
              <FaUndo className="me-2" />
              Restaurar
            </Button>
            <Button
              variant="primary"
              className="btn-save"
              onClick={handleSalvar}
            >
              <FaSave className="me-2" />
              Salvar Configurações
            </Button>
          </div>
        </div>

        {salvo && (
          <Alert variant="success" className="save-alert">
            <FaCheckCircle className="alert-icon" />
            Configurações salvas com sucesso!
          </Alert>
        )}

        <Row className="g-4">
          {/* Sidebar de Configurações */}
          <Col lg={3}>
            <Card className="config-sidebar">
              <Card.Body className="p-0">
                <div className="config-sidebar-menu">
                  <div className="sidebar-user">
                    <FaUserShield className="user-icon" />
                    <div>
                      <span className="user-name">Administrador</span>
                      <span className="user-role">Configurações do Sistema</span>
                    </div>
                  </div>
                  <Nav
                    variant="pills"
                    className="flex-column"
                    activeKey={tabAtiva}
                    onSelect={(k) => setTabAtiva(k)}
                  >
                    <Nav.Item>
                      <Nav.Link eventKey="geral">
                        <FaGlobe className="nav-icon" />
                        Geral
                      </Nav.Link>
                    </Nav.Item>
                    <Nav.Item>
                      <Nav.Link eventKey="aparencia">
                        <FaPalette className="nav-icon" />
                        Aparência
                      </Nav.Link>
                    </Nav.Item>
                    <Nav.Item>
                      <Nav.Link eventKey="notificacoes">
                        <FaBell className="nav-icon" />
                        Notificações
                        <Badge bg="danger" pill className="ms-2">3</Badge>
                      </Nav.Link>
                    </Nav.Item>
                    <Nav.Item>
                      <Nav.Link eventKey="seguranca">
                        <FaLock className="nav-icon" />
                        Segurança
                      </Nav.Link>
                    </Nav.Item>
                    <Nav.Item>
                      <Nav.Link eventKey="sistema">
                        <FaServer className="nav-icon" />
                        Sistema
                      </Nav.Link>
                    </Nav.Item>
                    <Nav.Item>
                      <Nav.Link eventKey="comunicacao">
                        <FaGlobe className="nav-icon" />
                        Comunicação
                      </Nav.Link>
                    </Nav.Item>
                  </Nav>
                </div>
              </Card.Body>
            </Card>
          </Col>

          {/* Conteúdo das Configurações */}
          <Col lg={9}>
            <Card className="config-content">
              <Card.Body>
                <AnimatePresence mode="wait">
                  <motion.div
                    key={tabAtiva}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ duration: 0.3 }}
                  >
                    {tabAtiva === 'geral' && (
                      <div className="config-section">
                        <h4 className="section-title">
                          <FaGlobe className="section-icon" />
                          Configurações Gerais
                        </h4>
                        <p className="section-desc">
                          Defina as configurações básicas da plataforma
                        </p>

                        <Form>
                          <Row>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Nome da Aplicação</Form.Label>
                                <Form.Control
                                  type="text"
                                  value={configGeral.nomeApp}
                                  onChange={(e) => setConfigGeral({...configGeral, nomeApp: e.target.value})}
                                />
                              </Form.Group>
                            </Col>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Versão</Form.Label>
                                <Form.Control
                                  type="text"
                                  value={configGeral.versao}
                                  disabled
                                  className="disabled-field"
                                />
                              </Form.Group>
                            </Col>
                          </Row>

                          <Form.Group className="mb-3">
                            <Form.Label>Descrição</Form.Label>
                            <Form.Control
                              type="text"
                              value={configGeral.descricao}
                              onChange={(e) => setConfigGeral({...configGeral, descricao: e.target.value})}
                            />
                          </Form.Group>

                          <Row>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Ambiente</Form.Label>
                                <Form.Select
                                  value={configGeral.ambiente}
                                  onChange={(e) => setConfigGeral({...configGeral, ambiente: e.target.value})}
                                >
                                  <option value="desenvolvimento">Desenvolvimento</option>
                                  <option value="teste">Teste</option>
                                  <option value="producao">Produção</option>
                                </Form.Select>
                              </Form.Group>
                            </Col>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Idioma</Form.Label>
                                <Form.Select
                                  value={configGeral.idioma}
                                  onChange={(e) => setConfigGeral({...configGeral, idioma: e.target.value})}
                                >
                                  <option value="pt">Português</option>
                                  <option value="en">English</option>
                                  <option value="fr">Français</option>
                                  <option value="es">Español</option>
                                </Form.Select>
                              </Form.Group>
                            </Col>
                          </Row>

                          <Form.Group className="mb-3">
                            <Form.Label>Fuso Horário</Form.Label>
                            <Form.Select
                              value={configGeral.fusoHorario}
                              onChange={(e) => setConfigGeral({...configGeral, fusoHorario: e.target.value})}
                            >
                              <option value="Africa/Luanda">Africa/Luanda (UTC+1)</option>
                              <option value="Africa/Lagos">Africa/Lagos (UTC+1)</option>
                              <option value="Europe/Lisbon">Europe/Lisbon (UTC+0)</option>
                              <option value="America/Sao_Paulo">America/Sao_Paulo (UTC-3)</option>
                            </Form.Select>
                          </Form.Group>
                        </Form>
                      </div>
                    )}

                    {tabAtiva === 'aparencia' && (
                      <div className="config-section">
                        <h4 className="section-title">
                          <FaPalette className="section-icon" />
                          Aparência
                        </h4>
                        <p className="section-desc">
                          Personalize a aparência do painel administrativo
                        </p>

                        <Form>
                          <Row>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Tema</Form.Label>
                                <div className="theme-selector">
                                  <Button
                                    variant={configAparencia.tema === 'claro' ? 'primary' : 'outline-secondary'}
                                    onClick={() => setConfigAparencia({...configAparencia, tema: 'claro'})}
                                    className="theme-btn"
                                  >
                                    <FaSun /> Claro
                                  </Button>
                                  <Button
                                    variant={configAparencia.tema === 'escuro' ? 'primary' : 'outline-secondary'}
                                    onClick={() => setConfigAparencia({...configAparencia, tema: 'escuro'})}
                                    className="theme-btn"
                                  >
                                    <FaMoon /> Escuro
                                  </Button>
                                  <Button
                                    variant={configAparencia.tema === 'sistema' ? 'primary' : 'outline-secondary'}
                                    onClick={() => setConfigAparencia({...configAparencia, tema: 'sistema'})}
                                    className="theme-btn"
                                  >
                                    Sistema
                                  </Button>
                                </div>
                              </Form.Group>
                            </Col>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Fonte</Form.Label>
                                <Form.Select
                                  value={configAparencia.fonte}
                                  onChange={(e) => setConfigAparencia({...configAparencia, fonte: e.target.value})}
                                >
                                  <option value="Poppins">Poppins</option>
                                  <option value="Inter">Inter</option>
                                  <option value="Roboto">Roboto</option>
                                  <option value="Open Sans">Open Sans</option>
                                </Form.Select>
                              </Form.Group>
                            </Col>
                          </Row>

                          <Row>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Cor Primária</Form.Label>
                                <div className="color-picker-wrapper">
                                  <input
                                    type="color"
                                    className="color-picker"
                                    value={configAparencia.corPrimaria}
                                    onChange={(e) => setConfigAparencia({...configAparencia, corPrimaria: e.target.value})}
                                  />
                                  <span className="color-value">{configAparencia.corPrimaria}</span>
                                </div>
                              </Form.Group>
                            </Col>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Cor Secundária</Form.Label>
                                <div className="color-picker-wrapper">
                                  <input
                                    type="color"
                                    className="color-picker"
                                    value={configAparencia.corSecundaria}
                                    onChange={(e) => setConfigAparencia({...configAparencia, corSecundaria: e.target.value})}
                                  />
                                  <span className="color-value">{configAparencia.corSecundaria}</span>
                                </div>
                              </Form.Group>
                            </Col>
                          </Row>

                          <Row>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Tamanho da Fonte</Form.Label>
                                <Form.Select
                                  value={configAparencia.tamanhoFonte}
                                  onChange={(e) => setConfigAparencia({...configAparencia, tamanhoFonte: e.target.value})}
                                >
                                  <option value="pequeno">Pequeno</option>
                                  <option value="medio">Médio</option>
                                  <option value="grande">Grande</option>
                                </Form.Select>
                              </Form.Group>
                            </Col>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Opções de Interface</Form.Label>
                                <div className="toggle-group">
                                  <Form.Check
                                    type="switch"
                                    label="Animações"
                                    checked={configAparencia.animacoes}
                                    onChange={() => handleToggle('aparencia', 'animacoes')}
                                    className="toggle-item"
                                  />
                                  <Form.Check
                                    type="switch"
                                    label="Sidebar Colapsada"
                                    checked={configAparencia.sidebarColapsada}
                                    onChange={() => handleToggle('aparencia', 'sidebarColapsada')}
                                    className="toggle-item"
                                  />
                                </div>
                              </Form.Group>
                            </Col>
                          </Row>
                        </Form>
                      </div>
                    )}

                    {tabAtiva === 'notificacoes' && (
                      <div className="config-section">
                        <h4 className="section-title">
                          <FaBell className="section-icon" />
                          Notificações
                        </h4>
                        <p className="section-desc">
                          Gerir os canais e tipos de notificação
                        </p>

                        <Form>
                          <h6 className="sub-section-title">Canais de Notificação</h6>
                          <div className="toggle-group">
                            <Form.Check
                              type="switch"
                              label="Email"
                              checked={configNotificacoes.email}
                              onChange={() => handleToggle('notificacoes', 'email')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Push Notification"
                              checked={configNotificacoes.push}
                              onChange={() => handleToggle('notificacoes', 'push')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="SMS"
                              checked={configNotificacoes.sms}
                              onChange={() => handleToggle('notificacoes', 'sms')}
                              className="toggle-item"
                            />
                          </div>

                          <h6 className="sub-section-title mt-4">Eventos</h6>
                          <div className="toggle-group">
                            <Form.Check
                              type="switch"
                              label="Novos Utilizadores"
                              checked={configNotificacoes.novosUtilizadores}
                              onChange={() => handleToggle('notificacoes', 'novosUtilizadores')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Novos Anúncios"
                              checked={configNotificacoes.novosAnuncios}
                              onChange={() => handleToggle('notificacoes', 'novosAnuncios')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Reports e Spam"
                              checked={configNotificacoes.reports}
                              onChange={() => handleToggle('notificacoes', 'reports')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Atualizações do Sistema"
                              checked={configNotificacoes.sistema}
                              onChange={() => handleToggle('notificacoes', 'sistema')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Marketing e Novidades"
                              checked={configNotificacoes.marketing}
                              onChange={() => handleToggle('notificacoes', 'marketing')}
                              className="toggle-item"
                            />
                          </div>
                        </Form>
                      </div>
                    )}

                    {tabAtiva === 'seguranca' && (
                      <div className="config-section">
                        <h4 className="section-title">
                          <FaLock className="section-icon" />
                          Segurança
                        </h4>
                        <p className="section-desc">
                          Configure as políticas de segurança da plataforma
                        </p>

                        <Form>
                          <div className="toggle-group">
                            <Form.Check
                              type="switch"
                              label="Autenticação de Dois Fatores (2FA)"
                              checked={configSeguranca.doisFatores}
                              onChange={() => handleToggle('seguranca', 'doisFatores')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Restrição de IP"
                              checked={configSeguranca.ipRestrito}
                              onChange={() => handleToggle('seguranca', 'ipRestrito')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Logs de Atividade"
                              checked={configSeguranca.logsAtivos}
                              onChange={() => handleToggle('seguranca', 'logsAtivos')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="SSL Forçado (HTTPS)"
                              checked={configSeguranca.sslForcado}
                              onChange={() => handleToggle('seguranca', 'sslForcado')}
                              className="toggle-item"
                            />
                          </div>

                          <Row>
                            <Col md={4}>
                              <Form.Group className="mb-3">
                                <Form.Label>Duração da Sessão (minutos)</Form.Label>
                                <Form.Control
                                  type="number"
                                  value={configSeguranca.sessaoDuracao}
                                  onChange={(e) => setConfigSeguranca({...configSeguranca, sessaoDuracao: parseInt(e.target.value)})}
                                />
                              </Form.Group>
                            </Col>
                            <Col md={4}>
                              <Form.Group className="mb-3">
                                <Form.Label>Tentativas Máximas</Form.Label>
                                <Form.Control
                                  type="number"
                                  value={configSeguranca.tentativasMaximas}
                                  onChange={(e) => setConfigSeguranca({...configSeguranca, tentativasMaximas: parseInt(e.target.value)})}
                                />
                              </Form.Group>
                            </Col>
                            <Col md={4}>
                              <Form.Group className="mb-3">
                                <Form.Label>Bloqueio (minutos)</Form.Label>
                                <Form.Control
                                  type="number"
                                  value={configSeguranca.bloqueioTempo}
                                  onChange={(e) => setConfigSeguranca({...configSeguranca, bloqueioTempo: parseInt(e.target.value)})}
                                />
                              </Form.Group>
                            </Col>
                          </Row>
                        </Form>
                      </div>
                    )}

                    {tabAtiva === 'sistema' && (
                      <div className="config-section">
                        <h4 className="section-title">
                          <FaServer className="section-icon" />
                          Sistema
                        </h4>
                        <p className="section-desc">
                          Configurações avançadas do sistema
                        </p>

                        <Form>
                          <Row>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Cache (segundos)</Form.Label>
                                <Form.Control
                                  type="number"
                                  value={configSistema.cacheTempo}
                                  onChange={(e) => setConfigSistema({...configSistema, cacheTempo: parseInt(e.target.value)})}
                                />
                              </Form.Group>
                            </Col>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Máximo de Anúncios</Form.Label>
                                <Form.Control
                                  type="number"
                                  value={configSistema.maxAnuncios}
                                  onChange={(e) => setConfigSistema({...configSistema, maxAnuncios: parseInt(e.target.value)})}
                                />
                              </Form.Group>
                            </Col>
                          </Row>

                          <div className="toggle-group">
                            <Form.Check
                              type="switch"
                              label="Cache Ativo"
                              checked={configSistema.cacheAtivo}
                              onChange={() => handleToggle('sistema', 'cacheAtivo')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Backup Automático"
                              checked={configSistema.backupAutomatico}
                              onChange={() => handleToggle('sistema', 'backupAutomatico')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Modo Manutenção"
                              checked={configSistema.manutencao}
                              onChange={() => handleToggle('sistema', 'manutencao')}
                              className="toggle-item"
                            />
                          </div>

                          <Form.Group className="mb-3">
                            <Form.Label>Frequência de Backup</Form.Label>
                            <Form.Select
                              value={configSistema.backupFrequencia}
                              onChange={(e) => setConfigSistema({...configSistema, backupFrequencia: e.target.value})}
                            >
                              <option value="horario">A cada hora</option>
                              <option value="diario">Diário</option>
                              <option value="semanal">Semanal</option>
                              <option value="mensal">Mensal</option>
                            </Form.Select>
                          </Form.Group>
                        </Form>
                      </div>
                    )}

                    {tabAtiva === 'comunicacao' && (
                      <div className="config-section">
                        <h4 className="section-title">
                          <FaGlobe className="section-icon" />
                          Comunicação
                        </h4>
                        <p className="section-desc">
                          Configurações de comunicação e modos de entrega
                        </p>

                        <Form>
                          <h6 className="sub-section-title">Modos de Entrega</h6>
                          <div className="toggle-group">
                            <Form.Check
                              type="switch"
                              label="Modo Centralizado"
                              checked={configComunicacao.modoCentralizado}
                              onChange={() => handleToggle('comunicacao', 'modoCentralizado')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Modo Descentralizado (WiFi Direct)"
                              checked={configComunicacao.modoDescentralizado}
                              onChange={() => handleToggle('comunicacao', 'modoDescentralizado')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Modo MULA"
                              checked={configComunicacao.modoMULA}
                              onChange={() => handleToggle('comunicacao', 'modoMULA')}
                              className="toggle-item"
                            />
                          </div>

                          <h6 className="sub-section-title mt-4">Tecnologias</h6>
                          <div className="toggle-group">
                            <Form.Check
                              type="switch"
                              label="WiFi Direct"
                              checked={configComunicacao.wifiDirect}
                              onChange={() => handleToggle('comunicacao', 'wifiDirect')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="Bluetooth"
                              checked={configComunicacao.bluetooth}
                              onChange={() => handleToggle('comunicacao', 'bluetooth')}
                              className="toggle-item"
                            />
                            <Form.Check
                              type="switch"
                              label="GPS"
                              checked={configComunicacao.gps}
                              onChange={() => handleToggle('comunicacao', 'gps')}
                              className="toggle-item"
                            />
                          </div>

                          <Row>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Timeout (segundos)</Form.Label>
                                <Form.Control
                                  type="number"
                                  value={configComunicacao.timeout}
                                  onChange={(e) => setConfigComunicacao({...configComunicacao, timeout: parseInt(e.target.value)})}
                                />
                              </Form.Group>
                            </Col>
                            <Col md={6}>
                              <Form.Group className="mb-3">
                                <Form.Label>Máximo de Tentativas</Form.Label>
                                <Form.Control
                                  type="number"
                                  value={configComunicacao.maxTentativas}
                                  onChange={(e) => setConfigComunicacao({...configComunicacao, maxTentativas: parseInt(e.target.value)})}
                                />
                              </Form.Group>
                            </Col>
                          </Row>
                        </Form>
                      </div>
                    )}
                  </motion.div>
                </AnimatePresence>
              </Card.Body>
            </Card>
          </Col>
        </Row>
      </Container>
    </div>
  );
};

export default Configuracoes;