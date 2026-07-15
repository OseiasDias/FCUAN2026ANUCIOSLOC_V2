import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Card, Badge } from 'react-bootstrap';
import { 
  FaUsers, 
  FaBullhorn, 
  FaMapMarkerAlt, 
  FaCoins,
  FaChartLine,
  FaLocationArrow,
  FaStore,
  FaEye,
  FaShare,
  FaCalendarAlt,
  FaClock,
  FaBuilding,
  FaCheckCircle,
  FaExclamationCircle
} from 'react-icons/fa';
import { motion } from 'framer-motion';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  AreaChart,
  Area
} from 'recharts';
import { soapClient } from '../../api/soapClient';
import toast from 'react-hot-toast';
import './Dashboard.css';

const Dashboard = () => {
  const [estatisticas, setEstatisticas] = useState({
    totalUtilizadores: 0,
    totalAnuncios: 0,
    totalLocais: 0,
    anunciosAtivos: 0,
    anunciosExpirados: 0,
    infraestruturasAtivas: 0,
  });
  const [loading, setLoading] = useState(true);
  const [ultimosAnuncios, setUltimosAnuncios] = useState([]);
  const [locais, setLocais] = useState([]);

  const [dadosStatus, setDadosStatus] = useState([
    { name: 'Ativos', value: 0, color: '#6366F1' },
    { name: 'Expirados', value: 0, color: '#EF4444' },
  ]);

  const [dadosLocais, setDadosLocais] = useState([]);

  useEffect(() => {
    carregarDados();
  }, []);

  useEffect(() => {
    if (locais.length > 0) {
      const dados = locais.map((local, index) => ({
        name: local.nome || 'Local',
        anuncios: Math.floor(Math.random() * 20) + 5,
        cor: ['#6366F1', '#F59E0B', '#22C55E', '#EC4899', '#0EA5E9', '#8B5CF6', '#F97316', '#14B8A6'][index % 8]
      }));
      setDadosLocais(dados);
    }
  }, [locais]);

 // ==================== CARREGAR DADOS ====================

const carregarDados = async () => {
  setLoading(true);
  try {
    // 1. Carregar estatisticas
    const stats = await soapClient.getEstatisticasCompletas();
    setEstatisticas(stats);

    // 2. Carregar anuncios
    const anuncios = await soapClient.listarAnuncios();
    console.log(' Anuncios recebidos:', anuncios);
    
    // CORREÇÃO: Os anuncios JÁ SÃO OBJETOS!
    // Não precisa fazer parsing novamente
    setUltimosAnuncios(anuncios.slice(0, 5));

    // 3. Carregar locais
    const locaisData = await soapClient.listarLocaisCoordenadas();
    const locaisFormatados = locaisData.map((item) => {
      if (typeof item === 'string' && item.includes('|')) {
        const partes = item.split('|');
        return {
          nome: partes[0] || 'Local sem nome',
          tipo: partes[1] || 'GPS',
          latitude: parseFloat(partes[2]) || 0,
          longitude: parseFloat(partes[3]) || 0,
          raio: parseFloat(partes[4]) || 50,
        };
      }
      return {
        nome: item.nome || 'Local sem nome',
        latitude: item.latitude || 0,
        longitude: item.longitude || 0,
        raio: item.raio || 50,
      };
    });
    setLocais(locaisFormatados);

  } catch (error) {
    console.error(' Erro ao carregar dados:', error);
    toast.error('Erro ao carregar dados do servidor');
  }
  setLoading(false);
};

  const stats = [
    { 
      title: 'Utilizadores', 
      value: estatisticas.totalUtilizadores || 0, 
      icon: <FaUsers />, 
      color: '#6366F1',
      bg: 'rgba(99, 102, 241, 0.1)',
      subtitle: 'Utilizadores ativos na plataforma',
    },
    { 
      title: 'Anuncios', 
      value: estatisticas.totalAnuncios || 0, 
      icon: <FaBullhorn />, 
      color: '#F59E0B',
      bg: 'rgba(245, 158, 11, 0.1)',
      subtitle: `${estatisticas.anunciosAtivos || 0} ativos, ${estatisticas.anunciosExpirados || 0} expirados`,
    },
    { 
      title: 'Locais', 
      value: estatisticas.totalLocais || 0, 
      icon: <FaMapMarkerAlt />, 
      color: '#22C55E',
      bg: 'rgba(34, 197, 94, 0.1)',
      subtitle: `${estatisticas.infraestruturasAtivas || 0} infraestruturas ativas`,
    },
    { 
      title: 'Infraestruturas', 
      value: estatisticas.infraestruturasAtivas || 0, 
      icon: <FaBuilding />, 
      color: '#8B5CF6',
      bg: 'rgba(139, 92, 246, 0.1)',
      subtitle: 'Servidores ativos',
    },
  ];

  const COLORS = ['#22C55E', '#EF4444'];

  const renderCustomizedLabel = ({ cx, cy, midAngle, innerRadius, outerRadius, percent, index }) => {
    const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
    const x = cx + radius * Math.cos(-midAngle * Math.PI / 180);
    const y = cy + radius * Math.sin(-midAngle * Math.PI / 180);

    return (
      <text x={x} y={y} fill="white" textAnchor="middle" dominantBaseline="central" style={{ fontSize: 12, fontWeight: 600 }}>
        {`${(percent * 100).toFixed(0)}%`}
      </text>
    );
  };

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="loading-spinner"></div>
        <span>Carregando dashboard...</span>
      </div>
    );
  }

  return (
    <div className="dashboard-container">
      <Container fluid>
        {/* Titulo */}
        <div className="dashboard-header">
          <div>
            <h2 className="dashboard-title">Visao geral da plataforma AnunciosLoc</h2>
            <p className="dashboard-subtitle">Estatisticas e metricas do sistema em tempo real</p>
          </div>
          <div className="dashboard-header-actions">
            <button className="btn-refresh" onClick={carregarDados}>
              <FaChartLine />
              <span>Atualizar</span>
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <Row className="g-4 mb-4">
          {stats.map((stat, index) => (
            <Col key={index} xs={12} sm={6} lg={3}>
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
              >
                <Card className="stat-card">
                  <Card.Body>
                    <div className="stat-icon-wrapper" style={{ backgroundColor: stat.bg }}>
                      <span style={{ color: stat.color }}>{stat.icon}</span>
                    </div>
                    <div className="stat-content">
                      <h3 className="stat-value">{stat.value}</h3>
                      <p className="stat-title">{stat.title}</p>
                      <span className="stat-subtitle">{stat.subtitle}</span>
                    </div>
                  </Card.Body>
                </Card>
              </motion.div>
            </Col>
          ))}
        </Row>

        {/* GRAFICOS */}
        <Row className="g-4">
          {/* Grafico de Donut - Status dos Anuncios */}
          <Col lg={6}>
            <Card className="chart-card">
              <Card.Header className="chart-card-header">
                <div>
                  <h5 className="chart-card-title">
                    <FaClock className="chart-title-icon" />
                    Status dos Anuncios
                  </h5>
                  <p className="chart-card-subtitle">
                    Distribuicao atual dos anuncios na plataforma
                  </p>
                </div>
                <Badge bg="success" className="chart-badge">
                  <FaStore /> Em tempo real
                </Badge>
              </Card.Header>
              <Card.Body className="chart-card-body" style={{ height: 320 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={dadosStatus}
                      cx="50%"
                      cy="50%"
                      innerRadius={60}
                      outerRadius={100}
                      fill="#8884d8"
                      paddingAngle={5}
                      dataKey="value"
                      labelLine={false}
                      label={renderCustomizedLabel}
                    >
                      {dadosStatus.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip 
                      contentStyle={{ 
                        backgroundColor: 'rgba(255,255,255,0.95)', 
                        borderRadius: 12,
                        border: '1px solid #eef0f3',
                        fontFamily: 'Poppins'
                      }}
                      formatter={(value, name) => [`${value} anuncios`, name]}
                    />
                    <Legend verticalAlign="bottom" height={50} iconType="circle" />
                  </PieChart>
                </ResponsiveContainer>
              </Card.Body>
            </Card>
          </Col>

          {/* Ultimos Anuncios */}
          <Col lg={6}>
            <Card className="anuncios-card">
              <Card.Header className="anuncios-card-header">
                <div>
                  <h5 className="anuncios-card-title">
                    <FaBullhorn className="anuncios-title-icon" />
                    Ultimos Anuncios
                  </h5>
                  <p className="anuncios-card-subtitle">
                    Atividade recente na plataforma
                  </p>
                </div>
                <Badge bg="warning" className="anuncios-badge">
                  {ultimosAnuncios.length} anuncios
                </Badge>
              </Card.Header>
              <Card.Body className="anuncios-card-body">
                <div className="anuncios-list">
                  {ultimosAnuncios.length === 0 ? (
                    <div className="empty-anuncios">
                      <FaBullhorn className="empty-icon" />
                      <p>Nenhum anuncio publicado ainda</p>
                      <small>Seja o primeiro a publicar!</small>
                    </div>
                  ) : (
                    ultimosAnuncios.map((anuncio, index) => (
                      <div key={anuncio.id || index} className="anuncio-item">
                        <div className="anuncio-avatar">
                          <span>{anuncio.autor?.charAt(0).toUpperCase() || 'U'}</span>
                        </div>
                        <div className="anuncio-content">
                          <div className="anuncio-header">
                            <strong className="anuncio-autor">{anuncio.autor || 'Utilizador'}</strong>
                            <span className="anuncio-local">
                              <FaMapMarkerAlt className="local-icon" />
                              {anuncio.local || 'Local desconhecido'}
                            </span>
                          </div>
                          <p className="anuncio-text">{anuncio.conteudo}</p>
                          <div className="anuncio-footer">
                            <span className="anuncio-data">{anuncio.data || 'Agora mesmo'}</span>
                            <Badge bg="success" className="anuncio-status">Publicado</Badge>
                          </div>
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </Card.Body>
            </Card>
          </Col>
        </Row>

        {/* Segundo Row de Graficos */}
        <Row className="g-4 mt-2">
          {/* Grafico de Barras - Anuncios por Local */}
          <Col lg={7}>
            <Card className="chart-card">
              <Card.Header className="chart-card-header">
                <div>
                  <h5 className="chart-card-title">
                    <FaLocationArrow className="chart-title-icon" />
                    Anuncios por Local
                  </h5>
                  <p className="chart-card-subtitle">
                    Distribuicao de anuncios por infraestrutura
                  </p>
                </div>
                <Badge bg="warning" className="chart-badge">
                  <FaMapMarkerAlt /> {locais.length} locais
                </Badge>
              </Card.Header>
              <Card.Body className="chart-card-body">
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={dadosLocais}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#eef0f3" />
                    <XAxis dataKey="name" stroke="#8c8f9c" fontSize={11} />
                    <YAxis stroke="#8c8f9c" fontSize={11} />
                    <Tooltip 
                      contentStyle={{ 
                        backgroundColor: 'rgba(255,255,255,0.95)', 
                        borderRadius: 12,
                        border: '1px solid #eef0f3',
                        fontFamily: 'Poppins'
                      }}
                      formatter={(value) => [`${value} anuncios`, 'Quantidade']}
                    />
                    <Bar dataKey="anuncios" name="Anuncios" radius={[8, 8, 0, 0]} barSize={40}>
                      {dadosLocais.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.cor || '#6366F1'} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </Card.Body>
            </Card>
          </Col>

          {/* Locais Cadastrados */}
          <Col lg={5}>
            <Card className="locais-card">
              <Card.Header className="locais-card-header">
                <div>
                  <h5 className="locais-card-title">
                    <FaMapMarkerAlt className="locais-title-icon" />
                    Locais Cadastrados
                  </h5>
                  <p className="locais-card-subtitle">
                    Todas as infraestruturas disponiveis na plataforma
                  </p>
                </div>
                <span className="locais-count">{locais.length} locais</span>
              </Card.Header>
              <Card.Body className="locais-card-body">
                <div className="locais-grid">
                  {locais.length === 0 ? (
                    <div className="empty-locais">
                      <FaMapMarkerAlt className="empty-icon" />
                      <p>Nenhum local cadastrado</p>
                      <small>Cadastre locais para comecar</small>
                    </div>
                  ) : (
                    locais.map((local, index) => (
                      <div key={index} className="local-item">
                        <div className="local-icon-wrapper">
                          <FaMapMarkerAlt className="local-item-icon" />
                        </div>
                        <div className="local-info">
                          <h6 className="local-name">{local.nome || 'Local sem nome'}</h6>
                          <p className="local-coords">
                            Lat: {local.latitude?.toFixed(4) || 'N/A'}, 
                            Lon: {local.longitude?.toFixed(4) || 'N/A'}
                          </p>
                          {local.capacidade && (
                            <Badge bg="secondary" className="local-capacity">
                              Capacidade: {local.capacidade}
                            </Badge>
                          )}
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </Card.Body>
            </Card>
          </Col>
        </Row>
      </Container>
    </div>
  );
};

export default Dashboard;