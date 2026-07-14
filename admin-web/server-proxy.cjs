const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();

const PORT = 3001;
const SOAP_URL = 'http://localhost:3001/ws/anunciosloc';

// Middleware
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'SOAPAction', 'Accept', 'Origin', 'X-Requested-With']
}));

app.use(express.text({ type: 'text/xml' }));

// Proxy para SOAP
app.post('/ws/anunciosloc', async (req, res) => {
  try {
    console.log('📤 Encaminhando requisição SOAP...');
    console.log('📦 Body:', req.body ? req.body.substring(0, 200) + '...' : 'vazio');

    const response = await axios.post(SOAP_URL, req.body, {
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': req.headers.soapaction || '',
        'Accept': 'text/xml',
      },
      timeout: 30000,
    });

    console.log('📡 Status:', response.status);
    console.log('📨 Resposta:', response.data ? response.data.substring(0, 200) + '...' : 'vazia');

    res.status(response.status).send(response.data);
  } catch (error) {
    console.error('❌ Erro no proxy:', error.message);
    
    if (error.response) {
      console.error('📡 Status do erro:', error.response.status);
      res.status(error.response.status).send(error.response.data);
    } else if (error.code === 'ECONNREFUSED') {
      console.error('❌ Servidor SOAP não está rodando!');
      res.status(503).send('Servidor SOAP indisponível');
    } else {
      res.status(500).send('Erro ao conectar ao servidor SOAP: ' + error.message);
    }
  }
});

// Rota para verificar status
app.get('/status', (req, res) => {
  res.json({ 
    status: 'online', 
    soap: SOAP_URL,
    timestamp: new Date().toISOString()
  });
});

// Rota para teste
app.get('/', (req, res) => {
  res.send(`
    <h1>🚀 Proxy SOAP com CORS</h1>
    <p>Status: <strong>online</strong></p>
    <p>SOAP URL: <code>${SOAP_URL}</code></p>
    <p>Use POST para <code>/ws/anunciosloc</code></p>
  `);
});

app.listen(PORT, () => {
  console.log(`========================================`);
  console.log(` PROXY SOAP COM CORS`);
  console.log(`========================================`);
  console.log(` Proxy rodando em: http://localhost:${PORT}`);
  console.log(` Encaminhando para: ${SOAP_URL}`);
  console.log(`========================================`);
  console.log(`Prima CTRL+C para parar...`);
});