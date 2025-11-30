

--- ===========================================================
--- USERS
--- ===========================================================

CREATE TABLE users (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(255),
    role VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE fornecedores (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    tipo VARCHAR(255),
    logo TEXT,
    cnpj VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE contatos (
    id UUID PRIMARY KEY,
    fornecedor_id UUID,
    name VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    funcao TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE compras (
    id UUID PRIMARY KEY,
    user_id UUID,
    data_compra TIMESTAMP,
    fornecedor_id UUID,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);






--- ===========================================================
--- ANALYTICS
--- ===========================================================