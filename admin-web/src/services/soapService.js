import axios from 'axios';

const SOAP_URL = 'http://localhost:8082/ws/anunciosloc';

// Função para construir o envelope SOAP
const buildSoapEnvelope = (method, params) => {
  const paramsXml = Object.entries(params)
    .map(([key, value]) => `<${key}>${value}</${key}>`)
    .join('');

  return `<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns="http://service.server.anunciosloc.pt/">
  <soap:Body>
    <ns:${method}>
      ${paramsXml}
    </ns:${method}>
  </soap:Body>
</soap:Envelope>`;
};

// Função para parsear a resposta SOAP
const parseSoapResponse = (xmlResponse) => {
  const parser = new DOMParser();
  const xmlDoc = parser.parseFromString(xmlResponse, 'text/xml');
  
  // Extrair o conteúdo do return
  const returnElement = xmlDoc.getElementsByTagName('return')[0];
  if (returnElement) {
    return returnElement.textContent;
  }
  return null;
};

// ==================== LOGIN ADMIN ====================

export const loginAdmin = async (email, password) => {
  try {
    const envelope = buildSoapEnvelope('loginAdmin', { email, password });
    
    const response = await axios.post(SOAP_URL, envelope, {
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': '',
      },
      timeout: 15000,
    });

    if (response.status === 200) {
      const result = parseSoapResponse(response.data);
      
      // Verificar se o login foi bem-sucedido
      if (result && result.includes('Login realizado')) {
        return {
          success: true,
          message: result,
          email: email,
        };
      } else {
        return {
          success: false,
          message: result || 'Credenciais inválidas',
        };
      }
    }
    
    return {
      success: false,
      message: 'Erro ao conectar ao servidor',
    };
  } catch (error) {
    console.error('Erro no login SOAP:', error);
    return {
      success: false,
      message: error.response?.data || 'Erro de conexão com o servidor',
    };
  }
};

// ==================== REGISTAR UTILIZADOR ====================

export const registarUtilizador = async (email, password, nome) => {
  try {
    const envelope = buildSoapEnvelope('ativarUtilizador', { email, password, nome });
    
    const response = await axios.post(SOAP_URL, envelope, {
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': '',
      },
      timeout: 15000,
    });

    if (response.status === 200) {
      const result = parseSoapResponse(response.data);
      return {
        success: result && result.includes('sucesso'),
        message: result || 'Utilizador registado',
      };
    }
    
    return {
      success: false,
      message: 'Erro ao registar utilizador',
    };
  } catch (error) {
    console.error('Erro no registo SOAP:', error);
    return {
      success: false,
      message: error.response?.data || 'Erro de conexão com o servidor',
    };
  }
};

// ==================== CONSULTAR SALDO ====================

export const consultarSaldo = async (email) => {
  try {
    const envelope = buildSoapEnvelope('consultarSaldo', { email });
    
    const response = await axios.post(SOAP_URL, envelope, {
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': '',
      },
      timeout: 15000,
    });

    if (response.status === 200) {
      const result = parseSoapResponse(response.data);
      return {
        success: true,
        saldo: parseInt(result) || 0,
      };
    }
    
    return {
      success: false,
      saldo: 0,
    };
  } catch (error) {
    console.error('Erro ao consultar saldo:', error);
    return {
      success: false,
      saldo: 0,
    };
  }
};

// ==================== LISTAR UTILIZADORES ====================

export const listarUtilizadores = async () => {
  try {
    const envelope = buildSoapEnvelope('listarUtilizadores', {});
    
    const response = await axios.post(SOAP_URL, envelope, {
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': '',
      },
      timeout: 15000,
    });

    if (response.status === 200) {
      const parser = new DOMParser();
      const xmlDoc = parser.parseFromString(response.data, 'text/xml');
      
      // Extrair todos os itens do return
      const items = xmlDoc.getElementsByTagName('item');
      const utilizadores = [];
      
      for (let i = 0; i < items.length; i++) {
        utilizadores.push(items[i].textContent);
      }
      
      return {
        success: true,
        utilizadores,
      };
    }
    
    return {
      success: false,
      utilizadores: [],
    };
  } catch (error) {
    console.error('Erro ao listar utilizadores:', error);
    return {
      success: false,
      utilizadores: [],
    };
  }
};