-- =============================================
-- 1. SCHEMA COMPLETO - SISTEMA DE INSPEÇÃO CONTRA INCÊNDIO
-- =============================================

CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clients (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    cnpj_cpf VARCHAR(20), -- CNPJ/CPF
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    zip_code VARCHAR(20),
    logo_url VARCHAR(500),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE patrimonio (
    id UUID PRIMARY KEY,
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    zip_code VARCHAR(20),
    logo_url VARCHAR(500),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE docs (
    id UUID PRIMARY KEY,
    patrimonio_id UUID REFERENCES patrimonio(id) ON DELETE CASCADE,
    tipo_docs_id UUID REFERENCES tipo_docs(id),
    name VARCHAR(255) NOT NULL,
    doc_url TEXT,
    is_fixed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tipo_docs (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contato (
    id UUID PRIMARY KEY,
    patrimonio_id UUID REFERENCES patrimonio(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(255),
    observacoes TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE local (
    id UUID PRIMARY KEY,
    patrimonio_id UUID REFERENCES patrimonio(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sub_local (
    id UUID PRIMARY KEY,
    local_id UUID REFERENCES local(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE checkpoint (
    id UUID PRIMARY KEY,
    local_id UUID REFERENCES local(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE checkpoint_area_cobertura (
    id UUID PRIMARY KEY,
    checkpoint_id UUID REFERENCES checkpoint(id) ON DELETE CASCADE,
    area_cobertura_id UUID REFERENCES area_cobertura(id) ON DELETE CASCADE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE equipamento (
    id UUID PRIMARY KEY,
    checkpoint_id UUID REFERENCES checkpoint(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    equipamento_foto_url TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE equipamento_info (
    id UUID PRIMARY KEY,
    equipamento_id UUID REFERENCES equipamento(id) ON DELETE CASCADE,
    dado VARCHAR(255) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inspecao (
    id UUID PRIMARY KEY,
    equipamento_id UUID REFERENCES equipamentos(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inspecao_resultado (
    id UUID PRIMARY KEY,
    inspecao_id UUID REFERENCES inspecao(id) ON DELETE CASCADE,
    n VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pergunta_equipamento (
    id UUID PRIMARY KEY,
    equipamento_id UUID REFERENCES equipamentos(id) ON DELETE CASCADE,
    pergunta VARCHAR(255) NOT NULL,
    conforme BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

