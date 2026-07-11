import React, { useState } from 'react';
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

import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const handleLogin = (email) => {
    setIsAuthenticated(true);
    localStorage.setItem('adminName', email.split('@')[0]);
    localStorage.setItem('adminEmail', email);
  };

  if (!isAuthenticated) {
    return <Login onLogin={handleLogin} />;
  }

  return (
    <BrowserRouter>
      <div className="app">
        <Toaster position="top-right" />
        
        <Routes>
          <Route
            path="/"
            element={
              <MenuAside conteudoPrincipal={<Dashboard />} />
            }
          />
          <Route
            path="/utilizadores"
            element={
              <MenuAside conteudoPrincipal={<Utilizadores />} />
            }
          />
          <Route
            path="/anuncios"
            element={
              <MenuAside conteudoPrincipal={<Anuncios />} />
            }
          />
          <Route
            path="/locais"
            element={
              <MenuAside conteudoPrincipal={<Locais />} />
            }
          />
          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;