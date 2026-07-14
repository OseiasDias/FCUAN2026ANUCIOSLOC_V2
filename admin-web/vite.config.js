import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true,
    host: true, // Permite acesso externo
    proxy: {
      // Proxy para o servidor SOAP (porta 8082) - NOVO IP!
      '/soap': {
        target: 'http://192.168.16.128:8082',  // ← ATUALIZADO!
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/soap/, ''),
        configure: (proxy, options) => {
          proxy.on('error', (err, req, res) => {
            console.log('❌ Proxy error:', err);
          });
          proxy.on('proxyReq', (proxyReq, req, res) => {
            console.log('📤 Proxy request:', req.method, req.url);
          });
          proxy.on('proxyRes', (proxyRes, req, res) => {
            console.log('📥 Proxy response:', proxyRes.statusCode, req.url);
          });
        }
      },
      // Proxy para o servidor Auth (porta 8085)
      '/auth': {
        target: 'http://192.168.16.128:8085',  // ← ATUALIZADO!
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/auth/, ''),
      }
    }
  }
})