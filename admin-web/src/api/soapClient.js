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
    
    console.log(' Resposta bruta:', response.data);
    
    // Extrair todos os <item> do XML
    const items = [];
    const regex = /<item>(.*?)<\/item>/gs;
    let match;
    
    while ((match = regex.exec(response.data)) !== null) {
      items.push(match[1].trim());
    }
    
    console.log(' Itens extraídos:', items);
    
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


  // ============ ADMIN ============

getAdminInfo: async (email) => {
  try {
    const envelope = createSoapEnvelope('getAdminInfo', { email });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    console.log(' Resposta getAdminInfo:', response.data);
    
    // Extrair o return
    const result = extractResponse(response.data, 'return');
    console.log(' Admin info:', result);
    
    return result || 'Informação não disponível';
  } catch (error) {
    console.error(' Erro ao buscar admin info:', error);
    throw error;
  }
},

atualizarAdmin: async (email, nome, password) => {
  try {
    const params = { email };
    
    // Só adicionar nome se não estiver vazio
    if (nome && nome.trim() !== '') {
      params.nome = nome;
    }
    
    // Só adicionar password se não estiver vazio
    if (password && password.trim() !== '') {
      params.password = password;
    }
    
    const envelope = createSoapEnvelope('atualizarAdmin', params);
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    console.log(' Resposta atualizarAdmin:', response.data);
    
    const result = extractResponse(response.data, 'return');
    return result || 'Admin atualizado com sucesso!';
  } catch (error) {
    console.error(' Erro ao atualizar admin:', error);
    throw error;
  }
},

cadastrarAdmin: async (email, password, nome, role) => {
  try {
    const envelope = createSoapEnvelope('cadastrarAdmin', {
      email,
      password,
      nome,
      role: role || 'ADMIN'
    });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    const result = extractResponse(response.data, 'return');
    return result || 'Admin cadastrado com sucesso!';
  } catch (error) {
    console.error(' Erro ao cadastrar admin:', error);
    throw error;
  }
},


// ============ UTILIZADORES (ADMIN) ============

listarUtilizadores: async () => {
  try {
    const envelope = createSoapEnvelope('listarUtilizadores', {});
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    console.log('📥 Resposta listarUtilizadores:', response.data);
    
    // Extrair os itens
    const items = extractList(response.data, 'item');
    console.log('📦 Itens extraídos:', items);
    
    // Converter cada item em objeto
    const utilizadores = items.map((item) => {
      // Formato: "admin@anunciosloc.com | Administrador | Saldo: 1000"
      const partes = item.split(' | ');
      return {
        email: partes[0] || '',
        nome: partes[1] || 'Utilizador',
        saldo: parseInt(partes[2]?.replace('Saldo: ', '') || 0),
        ativo: true,
        dataRegisto: new Date().toISOString().split('T')[0]
      };
    });
    
    console.log('✅ Utilizadores processados:', utilizadores);
    return utilizadores;
  } catch (error) {
    console.error('❌ Erro ao listar utilizadores:', error);
    throw error;
  }
},

ativarUtilizador: async (email, password, nome) => {
  try {
    const envelope = createSoapEnvelope('ativarUtilizador', { email, password, nome });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    const result = extractResponse(response.data, 'return');
    return result || 'Utilizador ativado com sucesso!';
  } catch (error) {
    console.error('❌ Erro ao ativar utilizador:', error);
    throw error;
  }
},

desativarUtilizador: async (email) => {
  try {
    const envelope = createSoapEnvelope('desativarConta', { email });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    const result = extractResponse(response.data, 'return');
    return result || 'Utilizador desativado com sucesso!';
  } catch (error) {
    console.error('❌ Erro ao desativar utilizador:', error);
    throw error;
  }
},

ativarUtilizadorAdmin: async (email) => {
  try {
    const envelope = createSoapEnvelope('reativarConta', { email });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    const result = extractResponse(response.data, 'return');
    return result || 'Utilizador reativado com sucesso!';
  } catch (error) {
    console.error('❌ Erro ao reativar utilizador:', error);
    throw error;
  }
},

eliminarUtilizador: async (email) => {
  try {
    const envelope = createSoapEnvelope('eliminarUtilizador', { email });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    const result = extractResponse(response.data, 'return');
    return result || 'Utilizador eliminado com sucesso!';
  } catch (error) {
    console.error('❌ Erro ao eliminar utilizador:', error);
    throw error;
  }
},

obterUtilizador: async (email) => {
  try {
    const envelope = createSoapEnvelope('obterUtilizador', { email });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    const result = extractResponse(response.data, 'return');
    return result || 'Utilizador não encontrado';
  } catch (error) {
    console.error('❌ Erro ao obter utilizador:', error);
    throw error;
  }
},

atualizarSaldo: async (email, novoSaldo) => {
  try {
    const envelope = createSoapEnvelope('atualizarSaldo', { email, novoSaldo });
    const response = await axios.post(SOAP_API_URL, envelope, {
      headers: { 'Content-Type': 'text/xml' },
      timeout: 15000,
    });
    
    const result = extractResponse(response.data, 'return');
    return result || 'Saldo atualizado com sucesso!';
  } catch (error) {
    console.error('❌ Erro ao atualizar saldo:', error);
    throw error;
  }
},
};