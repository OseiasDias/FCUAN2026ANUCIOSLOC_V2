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
  const regex = new RegExp(`<return>(.*?)</return>`, 's');
  const match = xml.match(regex);
  return match ? match[1].trim() : null;
};

// Função para extrair valor inteiro da resposta SOAP
const extractInt = (xml) => {
  const regex = /<return>(\d+)<\/return>/;
  const match = xml.match(regex);
  return match ? parseInt(match[1]) : 0;
};

// Função para extrair lista de itens (simplificada)
const extractList = (xml, itemTag) => {
  const items = [];
  const regex = new RegExp(`<${itemTag}>(.*?)</${itemTag}>`, 'gs');
  let match;
  while ((match = regex.exec(xml)) !== null) {
    items.push(match[1].trim());
  }
  return items;
};

// Função para extrair estatísticas completas
const extractEstatisticasCompletas = (xml) => {
  const texto = extractResponse(xml, 'return') || '';
  const stats = {};
  
  // Extrair valores do texto formatado
  const lines = texto.split('\n');
  for (const line of lines) {
    if (line.includes('Utilizadores ativos:')) {
      stats.totalUtilizadores = parseInt(line.match(/\d+/)?.[0] || 0);
    } else if (line.includes('Total de anuncios:')) {
      stats.totalAnuncios = parseInt(line.match(/\d+/)?.[0] || 0);
    } else if (line.includes('Anuncios ativos:')) {
      stats.anunciosAtivos = parseInt(line.match(/\d+/)?.[0] || 0);
    } else if (line.includes('Anuncios expirados:')) {
      stats.anunciosExpirados = parseInt(line.match(/\d+/)?.[0] || 0);
    } else if (line.includes('Locais cadastrados:')) {
      stats.totalLocais = parseInt(line.match(/\d+/)?.[0] || 0);
    } else if (line.includes('Infraestruturas ativas:')) {
      stats.infraestruturasAtivas = parseInt(line.match(/\d+/)?.[0] || 0);
    }
  }
  
  return stats;
};

// Cliente SOAP
export const soapClient = {
  // ============ UTILIZADORES ============
  
  listarUtilizadores: async () => {
    const envelope = createSoapEnvelope('listarUtilizadores', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    return extractList(response.data, 'return');
  },
  
  // ============ CONTAGENS ============
  
  contarUtilizadores: async () => {
    const envelope = createSoapEnvelope('contarUtilizadores', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 10000,
    });
    return extractInt(response.data);
  },
  
  contarAnuncios: async () => {
    const envelope = createSoapEnvelope('contarAnuncios', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 10000,
    });
    return extractInt(response.data);
  },
  
  contarAnunciosPorUtilizador: async (email) => {
    const envelope = createSoapEnvelope('contarAnunciosPorUtilizador', { email });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 10000,
    });
    return extractInt(response.data);
  },
  
  contarAnunciosPorLocal: async (local) => {
    const envelope = createSoapEnvelope('contarAnunciosPorLocal', { local });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 10000,
    });
    return extractInt(response.data);
  },
  
  contarLocais: async () => {
    const envelope = createSoapEnvelope('contarLocais', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 10000,
    });
    return extractInt(response.data);
  },
  
  contarAnunciosAtivos: async () => {
    const envelope = createSoapEnvelope('contarAnunciosAtivos', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 10000,
    });
    return extractInt(response.data);
  },
  
  contarAnunciosExpirados: async () => {
    const envelope = createSoapEnvelope('contarAnunciosExpirados', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 10000,
    });
    return extractInt(response.data);
  },
  
  contarInfraestruturasAtivas: async () => {
    const envelope = createSoapEnvelope('contarInfraestruturasAtivas', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 10000,
    });
    return extractInt(response.data);
  },
  
  getEstatisticasCompletas: async () => {
    const envelope = createSoapEnvelope('getEstatisticasCompletas', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    return extractEstatisticasCompletas(response.data);
  },
  
  // ============ ANUNCIOS ============
  
  // ============ ANÚNCIOS ============

listarAnuncios: async () => {
  try {
    const envelope = createSoapEnvelope('listarAnuncios', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    console.log('📥 Resposta bruta:', response.data);
    
    // Extrair todos os <item> do XML
    const items = [];
    const regex = /<item>(.*?)<\/item>/gs;
    let match;
    
    while ((match = regex.exec(response.data)) !== null) {
      items.push(match[1].trim());
    }
    
    console.log('📦 Itens extraídos:', items);
    
    // Converter cada item em um objeto de anúncio
    const anuncios = items.map((item, index) => {
      // Formato esperado: "[2026-06-25T17:29:40] benz@gmail.com: bbbbnb (Benfica Perto da Clé)"
      // Vamos extrair as partes
      
      // Extrair data entre [ ]
      const dataMatch = item.match(/\[(.*?)\]/);
      const data = dataMatch ? dataMatch[1] : 'Data desconhecida';
      
      // Remover a data do início
      let resto = item.replace(/\[.*?\]\s*/, '');
      
      // Extrair autor (até o primeiro ":")
      const autorMatch = resto.match(/^(.*?):\s*/);
      const autor = autorMatch ? autorMatch[1].trim() : 'Utilizador';
      
      // Remover o autor do resto
      resto = resto.replace(/^.*?:\s*/, '');
      
      // Extrair local (entre parênteses no final)
      const localMatch = resto.match(/\((.*?)\)$/);
      const local = localMatch ? localMatch[1].trim() : 'Local desconhecido';
      
      // Remover o local do resto
      const conteudo = resto.replace(/\(.*?\)$/, '').trim();
      
      return {
        id: `anuncio-${index}`,
        autor: autor,
        conteudo: conteudo || 'Sem conteúdo',
        local: local,
        data: data,
      };
    });
    
    console.log('Anúncios processados:', anuncios);
    return anuncios;
    
  } catch (error) {
    console.error(' Erro ao listar anúncios:', error);
    throw error;
  }
},
  
  // ============ LOCAIS ============
  
  listarLocais: async () => {
    const envelope = createSoapEnvelope('listarInfraestruturas', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    return extractList(response.data, 'item');
  },
  
  listarLocaisCoordenadas: async () => {
    const envelope = createSoapEnvelope('listarLocaisCoordenadas', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    return extractList(response.data, 'item');
  },
};