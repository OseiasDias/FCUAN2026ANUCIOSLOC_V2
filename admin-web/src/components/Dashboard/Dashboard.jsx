import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Card, Table, Spinner } from 'react-bootstrap';
import { soapClient } from '../../api/soapClient';
import StatCard from './StatCard';
import './Dashboard.css';

const Dashboard = () => {
  const [estatisticas, setEstatisticas] = useState(null);
  const [loading, setLoading] = useState(true);
  const [ultimosAnuncios, setUltimosAnuncios] = useState([]);

  useEffect(() => {
    carregarDados();
  }, []);

  const carregarDados = async () => {
    setLoading(true);
    try {
      const stats = await soapClient.getEstatisticas();
      setEstatisticas(stats);
      
      const anuncios = await soapClient.listarAnuncios();
      setUltimosAnuncios(anuncios.slice(0, 5));
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
    }
    setLoading(false);
  };

  if (loading) {
    return (
      <div className="d-flex justify-content-center align-items-center" style={{ height: '400px' }}>
        <Spinner animation="border" variant="primary" />
      </div>
    );
  }

  const stats = [
    { title: 'Utilizadores', value: estatisticas?.totalUtilizadores || 0, icon: 'users', color: 'purple' },
    { title: 'Anúncios', value: estatisticas?.totalAnuncios || 0, icon: 'anuncios', color: 'blue' },
    { title: 'Locais', value: estatisticas?.totalLocais || 0, icon: 'locais', color: 'green' },
    { title: 'Saldo Médio', value: `${estatisticas?.saldoMedio || 0} pts`, icon: 'saldo', color: 'orange' },
  ];

  return (
    <div className="dashboard-container p-4">
      <Container fluid>
        {/* Stats Cards */}
        <Row className="g-4 mb-4">
          {stats.map((stat, index) => (
            <Col key={index} xs={12} sm={6} lg={3}>
              <StatCard {...stat} />
            </Col>
          ))}
        </Row>

        {/* Últimos Anúncios */}
        <Row>
          <Col xs={12}>
            <Card className="shadow-sm">
              <Card.Header className="bg-white fw-bold py-3">
                📋 Últimos Anúncios
              </Card.Header>
              <Card.Body className="p-0">
                <Table responsive hover className="mb-0">
                  <thead className="bg-light">
                    <tr>
                      <th>Conteúdo</th>
                      <th>Autor</th>
                      <th>Local</th>
                      <th>Data</th>
                    </tr>
                  </thead>
                  <tbody>
                    {ultimosAnuncios.map((anuncio) => (
                      <tr key={anuncio.id}>
                        <td>{anuncio.conteudo}</td>
                        <td>{anuncio.autor}</td>
                        <td>{anuncio.local}</td>
                        <td className="text-muted">{anuncio.data}</td>
                      </tr>
                    ))}
                    {ultimosAnuncios.length === 0 && (
                      <tr>
                        <td colSpan="4" className="text-center text-muted py-4">
                          Nenhum anúncio encontrado
                        </td>
                      </tr>
                    )}
                  </tbody>
                </Table>
              </Card.Body>
            </Card>
          </Col>
        </Row>
      </Container>
    </div>
  );
};

export default Dashboard;