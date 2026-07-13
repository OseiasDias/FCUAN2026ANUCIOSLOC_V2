-- ============================================
-- CRIAÇÃO DA BASE DE DADOS
-- ============================================

CREATE DATABASE IF NOT EXISTS anunciosloc;
USE anunciosloc;

-- ============================================
-- TABELA: UTILIZADORES
-- ============================================

CREATE TABLE IF NOT EXISTS utilizadores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    saldo DECIMAL(10,2) DEFAULT 10.00,
    ativo BOOLEAN DEFAULT TRUE,
    role VARCHAR(20) DEFAULT 'USER',
    total_anuncios_publicados INT DEFAULT 0,
    total_visualizacoes_recebidas INT DEFAULT 0,
    ultimo_login TIMESTAMP NULL,
    data_registo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_anuncio TIMESTAMP NULL,
    INDEX idx_email (email)
);

-- ============================================
-- TABELA: ADMINISTRADORES
-- ============================================

CREATE TABLE IF NOT EXISTS administradores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'ADMIN',
    ativo BOOLEAN DEFAULT TRUE,
    data_registo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acesso TIMESTAMP NULL,
    INDEX idx_email (email)
);

-- ============================================
-- TABELA: ANUNCIOS
-- ============================================

CREATE TABLE IF NOT EXISTS anuncios (
    id VARCHAR(36) PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT NOT NULL,
    autor_email VARCHAR(100) NOT NULL,
    local_id BIGINT NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_expiracao TIMESTAMP NOT NULL,
    total_visualizacoes INT DEFAULT 0,
    total_entregas INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    expirado BOOLEAN DEFAULT FALSE,
    INDEX idx_autor_email (autor_email),
    INDEX idx_local_id (local_id),
    INDEX idx_data_expiracao (data_expiracao),
    FOREIGN KEY (autor_email) REFERENCES utilizadores(email) ON DELETE CASCADE
);

-- ============================================
-- TABELA: LOCAIS (INFRAESTRUTURAS)
-- ============================================

CREATE TABLE IF NOT EXISTS locais (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo ENUM('GPS', 'WIFI', 'BLE') DEFAULT 'GPS',
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    raio DECIMAL(10,2) DEFAULT 100.00,
    wifi_ssid VARCHAR(150) NULL,
    infraestrutura_id BIGINT NULL,
    criado_por BIGINT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nome (nome),
    INDEX idx_infraestrutura (infraestrutura_id)
);

-- ============================================
-- TABELA: INFRAESTRUTURAS
-- ============================================

CREATE TABLE IF NOT EXISTS infraestruturas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    localizacao VARCHAR(200) NULL,
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    capacidade INT DEFAULT 100,
    raio DECIMAL(10,2) DEFAULT 100.00,
    url VARCHAR(255) NULL,
    total_anuncios INT DEFAULT 0,
    total_entregas INT DEFAULT 0,
    utilizadores_conectados INT DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE,
    criador_email VARCHAR(100) NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nome (nome)
);

-- ============================================
-- TABELA: TICKETS (AUTH)
-- ============================================

CREATE TABLE IF NOT EXISTS tickets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) DEFAULT 'ACCESS',
    validade TIMESTAMP NOT NULL,
    usado BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ticket_id (ticket_id),
    INDEX idx_email (email)
);

-- ============================================
-- TABELA: PERFIL_UTILIZADORES
-- ============================================

CREATE TABLE IF NOT EXISTS perfil_utilizadores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    utilizador_id BIGINT NOT NULL,
    chave VARCHAR(100) NOT NULL,
    valor VARCHAR(255) NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_utilizador (utilizador_id),
    INDEX idx_chave (chave),
    FOREIGN KEY (utilizador_id) REFERENCES utilizadores(id) ON DELETE CASCADE
);

-- ============================================
-- TABELA: RESTRICOES
-- ============================================

CREATE TABLE IF NOT EXISTS restricoes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    anuncio_id VARCHAR(36) NOT NULL,
    tipo ENUM('WHITELIST', 'BLACKLIST') NOT NULL,
    chave VARCHAR(100) NOT NULL,
    valor VARCHAR(255) NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_anuncio (anuncio_id),
    FOREIGN KEY (anuncio_id) REFERENCES anuncios(id) ON DELETE CASCADE
);

-- ============================================
-- INSERIR ADMIN PADRÃO
-- ============================================

INSERT INTO administradores (email, nome, password_hash, role)
VALUES ('admin@anunciosloc.com', 'Administrador', SHA2('admin123', 256), 'SUPER_ADMIN')
ON DUPLICATE KEY UPDATE email = email;

-- ============================================
-- INSERIR LOCAIS PADRÃO
-- ============================================

INSERT INTO locais (nome, tipo, latitude, longitude, raio, ativo) VALUES
('Belas Shopping', 'GPS', -8.98, 13.18, 100, 1),
('Talatona', 'GPS', -8.89, 13.20, 100, 1),
('Kilamba', 'GPS', -9.00, 13.30, 100, 1),
('Luanda Sul', 'GPS', -8.95, 13.25, 100, 1);

-- ============================================
-- VERIFICAR DADOS INSERIDOS
-- ============================================

SELECT '========== ADMINISTRADORES ==========' AS '';
SELECT * FROM administradores;

SELECT '========== LOCAIS ==========' AS '';
SELECT * FROM locais;

SELECT '========== TABELAS CRIADAS ==========' AS '';
SHOW TABLES;