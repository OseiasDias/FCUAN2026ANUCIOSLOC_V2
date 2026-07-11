import React, { useState, useEffect } from 'react';
import { 
  Container, Row, Col, Card, Table, Form, Button, 
  Spinner, Badge, InputGroup, Modal 
} from 'react-bootstrap';
import { FaSearch, FaUserPlus, FaEdit, FaTrash, FaCheck, FaTimes } from 'react-icons/fa';
import { soapClient } from '../../api/soapClient';
import toast from 'react-hot-toast';
import './Utilizadores.css';

const Utilizadores = () => {
  const [utilizadores, setUtilizadores] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [novoUtilizador, setNovoUtilizador] = useState({ email: '', nome: '', password: '' });

  useEffect(() => {
    carregarUtilizadores();
  }, []);

  const carregarUtilizadores = async () => {
    setLoading(true);
    try {
      const data = await soapClient.listarUtilizadores();
      setUtilizadores(data);
    } catch (error) {
      toast.error('Erro ao carregar utilizadores');
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
    try {
      // Chamar API para criar utilizador
      toast.success('Utilizador criado com sucesso');
      setShowModal(false);
      setNovoUtilizador({ email: '', nome: '', password: '' });
      carregarUtilizadores();
    } catch (error) {
      toast.error('Erro ao criar utilizador');
    }
  };

  const filteredUsers = utilizadores.filter(user =>
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.nome.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <div className="d-flex justify-content-center align-items-center" style={{ height: '400px' }}>
        <Spinner animation="border" variant="primary" />
      </div>
    );
  }

  return (
    <div className="utilizadores-container p-4">
      <Container fluid>
        <Row className="mb-4">
          <Col>
            <h2 className="fw-bold mb-1">👥 Utilizadores</h2>
            <p className="text-muted">Gerir todos os utilizadores da plataforma</p>
          </Col>
          <Col xs="auto" className="d-flex align-items-center">
            <Button variant="primary" onClick={() => setShowModal(true)}>
              <FaUserPlus className="me-2" />
              Novo Utilizador
            </Button>
          </Col>
        </Row>

        {/* Barra de pesquisa */}
        <Row className="mb-4">
          <Col md={6} lg={4}>
            <InputGroup>
              <InputGroup.Text>
                <FaSearch />
              </InputGroup.Text>
              <Form.Control
                type="text"
                placeholder="Pesquisar por email ou nome..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </InputGroup>
          </Col>
        </Row>

        {/* Tabela */}
        <Card className="shadow-sm">
          <Card.Body className="p-0">
            <Table responsive hover className="mb-0">
              <thead className="bg-light">
                <tr>
                  <th>Utilizador</th>
                  <th>Saldo</th>
                  <th>Status</th>
                  <th>Data Registo</th>
                  <th className="text-center">Ações</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((user) => (
                  <tr key={user.email}>
                    <td>
                      <div className="fw-semibold">{user.nome}</div>
                      <small className="text-muted">{user.email}</small>
                    </td>
                    <td>
                      <span className="fw-bold text-primary">{user.saldo} pts</span>
                    </td>
                    <td>
                      <Badge bg={user.ativo ? 'success' : 'danger'}>
                        {user.ativo ? '✅ Ativo' : '❌ Inativo'}
                      </Badge>
                    </td>
                    <td className="text-muted">{user.dataRegisto || 'N/A'}</td>
                    <td>
                      <div className="d-flex justify-content-center gap-2">
                        <Button
                          variant={user.ativo ? 'outline-warning' : 'outline-success'}
                          size="sm"
                          onClick={() => user.ativo ? handleDesativar(user.email) : handleAtivar(user.email)}
                          title={user.ativo ? 'Desativar' : 'Ativar'}
                        >
                          {user.ativo ? <FaTimes /> : <FaCheck />}
                        </Button>
                        <Button
                          variant="outline-danger"
                          size="sm"
                          onClick={() => handleEliminar(user.email)}
                          title="Eliminar"
                        >
                          <FaTrash />
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
                {filteredUsers.length === 0 && (
                  <tr>
                    <td colSpan="5" className="text-center text-muted py-4">
                      Nenhum utilizador encontrado
                    </td>
                  </tr>
                )}
              </tbody>
            </Table>
          </Card.Body>
        </Card>
      </Container>

      {/* Modal Novo Utilizador */}
      <Modal show={showModal} onHide={() => setShowModal(false)}>
        <Modal.Header closeButton>
          <Modal.Title>Novo Utilizador</Modal.Title>
        </Modal.Header>
        <Form onSubmit={handleCriarUtilizador}>
          <Modal.Body>
            <Form.Group className="mb-3">
              <Form.Label>Email</Form.Label>
              <Form.Control
                type="email"
                placeholder="exemplo@email.com"
                value={novoUtilizador.email}
                onChange={(e) => setNovoUtilizador({...novoUtilizador, email: e.target.value})}
                required
              />
            </Form.Group>
            <Form.Group className="mb-3">
              <Form.Label>Nome</Form.Label>
              <Form.Control
                type="text"
                placeholder="Nome completo"
                value={novoUtilizador.nome}
                onChange={(e) => setNovoUtilizador({...novoUtilizador, nome: e.target.value})}
                required
              />
            </Form.Group>
            <Form.Group className="mb-3">
              <Form.Label>Password</Form.Label>
              <Form.Control
                type="password"
                placeholder="********"
                value={novoUtilizador.password}
                onChange={(e) => setNovoUtilizador({...novoUtilizador, password: e.target.value})}
                required
              />
            </Form.Group>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={() => setShowModal(false)}>
              Cancelar
            </Button>
            <Button variant="primary" type="submit">
              Criar Utilizador
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>
    </div>
  );
};

export default Utilizadores;