import axios from 'axios';
import { SOAP_API_URL, NAMESPACE } from '../utils/constants';

// Função para criar envelope SOAP
const createSoapEnvelope = (method, params) => {
  let body = `<ns:${method}>`;
  
  for (const [key, value] of Object.entries(params)) {
    body += `<${key}>${value}</${key}>`;
  }
  
  body += `</ns:${method}>`;
  
  return `<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:ns="${NAMESPACE}">
      <soap:Body>
        ${body}
      </soap:Body>
    </soap:Envelope>`;
};

// Função para extrair resposta SOAP
const extractResponse = (xml, tag) => {
  const regex = new RegExp(`<${tag}>(.*?)</${tag}>`, 's');
  const match = xml.match(regex);
  return match ? match[1].trim() : null;
};

// Função para extrair lista de utilizadores
const extractUtilizadores = (xml) => {
  // Simula dados - substituir com parsing real
  return [
    { email: 'admin@anunciosloc.com', nome: 'Administrador', saldo: 1000, ativo: true, dataRegisto: '2026-01-01' },
    { email: 'joao@gmail.com', nome: 'João Silva', saldo: 85, ativo: true, dataRegisto: '2026-06-01' },
    { email: 'maria@gmail.com', nome: 'Maria Santos', saldo: 120, ativo: true, dataRegisto: '2026-06-15' },
    { email: 'pedro@gmail.com', nome: 'Pedro Costa', saldo: 45, ativo: false, dataRegisto: '2026-05-20' },
  ];
};

// Função para extrair anúncios
const extractAnuncios = (xml) => {
  return [
    { id: '1', conteudo: 'Vendo carro Toyota Corolla 2022', autor: 'joao@gmail.com', local: 'Belas Shopping', data: '2026-06-25 14:30' },
    { id: '2', conteudo: 'Alugo T2 mobiliado perto da Talatona', autor: 'maria@gmail.com', local: 'Talatona', data: '2026-06-24 10:15' },
    { id: '3', conteudo: 'Vaga para motorista com experiência', autor: 'pedro@gmail.com', local: 'Kilamba', data: '2026-06-23 09:00' },
    { id: '4', conteudo: 'Vendo iPhone 13 Pro Max 256GB', autor: 'joao@gmail.com', local: 'Belas Shopping', data: '2026-06-22 16:45' },
  ];
};

// Função para extrair locais
const extractLocais = (xml) => {
  return [
    { id: 1, nome: 'Belas Shopping', latitude: -8.98, longitude: 13.18, capacidade: 100, criador: 'admin@anunciosloc.com' },
    { id: 2, nome: 'Talatona', latitude: -8.89, longitude: 13.20, capacidade: 50, criador: 'admin@anunciosloc.com' },
    { id: 3, nome: 'Kilamba', latitude: -9.00, longitude: 13.30, capacidade: 80, criador: 'admin@anunciosloc.com' },
  ];
};

// Função para extrair estatísticas
const extractEstatisticas = (xml) => {
  return {
    totalUtilizadores: 150,
    utilizadoresAtivos: 120,
    totalAnuncios: 320,
    anunciosHoje: 15,
    totalLocais: 12,
    saldoMedio: 45.2,
  };
};

// Cliente SOAP
export const soapClient = {
  // ============ UTILIZADORES ============
  
  listarUtilizadores: async () => {
    const envelope = createSoapEnvelope('listarTodosUtilizadores', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractUtilizadores(response.data);
  },
  
  desativarUtilizador: async (email) => {
    const envelope = createSoapEnvelope('desativarUtilizadorAdmin', { email });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractResponse(response.data, 'return');
  },
  
  ativarUtilizador: async (email) => {
    const envelope = createSoapEnvelope('ativarUtilizadorAdmin', { email });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractResponse(response.data, 'return');
  },
  
  eliminarUtilizador: async (email) => {
    const envelope = createSoapEnvelope('eliminarUtilizadorAdmin', { email });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractResponse(response.data, 'return');
  },
  
  // ============ ANÚNCIOS ============
  
  listarAnuncios: async () => {
    const envelope = createSoapEnvelope('listarTodosAnuncios', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractAnuncios(response.data);
  },
  
  removerAnuncio: async (id) => {
    const envelope = createSoapEnvelope('removerAnuncioAdmin', { id });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractResponse(response.data, 'return');
  },
  
  // ============ LOCAIS ============
  
  listarLocais: async () => {
    const envelope = createSoapEnvelope('listarTodosLocais', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractLocais(response.data);
  },
  
  criarLocal: async (local) => {
    const envelope = createSoapEnvelope('criarLocalAdmin', local);
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractResponse(response.data, 'return');
  },
  
  eliminarLocal: async (nome) => {
    const envelope = createSoapEnvelope('eliminarLocalAdmin', { nome });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractResponse(response.data, 'return');
  },
  
  // ============ ESTATÍSTICAS ============
  
  getEstatisticas: async () => {
    const envelope = createSoapEnvelope('getEstatisticas', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
    });
    return extractEstatisticas(response.data);
  },
};