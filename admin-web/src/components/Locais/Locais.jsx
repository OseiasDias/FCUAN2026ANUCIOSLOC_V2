import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Card, Table, Spinner, Badge, Button, Modal, Form } from 'react-bootstrap';
import { FaTrash, FaPlus, FaEdit, FaMapMarkerAlt } from 'react-icons/fa';
import { soapClient } from '../../api/soapClient';
import toast from 'react-hot-toast';
import './Locais.css';

const Locais = () => {
  const [locais, setLocais] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [novoLocal, setNovoLocal] = useState({ nome: '', latitude: '', longitude: '', capacidade: '' });

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
    if (!window.confirm(`Deseja eliminar o local ${nome}?`)) return;
    
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
    try {
      await soapClient.criarLocal({
        nome: novoLocal.nome,
        latitude: parseFloat(novoLocal.latitude),
        longitude: parseFloat(novoLocal.longitude),
        capacidade: parseInt(novoLocal.capacidade),
      });
      toast.success('Local criado com sucesso');
      setShowModal(false);
      setNovoLocal({ nome: '', latitude: '', longitude: '', capacidade: '' });
      carregarLocais();
    } catch (error) {
      toast.error('Erro ao criar local');
    }
  };

  if (loading) {
    return (
      <div className="d-flex justify-content-center align-items-center" style={{ height: '400px' }}>
        <Spinner animation="border" variant="primary" />
      </div>
    );
  }

  return (
    <div className="locais-container p-4">
      <Container fluid>
        <Row className="mb-4">
          <Col>
            <h2 className="fw-bold mb-1">📍 Locais</h2>
            <p className="text-muted">Gerir todas as infraestruturas da plataforma</p>
          </Col>
          <Col xs="auto" className="d-flex align-items-center">
            <Button variant="primary" onClick={() => setShowModal(true)}>
              <FaPlus className="me-2" />
              Novo Local
            </Button>
          </Col>
        </Row>

        {/* Cards de Locais */}
        <Row className="g-4">
          {locais.map((local) => (
            <Col key={local.id} xs={12} md={6} lg={4}>
              <Card className="shadow-sm h-100 local-card">
                <Card.Body>
                  <div className="d-flex align-items-start justify-content-between mb-2">
                    <div>
                      <FaMapMarkerAlt className="text-primary me-2" />
                      <h5 className="d-inline fw-bold">{local.nome}</h5>
                    </div>
                    <Badge bg="secondary">{local.capacidade || 'N/A'}</Badge>
                  </div>
                  
                  <div className="mt-3">
                    <div className="d-flex gap-2 text-muted small">
                      <span>Lat: {local.latitude || 'N/A'}</span>
                      <span>Lon: {local.longitude || 'N/A'}</span>
                    </div>
                    {local.criador && (
                      <div className="text-muted small mt-1">
                        Criado por: {local.criador}
                      </div>
                    )}
                  </div>

                  <div className="mt-3 d-flex gap-2">
                    <Button
                      variant="outline-danger"
                      size="sm"
                      onClick={() => handleEliminar(local.nome)}
                    >
                      <FaTrash className="me-1" />
                      Eliminar
                    </Button>
                  </div>
                </Card.Body>
              </Card>
            </Col>
          ))}
          {locais.length === 0 && (
            <Col xs={12}>
              <div className="text-center text-muted py-5">
                <h4>Nenhum local cadastrado</h4>
                <p>Clique em "Novo Local" para adicionar uma infraestrutura</p>
              </div>
            </Col>
          )}
        </Row>
      </Container>

      {/* Modal Novo Local */}
      <Modal show={showModal} onHide={() => setShowModal(false)}>
        <Modal.Header closeButton>
          <Modal.Title>Novo Local</Modal.Title>
        </Modal.Header>
        <Form onSubmit={handleCriarLocal}>
          <Modal.Body>
            <Form.Group className="mb-3">
              <Form.Label>Nome</Form.Label>
              <Form.Control
                type="text"
                placeholder="Ex: Belas Shopping"
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
                    placeholder="-8.98"
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
                    placeholder="13.18"
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
                placeholder="100"
                value={novoLocal.capacidade}
                onChange={(e) => setNovoLocal({...novoLocal, capacidade: e.target.value})}
                required
              />
            </Form.Group>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={() => setShowModal(false)}>
              Cancelar
            </Button>
            <Button variant="primary" type="submit">
              Criar Local
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>
    </div>
  );
};

export default Locais;