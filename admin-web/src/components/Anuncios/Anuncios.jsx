import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Card, Table, Spinner, Badge, Button } from 'react-bootstrap';
import { FaTrash, FaSearch } from 'react-icons/fa';
import { soapClient } from '../../api/soapClient';
import toast from 'react-hot-toast';
import './Anuncios.css';

const Anuncios = () => {
  const [anuncios, setAnuncios] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    carregarAnuncios();
  }, []);

  const carregarAnuncios = async () => {
    setLoading(true);
    try {
      const data = await soapClient.listarAnuncios();
      setAnuncios(data);
    } catch (error) {
      toast.error('Erro ao carregar anúncios');
    }
    setLoading(false);
  };

  const handleRemover = async (id) => {
    if (!window.confirm(`Deseja remover este anúncio?`)) return;
    
    try {
      await soapClient.removerAnuncio(id);
      toast.success('Anúncio removido com sucesso');
      carregarAnuncios();
    } catch (error) {
      toast.error('Erro ao remover anúncio');
    }
  };

  const filteredAnuncios = anuncios.filter(anuncio =>
    anuncio.conteudo.toLowerCase().includes(searchTerm.toLowerCase()) ||
    anuncio.autor.toLowerCase().includes(searchTerm.toLowerCase()) ||
    anuncio.local.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <div className="d-flex justify-content-center align-items-center" style={{ height: '400px' }}>
        <Spinner animation="border" variant="primary" />
      </div>
    );
  }

  return (
    <div className="anuncios-container p-4">
      <Container fluid>
        <Row className="mb-4">
          <Col>
            <h2 className="fw-bold mb-1">📢 Anúncios</h2>
            <p className="text-muted">Gerir todos os anúncios da plataforma</p>
          </Col>
          <Col xs="auto" className="d-flex align-items-center">
            <Badge bg="primary" className="p-2 px-3">
              Total: {anuncios.length}
            </Badge>
          </Col>
        </Row>

        {/* Barra de pesquisa */}
        <Row className="mb-4">
          <Col md={6} lg={4}>
            <div className="input-group">
              <span className="input-group-text"><FaSearch /></span>
              <input
                type="text"
                className="form-control"
                placeholder="Pesquisar anúncios..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </Col>
        </Row>

        {/* Tabela */}
        <Card className="shadow-sm">
          <Card.Body className="p-0">
            <Table responsive hover className="mb-0">
              <thead className="bg-light">
                <tr>
                  <th>Conteúdo</th>
                  <th>Autor</th>
                  <th>Local</th>
                  <th>Data</th>
                  <th className="text-center">Ações</th>
                </tr>
              </thead>
              <tbody>
                {filteredAnuncios.map((anuncio) => (
                  <tr key={anuncio.id}>
                    <td className="fw-medium">{anuncio.conteudo}</td>
                    <td>{anuncio.autor}</td>
                    <td>
                      <Badge bg="info" text="dark">
                        {anuncio.local}
                      </Badge>
                    </td>
                    <td className="text-muted">{anuncio.data}</td>
                    <td>
                      <div className="d-flex justify-content-center">
                        <Button
                          variant="outline-danger"
                          size="sm"
                          onClick={() => handleRemover(anuncio.id)}
                          title="Remover anúncio"
                        >
                          <FaTrash />
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
                {filteredAnuncios.length === 0 && (
                  <tr>
                    <td colSpan="5" className="text-center text-muted py-4">
                      Nenhum anúncio encontrado
                    </td>
                  </tr>
                )}
              </tbody>
            </Table>
          </Card.Body>
        </Card>
      </Container>
    </div>
  );
};

export default Anuncios;