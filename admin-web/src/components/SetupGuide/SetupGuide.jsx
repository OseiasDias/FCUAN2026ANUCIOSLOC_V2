import React, { useState } from 'react';
import { Container, Row, Col, Card, Button, Badge, ProgressBar, Alert } from 'react-bootstrap';
import {
  FaCheckCircle, FaArrowRight, FaArrowLeft, FaUsers,
  FaMapMarkerAlt, FaBullhorn, FaCoins, FaServer,
  FaWifi, FaShieldAlt, FaChartLine, FaRocket,
  FaUserCheck, FaPlus, FaEye, FaTrash,
  FaBuilding, FaGlobe, FaClock, FaPlay,
  FaInfoCircle, FaLightbulb, FaQuestionCircle,
  FaDatabase, FaMobile, FaDesktop, FaCloud,
  FaGithub, FaReact, FaJava, FaDocker
} from 'react-icons/fa';
import { motion, AnimatePresence } from 'framer-motion';
import './SetupGuide.css';

const SetupGuide = ({ onComplete }) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [completedSteps, setCompletedSteps] = useState([]);
  const [showTips, setShowTips] = useState(true);

  const steps = [
    {
      id: 'welcome',
      icon: <FaRocket />,
      title: '🚀 Bem-vindo ao AnunciosLoc',
      description: 'O sistema de anúncios baseado em localização mais completo de Angola.',
      color: '#6366F1',
      tips: [
        'Este guia vai ajudá-lo a dominar todas as funcionalidades',
        'Pode voltar a este guia a qualquer momento',
        'Cada passo tem uma explicação detalhada'
      ],
      tasks: [
        { text: 'Conhecer as funcionalidades do sistema', detail: 'Explore todos os módulos disponíveis' },
        { text: 'Configurar os primeiros locais', detail: 'Crie infraestruturas para receber anúncios' },
        { text: 'Gerir utilizadores e anúncios', detail: 'Controle toda a atividade da plataforma' },
        { text: 'Monitorizar estatísticas', detail: 'Acompanhe o desempenho em tempo real' }
      ]
    },
    {
      id: 'locais',
      icon: <FaMapMarkerAlt />,
      title: '📍 Gestão de Locais (Infraestruturas)',
      description: 'Os locais são onde os anúncios são publicados e visualizados.',
      color: '#22C55E',
      tips: [
        'Cada local tem coordenadas GPS (latitude/longitude)',
        'Pode definir o tipo: GPS, WiFi ou BLE',
        'A capacidade define o número máximo de utilizadores'
      ],
      tasks: [
        { text: 'Criar local com coordenadas GPS', detail: 'Ex: -8.98, 13.18 para Belas Shopping' },
        { text: 'Definir capacidade e tipo', detail: 'Capacidade: 100, Tipo: GPS' },
        { text: 'Listar todos os locais cadastrados', detail: 'Visualize todos os locais num só lugar' },
        { text: 'Editar ou eliminar locais', detail: 'Atualize informações ou remova locais' }
      ],
      exemplo: {
        titulo: 'Exemplo de Local',
        campos: [
          { label: 'Nome', valor: 'Belas Shopping' },
          { label: 'Latitude', valor: '-8.98' },
          { label: 'Longitude', valor: '13.18' },
          { label: 'Capacidade', valor: '100' },
          { label: 'Tipo', valor: 'GPS' }
        ]
      },
      actions: [
        { label: 'Criar Local', icon: <FaPlus />, path: '/locais', desc: 'Adicione uma nova infraestrutura' },
        { label: 'Ver Locais', icon: <FaEye />, path: '/locais', desc: 'Lista todas as infraestruturas' }
      ]
    },
    {
      id: 'utilizadores',
      icon: <FaUsers />,
      title: '👥 Gestão de Utilizadores',
      description: 'Controle todos os utilizadores e suas permissões na plataforma.',
      color: '#F59E0B',
      tips: [
        'Cada utilizador tem saldo para publicar anúncios',
        'Pode ativar/desativar contas temporariamente',
        'A eliminação é permanente e irreversível'
      ],
      tasks: [
        { text: 'Visualizar lista completa', detail: 'Veja todos os utilizadores com detalhes' },
        { text: 'Ativar ou desativar contas', detail: 'Controle o acesso dos utilizadores' },
        { text: 'Eliminar utilizadores', detail: 'Remova contas problemáticas' },
        { text: 'Ver detalhes de cada utilizador', detail: 'Aceda a informações completas' }
      ],
      actions: [
        { label: 'Ver Utilizadores', icon: <FaUsers />, path: '/utilizadores', desc: 'Lista de todos os utilizadores' },
        { label: 'Criar Utilizador', icon: <FaUserCheck />, path: '/utilizadores', desc: 'Adicione um novo utilizador' }
      ]
    },
    {
      id: 'anuncios',
      icon: <FaBullhorn />,
      title: '📢 Moderação de Anúncios',
      description: 'Gerir e moderar todos os anúncios publicados na plataforma.',
      color: '#EC4899',
      tips: [
        'Anúncios podem ser filtrados por local ou status',
        'Remove anúncios inapropriados com um clique',
        'Cada anúncio tem um ID único para tracking'
      ],
      tasks: [
        { text: 'Visualizar todos os anúncios', detail: 'Lista completa com filtros' },
        { text: 'Filtrar por local ou status', detail: 'Encontre rapidamente o que procura' },
        { text: 'Remover anúncios inapropriados', detail: 'Mantenha a plataforma limpa' },
        { text: 'Ver detalhes completos', detail: 'Informações detalhadas de cada anúncio' }
      ],
      actions: [
        { label: 'Ver Anúncios', icon: <FaBullhorn />, path: '/anuncios', desc: 'Lista de todos os anúncios' },
        { label: 'Moderar', icon: <FaShieldAlt />, path: '/anuncios', desc: 'Modere o conteúdo' }
      ]
    },
    {
      id: 'dashboard',
      icon: <FaChartLine />,
      title: '📊 Dashboard e Estatísticas',
      description: 'Monitorize o desempenho da plataforma em tempo real.',
      color: '#8B5CF6',
      tips: [
        'Acompanhe métricas como utilizadores ativos e anúncios',
        'Visualize gráficos de evolução mensal',
        'Veja a distribuição de anúncios por local'
      ],
      tasks: [
        { text: 'Visualizar métricas principais', detail: 'Indicadores chave de desempenho' },
        { text: 'Acompanhar evolução de anúncios', detail: 'Gráficos interativos' },
        { text: 'Ver distribuição por local', detail: 'Análise geográfica' },
        { text: 'Monitorizar status dos anúncios', detail: 'Ativos, entregues e expirados' }
      ],
      actions: [
        { label: 'Ver Dashboard', icon: <FaChartLine />, path: '/', desc: 'Painel de controlo' }
      ]
    },
    {
      id: 'modos',
      icon: <FaServer />,
      title: '📡 Modos de Entrega',
      description: 'Compreenda os diferentes modos de entrega do sistema.',
      color: '#06B6D4',
      tips: [
        'Cada modo tem vantagens específicas',
        'O modo centralizado é mais seguro',
        'O modo MULA estende o alcance dos anúncios'
      ],
      tasks: [
        { text: 'Modo Centralizado: via servidor SOAP', detail: 'Persistência em MySQL' },
        { text: 'Modo Descentralizado: WiFi Direct', detail: 'Comunicação P2P' },
        { text: 'Modo MULA: store-and-forward', detail: 'Roteamento inteligente' },
        { text: 'Segurança: autenticação Kerberos', detail: 'Tickets e validação' }
      ]
    },
    {
      id: 'tecnologias',
      icon: <FaDatabase />,
      title: '🛠️ Tecnologias Utilizadas',
      description: 'Conheça a stack tecnológica do sistema AnunciosLoc.',
      color: '#8B5CF6',
      tips: [
        'O backend usa Java com JAX-WS',
        'O frontend usa React com Vite',
        'A app móvel usa Flutter para multiplataforma'
      ],
      tasks: [
        { text: 'Backend: Java 17 + Spring Boot', detail: 'Serviços SOAP e REST' },
        { text: 'Frontend: React 18 + Vite', detail: 'Painel administrativo' },
        { text: 'Mobile: Flutter 3.0+', detail: 'App Android' },
        { text: 'BD: MySQL 8+', detail: 'Persistência de dados' },
        { text: 'DevOps: Docker + Git', detail: 'Deploy e versionamento' }
      ]
    },
    {
      id: 'complete',
      icon: <FaCheckCircle />,
      title: '🎉 Configuração Concluída!',
      description: 'Parabéns! A plataforma AnunciosLoc está pronta para usar.',
      color: '#22C55E',
      tips: [
        'Explore todos os módulos',
        'Acompanhe as estatísticas regularmente',
        'O suporte está disponível para dúvidas'
      ],
      tasks: [
        { text: 'Plataforma configurada com sucesso', detail: 'Todos os módulos prontos' },
        { text: 'Pode começar a gerir a plataforma', detail: 'Explore as funcionalidades' }
      ]
    }
  ];

  const handleNext = () => {
    if (currentStep < steps.length - 1) {
      setCompletedSteps([...completedSteps, currentStep]);
      setCurrentStep(currentStep + 1);
    } else {
      onComplete && onComplete();
    }
  };

  const handlePrevious = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
      setCompletedSteps(completedSteps.filter(s => s !== currentStep - 1));
    }
  };

  const step = steps[currentStep];
  const progress = ((currentStep + 1) / steps.length) * 100;
  const isLastStep = currentStep === steps.length - 1;

  return (
    <div className="setup-guide-container">
      <Container>
        <Row className="justify-content-center">
          <Col lg={10} xl={8}>
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <Card className="setup-card">
                <Card.Body>
                  {/* Progresso */}
                  <div className="setup-progress">
                    <div className="progress-header">
                      <span className="step-indicator">
                        Passo {currentStep + 1} de {steps.length}
                      </span>
                      <span className="step-percent">{Math.round(progress)}%</span>
                    </div>
                    <ProgressBar 
                      now={progress} 
                      className="setup-progress-bar"
                      variant="primary"
                    />
                    <div className="step-dots">
                      {steps.map((_, index) => (
                        <div
                          key={index}
                          className={`step-dot ${index === currentStep ? 'active' : ''} ${completedSteps.includes(index) ? 'completed' : ''}`}
                          onClick={() => {
                            if (completedSteps.includes(index) || index === currentStep) {
                              setCurrentStep(index);
                            }
                          }}
                        />
                      ))}
                    </div>
                  </div>

                  {/* Conteúdo */}
                  <AnimatePresence mode="wait">
                    <motion.div
                      key={currentStep}
                      initial={{ opacity: 0, x: 20 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -20 }}
                      transition={{ duration: 0.3 }}
                      className="step-content"
                    >
                      <div className="step-header">
                        <div 
                          className="step-icon-wrapper"
                          style={{ backgroundColor: step.color + '20', color: step.color }}
                        >
                          {step.icon}
                        </div>
                        <div>
                          <h3 className="step-title">{step.title}</h3>
                          <p className="step-description">{step.description}</p>
                        </div>
                      </div>

                      {/* Dicas */}
                      {step.tips && (
                        <Alert variant="info" className="step-tips">
                          <div className="tips-header">
                            <FaLightbulb className="tips-icon" />
                            <span>Dicas importantes</span>
                          </div>
                          <ul className="tips-list">
                            {step.tips.map((tip, index) => (
                              <li key={index}>{tip}</li>
                            ))}
                          </ul>
                        </Alert>
                      )}

                      {/* Tarefas */}
                      <div className="step-tasks">
                        <h6 className="tasks-title">
                          <FaInfoCircle className="tasks-icon" />
                          O que vai aprender:
                        </h6>
                        {step.tasks.map((task, index) => (
                          <div key={index} className="task-item">
                            <div className="task-check">
                              <FaCheckCircle className="task-check-icon" />
                            </div>
                            <div className="task-content">
                              <span className="task-text">{task.text}</span>
                              <span className="task-detail">{task.detail}</span>
                            </div>
                          </div>
                        ))}
                      </div>

                      {/* Exemplo */}
                      {step.exemplo && (
                        <div className="step-example">
                          <h6 className="example-title">
                            <FaGlobe className="example-icon" />
                            {step.exemplo.titulo}
                          </h6>
                          <div className="example-grid">
                            {step.exemplo.campos.map((campo, index) => (
                              <div key={index} className="example-item">
                                <span className="example-label">{campo.label}</span>
                                <span className="example-value">{campo.valor}</span>
                              </div>
                            ))}
                          </div>
                        </div>
                      )}

                      {/* Modos de Entrega */}
                      {step.id === 'modos' && (
                        <div className="modos-grid">
                          <div className="modo-card centralizado">
                            <FaServer className="modo-icon" />
                            <h6>Centralizado</h6>
                            <p>Via servidor SOAP com persistência MySQL</p>
                            <span className="modo-tag">Seguro</span>
                          </div>
                          <div className="modo-card descentralizado">
                            <FaWifi className="modo-icon" />
                            <h6>Descentralizado</h6>
                            <p>WiFi Direct entre dispositivos</p>
                            <span className="modo-tag">Rápido</span>
                          </div>
                          <div className="modo-card mula">
                            <FaShieldAlt className="modo-icon" />
                            <h6>Modo MULA</h6>
                            <p>Store-and-forward com caching</p>
                            <span className="modo-tag">Eficiente</span>
                          </div>
                        </div>
                      )}

                      {/* Tecnologias */}
                      {step.id === 'tecnologias' && (
                        <div className="tecnologias-grid">
                          <div className="tech-card">
                            <FaJava className="tech-icon" style={{ color: '#007396' }} />
                            <h6>Backend</h6>
                            <p>Java 17, Spring Boot, JAX-WS</p>
                          </div>
                          <div className="tech-card">
                            <FaReact className="tech-icon" style={{ color: '#61DAFB' }} />
                            <h6>Frontend</h6>
                            <p>React 18, Vite, Bootstrap 5</p>
                          </div>
                          <div className="tech-card">
                            <FaMobile className="tech-icon" style={{ color: '#02569B' }} />
                            <h6>Mobile</h6>
                            <p>Flutter 3.0+, Dart</p>
                          </div>
                          <div className="tech-card">
                            <FaDatabase className="tech-icon" style={{ color: '#4479A1' }} />
                            <h6>BD</h6>
                            <p>MySQL 8+, JDBC</p>
                          </div>
                          <div className="tech-card">
                            <FaDocker className="tech-icon" style={{ color: '#2496ED' }} />
                            <h6>DevOps</h6>
                            <p>Docker, Git, Maven</p>
                          </div>
                          <div className="tech-card">
                            <FaCloud className="tech-icon" style={{ color: '#6366F1' }} />
                            <h6>Arquitetura</h6>
                            <p>Microserviços, SOAP, REST</p>
                          </div>
                        </div>
                      )}

                      {/* Ações */}
                      {step.actions && (
                        <div className="step-actions">
                          <h6 className="actions-label">
                            <FaPlay className="actions-icon" />
                            Ações Recomendadas:
                          </h6>
                          <div className="actions-grid">
                            {step.actions.map((action, index) => (
                              <Button
                                key={index}
                                variant="outline-primary"
                                className="action-btn"
                                href={action.path}
                              >
                                {action.icon}
                                <div className="action-info">
                                  <span>{action.label}</span>
                                  <small>{action.desc}</small>
                                </div>
                                <FaArrowRight className="action-arrow" />
                              </Button>
                            ))}
                          </div>
                        </div>
                      )}

                      {isLastStep && (
                        <div className="completion-message">
                          <div className="completion-icon">
                            <FaCheckCircle />
                          </div>
                          <h4>🎉 Sistema pronto para uso!</h4>
                          <p>
                            A plataforma AnunciosLoc está totalmente configurada.
                            Comece a gerir locais, utilizadores e anúncios agora mesmo.
                          </p>
                          <div className="quick-stats">
                            <div className="quick-stat">
                              <span className="stat-number">8</span>
                              <span className="stat-label">Passos</span>
                            </div>
                            <div className="quick-stat">
                              <span className="stat-number">4</span>
                              <span className="stat-label">Módulos</span>
                            </div>
                            <div className="quick-stat">
                              <span className="stat-number">3</span>
                              <span className="stat-label">Modos</span>
                            </div>
                          </div>
                        </div>
                      )}
                    </motion.div>
                  </AnimatePresence>

                  {/* Navegação */}
                  <div className="step-navigation">
                    <Button
                      variant="outline-secondary"
                      onClick={handlePrevious}
                      disabled={currentStep === 0}
                      className="nav-btn prev-btn"
                    >
                      <FaArrowLeft />
                      Anterior
                    </Button>

                    <Button
                      variant="primary"
                      onClick={handleNext}
                      className="nav-btn next-btn"
                    >
                      {isLastStep ? (
                        <>
                          <FaCheckCircle />
                          Concluir
                        </>
                      ) : (
                        <>
                          Continuar
                          <FaArrowRight />
                        </>
                      )}
                    </Button>
                  </div>
                </Card.Body>
              </Card>
            </motion.div>
          </Col>
        </Row>
      </Container>
    </div>
  );
};

export default SetupGuide;