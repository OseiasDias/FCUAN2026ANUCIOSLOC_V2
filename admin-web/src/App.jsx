import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';

// Components
import Login from './components/Login/Login';
import MenuAside from './components/Layout/MenuAside';

// Pages
import Dashboard from './components/Dashboard/Dashboard';
import Utilizadores from './components/Utilizadores/Utilizadores';
import Anuncios from './components/Anuncios/Anuncios';
import Locais from './components/Locais/Locais';
import SetupGuide from './components/SetupGuide/SetupGuide';
import PerfilAdmin from './components/PerfilAdmin/PerfilAdmin';
import Configuracoes from './components/Configuracoes/Configuracoes';

// CSS
import './App.css';

// Componente de Rota Protegida
const RotaProtegida = ({ children }) => {
  const isAuthenticated = localStorage.getItem('userLogged') === 'true';
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return children;
};

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  // Verificar autenticação ao carregar a app
  useEffect(() => {
    const logged = localStorage.getItem('userLogged') === 'true';
    setIsAuthenticated(logged);
    setLoading(false);
  }, []);

  const handleLogin = (email) => {
    setIsAuthenticated(true);
    localStorage.setItem('userLogged', 'true');
    localStorage.setItem('userEmail', email);
    localStorage.setItem('adminName', email.split('@')[0]);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    localStorage.removeItem('userLogged');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('adminName');
  };

  // Mostrar loading enquanto verifica autenticação
  if (loading) {
    return (
      <div className="app-loading">
        <div className="loading-spinner"></div>
        <span>Carregando...</span>
      </div>
    );
  }

  // Se não estiver autenticado, mostrar Login
  if (!isAuthenticated) {
    return <Login onLogin={handleLogin} />;
  }

  return (
    <BrowserRouter>
      <div className="app">
        <Toaster 
          position="top-right"
          toastOptions={{
            duration: 4000,
            style: {
              background: '#363636',
              color: '#fff',
              borderRadius: '12px',
              padding: '16px',
            },
          }}
        />
        
        <Routes>
          {/* Rotas Protegidas - Usam o componente RotaProtegida */}
          <Route
            path="/"
            element={
              <RotaProtegida>
                <MenuAside conteudoPrincipal={<Dashboard />} onLogout={handleLogout} />
              </RotaProtegida>
            }
          />
          <Route
            path="/utilizadores"
            element={
              <RotaProtegida>
                <MenuAside conteudoPrincipal={<Utilizadores />} onLogout={handleLogout} />
              </RotaProtegida>
            }
          />
          <Route
            path="/anuncios"
            element={
              <RotaProtegida>
                <MenuAside conteudoPrincipal={<Anuncios />} onLogout={handleLogout} />
              </RotaProtegida>
            }
          />
          <Route
            path="/locais"
            element={
              <RotaProtegida>
                <MenuAside conteudoPrincipal={<Locais />} onLogout={handleLogout} />
              </RotaProtegida>
            }
          />
          <Route
            path="/setup"
            element={
              <RotaProtegida>
                <MenuAside conteudoPrincipal={<SetupGuide />} onLogout={handleLogout} />
              </RotaProtegida>
            }
          />
          <Route
            path="/perfil"
            element={
              <RotaProtegida>
                <MenuAside conteudoPrincipal={<PerfilAdmin />} onLogout={handleLogout} />
              </RotaProtegida>
            }
          />
          <Route
            path="/configuracoes"
            element={
              <RotaProtegida>
                <MenuAside conteudoPrincipal={<Configuracoes />} onLogout={handleLogout} />
              </RotaProtegida>
            }
          />
          
          {/* Redirecionar para login se rota não existir */}
          <Route path="/login" element={<Navigate to="/" replace />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;