-- Criar base de dados
CREATE DATABASE IF NOT EXISTS anunciosloc;
USE anunciosloc;

-- Tabela de utilizadores
CREATE TABLE IF NOT EXISTS utilizadores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    saldo INT DEFAULT 10,
    ultimo_anuncio TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de anúncios
CREATE TABLE IF NOT EXISTS anuncios (
    id VARCHAR(36) PRIMARY KEY,
    conteudo TEXT NOT NULL,
    autor_email VARCHAR(100) NOT NULL,
    local_nome VARCHAR(100) NOT NULL,
    total_entregas INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (autor_email) REFERENCES utilizadores(email)
);

-- Tabela de saldos replicados (para quorum)
CREATE TABLE IF NOT EXISTS saldos_replicados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    saldo INT DEFAULT 10,
    infra_nome VARCHAR(100) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_email_infra (email, infra_nome)
);

-- Tabela de infraestruturas
CREATE TABLE IF NOT EXISTS infraestruturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    localizacao VARCHAR(100),
    latitude DOUBLE,
    longitude DOUBLE,
    capacidade INT DEFAULT 100,
    url VARCHAR(255),
    ativo BOOLEAN DEFAULT TRUE
);

-- Inserir dados iniciais
INSERT INTO infraestruturas (nome, localizacao, latitude, longitude, url) VALUES
('Infra-BelasShopping', 'Belas Shopping', -8.98, 13.18, 'http://localhost:8081/infra'),
('Infra-Talatona', 'Talatona', -8.89, 13.20, 'http://localhost:8082/infra'),
('Infra-Kilamba', 'Kilamba', -9.00, 13.30, 'http://localhost:8083/infra');

-- Inserir utilizador admin
INSERT INTO utilizadores (email, password_hash, saldo) VALUES
('admin@teste.com', 'admin123', 100);