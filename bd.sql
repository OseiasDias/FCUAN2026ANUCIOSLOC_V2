-- Criar base de dados
CREATE DATABASE IF NOT EXISTS anunciosloc;
USE anunciosloc;

-- =====================================================
-- TABELA: utilizadores
-- =====================================================

CREATE TABLE IF NOT EXISTS utilizadores (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    saldo DECIMAL(10,2) DEFAULT 10.00,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultimo_anuncio DATETIME NULL,
    sessao_activa BOOLEAN DEFAULT TRUE,
    total_anuncios_publicados INT DEFAULT 0,
    total_visualizacoes_recebidas INT DEFAULT 0
);

-- =====================================================
-- TABELA: perfil_utilizador
-- =====================================================

CREATE TABLE IF NOT EXISTS perfil_utilizador (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id BIGINT NOT NULL,
    chave_perfil VARCHAR(100) NOT NULL,
    valor_perfil VARCHAR(100) NOT NULL,
    FOREIGN KEY (utilizador_id) REFERENCES utilizadores(id) ON DELETE CASCADE
);

-- =====================================================
-- TABELA: infraestruturas
-- =====================================================

CREATE TABLE IF NOT EXISTS infraestruturas (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    capacidade INT NOT NULL,
    premio_entrega DECIMAL(10,2) DEFAULT 2.00,
    conexoes_actuais INT DEFAULT 0,
    anuncios_entregues INT DEFAULT 0,
    anuncios_publicados INT DEFAULT 0
);

-- =====================================================
-- TABELA: locais
-- =====================================================

CREATE TABLE IF NOT EXISTS locais (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    tipo ENUM('GPS', 'WIFI') NOT NULL,
    latitude DOUBLE NULL,
    longitude DOUBLE NULL,
    raio DOUBLE NULL,
    wifi_ssid VARCHAR(150) NULL,
    infraestrutura_id BIGINT NOT NULL,
    FOREIGN KEY (infraestrutura_id) REFERENCES infraestruturas(id) ON DELETE CASCADE
);

-- =====================================================
-- TABELA: anuncios
-- =====================================================

CREATE TABLE IF NOT EXISTS anuncios (
    id VARCHAR(36) PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT NOT NULL,
    utilizador_id BIGINT NOT NULL,
    local_id BIGINT NOT NULL,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_expiracao DATETIME NOT NULL,
    total_visualizacoes INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (utilizador_id) REFERENCES utilizadores(id) ON DELETE CASCADE,
    FOREIGN KEY (local_id) REFERENCES locais(id) ON DELETE CASCADE
);

-- =====================================================
-- TABELA: visualizacoes_anuncio
-- =====================================================

CREATE TABLE IF NOT EXISTS visualizacoes_anuncio (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    anuncio_id VARCHAR(36) NOT NULL,
    utilizador_id BIGINT NOT NULL,
    data_visualizacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (anuncio_id) REFERENCES anuncios(id) ON DELETE CASCADE,
    FOREIGN KEY (utilizador_id) REFERENCES utilizadores(id) ON DELETE CASCADE
);

-- =====================================================
-- TABELA: comentarios
-- =====================================================

CREATE TABLE IF NOT EXISTS comentarios (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    anuncio_id VARCHAR(36) NOT NULL,
    utilizador_id BIGINT NOT NULL,
    texto TEXT NOT NULL,
    data_comentario DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (anuncio_id) REFERENCES anuncios(id) ON DELETE CASCADE,
    FOREIGN KEY (utilizador_id) REFERENCES utilizadores(id) ON DELETE CASCADE
);

-- =====================================================
-- TABELA: restricoes
-- =====================================================

CREATE TABLE IF NOT EXISTS restricoes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    anuncio_id VARCHAR(36) NOT NULL,
    tipo ENUM('WHITELIST', 'BLACKLIST') NOT NULL,
    chave_restricao VARCHAR(100) NOT NULL,
    valor_restricao VARCHAR(100) NOT NULL,
    FOREIGN KEY (anuncio_id) REFERENCES anuncios(id) ON DELETE CASCADE
);

-- =====================================================
-- TABELA: sessoes
-- =====================================================

CREATE TABLE IF NOT EXISTS sessoes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id BIGINT NOT NULL,
    token VARCHAR(255) NOT NULL,
    data_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
    expiracao DATETIME NOT NULL,
    FOREIGN KEY (utilizador_id) REFERENCES utilizadores(id) ON DELETE CASCADE
);

-- =====================================================
-- TABELA: replica_saldo
-- =====================================================

CREATE TABLE IF NOT EXISTS replica_saldo (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id BIGINT NOT NULL,
    infraestrutura_id BIGINT NOT NULL,
    saldo DECIMAL(10,2) NOT NULL,
    versao INT DEFAULT 1,
    FOREIGN KEY (utilizador_id) REFERENCES utilizadores(id) ON DELETE CASCADE,
    FOREIGN KEY (infraestrutura_id) REFERENCES infraestruturas(id) ON DELETE CASCADE,
    UNIQUE KEY unique_replica (utilizador_id, infraestrutura_id)
);

-- =====================================================
-- INDICES
-- =====================================================

CREATE INDEX idx_utilizador_email ON utilizadores(email);
CREATE INDEX idx_anuncio_data_expiracao ON anuncios(data_expiracao);
CREATE INDEX idx_anuncio_activo ON anuncios(activo);
CREATE INDEX idx_local_tipo ON locais(tipo);
CREATE INDEX idx_sessao_token ON sessoes(token);
CREATE INDEX idx_sessao_expiracao ON sessoes(expiracao);

-- =====================================================
-- DADOS INICIAIS
-- =====================================================

INSERT INTO infraestruturas (nome, capacidade, premio_entrega) VALUES 
('Infraestrutura Central', 100, 2.00),
('Belas Shopping', 50, 2.50),
('Aeroporto 4 de Fevereiro', 200, 3.00);

INSERT INTO locais (nome, tipo, latitude, longitude, raio, infraestrutura_id) VALUES 
('Largo da Independencia', 'GPS', -8.838333, 13.234444, 20, 1),
('Belas Shopping', 'GPS', -8.980000, 13.180000, 15, 2),
('Aeroporto 4 de Fevereiro', 'GPS', -8.858333, 13.231111, 30, 3);

-- Utilizador admin para testes
INSERT INTO utilizadores (nome, email, senha, saldo, sessao_activa) VALUES 
('Administrador', 'admin@anunciosloc.com', 'admin123', 1000.00, TRUE);

SELECT 'Base de dados criada com sucesso!' as Mensagem;