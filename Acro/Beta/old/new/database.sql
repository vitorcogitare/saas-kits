-- =============================================
-- SCHEMA COMPLETO - SISTEMA DE INSPEÇÃO CONTRA INCÊNDIO
-- Database: PostgreSQL (Supabase)
-- Versão: 2.0
-- =============================================

-- =============================================
-- 1. TABELAS DE USUÁRIOS E PERMISSÕES
-- =============================================

-- Tabela de Roles
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL, -- 'client', 'inspector', 'manager', 'admin'
    description TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Permissões
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    module VARCHAR(50), -- 'inspections', 'assets', 'users', 'reports', 'clients'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relacionamento Role-Permissões
CREATE TABLE role_permissions (
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id)
);

-- Tabela de Usuários
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role_id INTEGER REFERENCES roles(id),
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 2. TABELAS DE CLIENTES E PATRIMÔNIOS
-- =============================================

-- Tabela de Clientes/Empresas
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    document VARCHAR(20), -- CNPJ/CPF
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    logo_url VARCHAR(500),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relacionamento Cliente-Usuários (múltiplos usuários por cliente)
CREATE TABLE client_users (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    access_level VARCHAR(50) DEFAULT 'view_only', -- view_only, full_access
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(client_id, user_id)
);

-- Tabela de Unidades/Prédios/Patrimônios
CREATE TABLE properties (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50), -- Código interno
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    total_area DECIMAL(10, 2), -- m²
    building_type VARCHAR(100), -- 'comercial', 'industrial', 'residencial'
    risk_classification VARCHAR(50), -- 'baixo', 'médio', 'alto'
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Localizações Hierárquicas (Local e Sub-local)
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    property_id INTEGER REFERENCES properties(id) ON DELETE CASCADE,
    parent_location_id INTEGER REFERENCES locations(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL, -- 'Térreo', 'Subsolo', 'Sala 101', 'Corredor A'
    code VARCHAR(50), -- 'T-01', 'SS-B1', 'S101'
    description TEXT,
    level INTEGER NOT NULL, -- 1=andar, 2=área, 3=sala/ambiente
    qr_code VARCHAR(100) UNIQUE, -- QR Code do checkpoint
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    floor_plan_url VARCHAR(500), -- Planta baixa do local
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 3. DOCUMENTOS DE CONFORMIDADE
-- =============================================

-- Tabela para AVCB, CLCB e outros documentos
CREATE TABLE compliance_documents (
    id SERIAL PRIMARY KEY,
    property_id INTEGER REFERENCES properties(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL, -- 'AVCB', 'CLCB', 'Projeto', 'ART', 'Laudo'
    document_number VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    issuing_authority VARCHAR(255), -- Corpo de Bombeiros, Prefeitura
    file_path VARCHAR(500),
    file_url VARCHAR(500), -- URL do Supabase Storage
    status VARCHAR(20) DEFAULT 'active', -- active, expired, pending_renewal, cancelled
    observations TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 4. SISTEMAS E EQUIPAMENTOS
-- =============================================

-- Tabela de Tipos de Sistemas
CREATE TABLE system_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL, -- 'Extintor', 'PCF', 'Hidrante', 'Alarme', 'Iluminação Emergência'
    code VARCHAR(20), -- 'EXT', 'PCF', 'HID'
    description TEXT,
    icon_name VARCHAR(50), -- Nome do ícone para o frontend
    color VARCHAR(7), -- Cor hexadecimal para identificação visual
    requires_maintenance BOOLEAN DEFAULT TRUE,
    maintenance_frequency_days INTEGER, -- Frequência padrão de manutenção
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Equipamentos/Ativos
CREATE TABLE assets (
    id SERIAL PRIMARY KEY,
    property_id INTEGER REFERENCES properties(id) ON DELETE CASCADE,
    location_id INTEGER REFERENCES locations(id) ON DELETE SET NULL,
    system_type_id INTEGER REFERENCES system_types(id),
    parent_asset_id INTEGER REFERENCES assets(id) ON DELETE SET NULL, -- Para hierarquia (ex: mangueira pertence a hidrante)
    qr_code VARCHAR(100) UNIQUE NOT NULL,
    identifier VARCHAR(100) NOT NULL, -- 'EXT-001', 'PCF-01A', 'HID-T-05'
    manufacturer VARCHAR(255),
    model VARCHAR(255),
    serial_number VARCHAR(255),
    location_description TEXT, -- Descrição detalhada da localização
    technical_specs JSONB, -- Especificações técnicas variáveis por tipo
    installation_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    warranty_expiry_date DATE,
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, maintenance, condemned
    condition_rating INTEGER CHECK (condition_rating >= 1 AND condition_rating <= 5), -- 1=péssimo, 5=ótimo
    photos JSONB, -- Array de URLs de fotos
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Histórico de Manutenções
CREATE TABLE maintenance_history (
    id SERIAL PRIMARY KEY,
    asset_id INTEGER REFERENCES assets(id) ON DELETE CASCADE,
    maintenance_type VARCHAR(50), -- 'preventiva', 'corretiva', 'recarga', 'teste'
    performed_by VARCHAR(255),
    company VARCHAR(255), -- Empresa que realizou
    performed_at TIMESTAMP NOT NULL,
    next_due_date DATE,
    cost DECIMAL(10, 2),
    observations TEXT,
    documents JSONB, -- Array de URLs de certificados, notas fiscais
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 5. CHECKLISTS E TEMPLATES
-- =============================================

-- Tipos de Resposta para Itens de Checklist
CREATE TABLE checklist_item_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL, -- 'yes_no', 'compliant', 'numeric', 'text', 'multiple_choice', 'photo'
    description TEXT
);

-- Tabela de Modelos de Checklist
CREATE TABLE checklist_templates (
    id SERIAL PRIMARY KEY,
    system_type_id INTEGER REFERENCES system_types(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    based_on_norm VARCHAR(100), -- 'NBR 12693', 'NBR 13434', 'IT-CB'
    version VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Itens do Checklist
CREATE TABLE checklist_items (
    id SERIAL PRIMARY KEY,
    checklist_template_id INTEGER REFERENCES checklist_templates(id) ON DELETE CASCADE,
    item_type_id INTEGER REFERENCES checklist_item_types(id),
    question_text TEXT NOT NULL,
    help_text TEXT,
    item_order INTEGER NOT NULL,
    category VARCHAR(100), -- Para agrupar itens: 'Estrutura', 'Sinalização', 'Funcionalidade'
    severity_level VARCHAR(20) DEFAULT 'medium', -- low, medium, high, critical
    is_required BOOLEAN DEFAULT TRUE,
    requires_photo BOOLEAN DEFAULT FALSE,
    validation_rules JSONB, -- min/max para numéricos, opções para múltipla escolha
    expected_value TEXT, -- Valor esperado para comparação automática
    active BOOLEAN DEFAULT TRUE
);

-- =============================================
-- 6. VISTORIAS/INSPEÇÕES
-- =============================================

-- Tabela de Vistorias Agendadas/Programadas
CREATE TABLE scheduled_inspections (
    id SERIAL PRIMARY KEY,
    property_id INTEGER REFERENCES properties(id) ON DELETE CASCADE,
    assigned_to INTEGER REFERENCES users(id),
    scheduled_date DATE NOT NULL,
    scheduled_time TIME,
    deadline_date DATE,
    priority VARCHAR(20) DEFAULT 'normal', -- low, normal, high, urgent
    inspection_type VARCHAR(50), -- 'routine', 'emergency', 'follow_up'
    status VARCHAR(20) DEFAULT 'pending', -- pending, confirmed, in_progress, completed, cancelled
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela Principal de Vistorias
CREATE TABLE inspections (
    id SERIAL PRIMARY KEY,
    scheduled_inspection_id INTEGER REFERENCES scheduled_inspections(id),
    property_id INTEGER REFERENCES properties(id) ON DELETE CASCADE,
    inspector_id INTEGER REFERENCES users(id),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(20) DEFAULT 'draft', -- draft, in_progress, completed, signed, cancelled
    weather_conditions VARCHAR(100),
    temperature DECIMAL(5,2),
    inspection_notes TEXT,
    overall_status VARCHAR(20), -- compliant, non_compliant, partial
    completion_percentage INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Checkpoints Escaneados durante a Vistoria
CREATE TABLE inspection_checkpoints (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER REFERENCES inspections(id) ON DELETE CASCADE,
    location_id INTEGER REFERENCES locations(id),
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    device_info JSONB -- Info do dispositivo móvel
);

-- Vistoria por Sistema
CREATE TABLE inspection_systems (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER REFERENCES inspections(id) ON DELETE CASCADE,
    system_type_id INTEGER REFERENCES system_types(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, in_progress, completed
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    notes TEXT
);

-- Resultados da Vistoria por Asset
CREATE TABLE inspection_results (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER REFERENCES inspections(id) ON DELETE CASCADE,
    asset_id INTEGER REFERENCES assets(id) ON DELETE CASCADE,
    checklist_item_id INTEGER REFERENCES checklist_items(id),
    compliance_status VARCHAR(20) NOT NULL, -- compliant, non_compliant, not_applicable, not_verified
    response_value TEXT, -- Valor da resposta (texto, número, etc)
    observations TEXT,
    severity VARCHAR(20), -- Pode herdar do template ou ser sobrescrito
    is_critical BOOLEAN DEFAULT FALSE,
    requires_immediate_action BOOLEAN DEFAULT FALSE,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    scanned_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Mídia/Evidências
CREATE TABLE inspection_media (
    id SERIAL PRIMARY KEY,
    inspection_result_id INTEGER REFERENCES inspection_results(id) ON DELETE CASCADE,
    inspection_id INTEGER REFERENCES inspections(id) ON DELETE CASCADE,
    asset_id INTEGER REFERENCES assets(id),
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500), -- URL do Supabase Storage
    file_type VARCHAR(10), -- jpg, png, pdf, mp4
    file_size INTEGER, -- em bytes
    caption TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    taken_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Assinaturas
CREATE TABLE inspection_signatures (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER REFERENCES inspections(id) ON DELETE CASCADE,
    signer_name VARCHAR(255) NOT NULL,
    signer_role VARCHAR(100),
    signer_document VARCHAR(50), -- CPF
    signature_data TEXT, -- Base64 da assinatura
    signature_url VARCHAR(500), -- URL do Supabase Storage
    signed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    signer_type VARCHAR(20), -- inspector, client, witness, manager
    ip_address INET,
    device_info JSONB
);

-- =============================================
-- 7. NÃO CONFORMIDADES E PLANOS DE AÇÃO
-- =============================================

-- Tabela de Não Conformidades
CREATE TABLE non_conformities (
    id SERIAL PRIMARY KEY,
    inspection_result_id INTEGER REFERENCES inspection_results(id) ON DELETE CASCADE,
    inspection_id INTEGER REFERENCES inspections(id) ON DELETE CASCADE,
    asset_id INTEGER REFERENCES assets(id),
    location_id INTEGER REFERENCES locations(id),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20) NOT NULL, -- low, medium, high, critical
    category VARCHAR(100), -- 'structural', 'operational', 'documentation', 'signage'
    deadline DATE,
    assigned_to INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'open', -- open, in_progress, resolved, cancelled, overdue
    resolution_notes TEXT,
    resolved_at TIMESTAMP,
    resolved_by INTEGER REFERENCES users(id),
    requires_external_service BOOLEAN DEFAULT FALSE,
    estimated_cost DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Planos de Ação para Não Conformidades
CREATE TABLE action_plans (
    id SERIAL PRIMARY KEY,
    non_conformity_id INTEGER REFERENCES non_conformities(id) ON DELETE CASCADE,
    action_description TEXT NOT NULL,
    responsible_id INTEGER REFERENCES users(id),
    estimated_cost DECIMAL(10, 2),
    actual_cost DECIMAL(10, 2),
    deadline DATE,
    status VARCHAR(20) DEFAULT 'pending', -- pending, in_progress, completed, cancelled
    completion_percentage INTEGER DEFAULT 0,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 8. RELATÓRIOS
-- =============================================

-- Templates de Relatórios Customizáveis
CREATE TABLE report_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    template_type VARCHAR(50), -- 'inspection', 'asset_inventory', 'maintenance', 'non_conformities'
    template_content JSONB, -- Estrutura do template (seções, campos, etc)
    header_html TEXT,
    footer_html TEXT,
    css_styles TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relatórios Gerados
CREATE TABLE generated_reports (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER REFERENCES inspections(id) ON DELETE CASCADE,
    property_id INTEGER REFERENCES properties(id),
    report_template_id INTEGER REFERENCES report_templates(id),
    report_type VARCHAR(50), -- 'full_inspection', 'executive_summary', 'non_conformities', 'assets'
    file_path VARCHAR(500),
    file_url VARCHAR(500), -- URL do Supabase Storage
    file_format VARCHAR(10), -- 'pdf', 'xlsx', 'docx'
    file_size INTEGER,
    generated_by INTEGER REFERENCES users(id),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    download_count INTEGER DEFAULT 0,
    last_downloaded_at TIMESTAMP
);

-- =============================================
-- 9. NOTIFICAÇÕES
-- =============================================

-- Configurações de Notificação por Usuário
CREATE TABLE notification_settings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50), -- 'maintenance_due', 'inspection_scheduled', 'non_conformity', 'document_expiry'
    channel VARCHAR(20), -- 'email', 'push', 'sms', 'in_app'
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, notification_type, channel)
);

-- Tabela de Notificações
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50), -- 'maintenance_due', 'inspection_scheduled', 'non_conformity', 'document_expiry'
    title VARCHAR(255) NOT NULL,
    message TEXT,
    related_entity_type VARCHAR(50), -- 'asset', 'inspection', 'non_conformity', 'document'
    related_entity_id INTEGER,
    priority VARCHAR(20) DEFAULT 'normal', -- low, normal, high, urgent
    action_url VARCHAR(500), -- Deep link para a tela específica
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

-- =============================================
-- 10. AUDITORIA E LOGS
-- =============================================

-- Logs de Auditoria
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL, -- 'create', 'update', 'delete', 'view', 'download', 'sign'
    entity_type VARCHAR(50) NOT NULL, -- 'asset', 'inspection', 'user', 'report'
    entity_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    location JSONB, -- {latitude, longitude, city}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Logs de Sincronização Offline
CREATE TABLE sync_logs (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100),
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(50), -- 'upload', 'download', 'conflict'
    entity_type VARCHAR(50),
    entity_ids JSONB, -- Array de IDs sincronizados
    records_count INTEGER,
    sync_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'completed', -- pending, completed, failed
    conflict_resolution JSONB, -- Como conflitos foram resolvidos
    error_message TEXT,
    duration_ms INTEGER -- Tempo de duração da sync
);

-- =============================================
-- ÍNDICES PARA PERFORMANCE
-- =============================================

-- Índices de Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Índices de Clients e Properties
CREATE INDEX idx_properties_client_id ON properties(client_id);
CREATE INDEX idx_properties_active ON properties(active);
CREATE INDEX idx_client_users_client_id ON client_users(client_id);
CREATE INDEX idx_client_users_user_id ON client_users(user_id);

-- Índices de Locations
CREATE INDEX idx_locations_property_id ON locations(property_id);
CREATE INDEX idx_locations_parent_id ON locations(parent_location_id);
CREATE INDEX idx_locations_qr_code ON locations(qr_code);

-- Índices de Assets
CREATE INDEX idx_assets_qr_code ON assets(qr_code);
CREATE INDEX idx_assets_property_id ON assets(property_id);
CREATE INDEX idx_assets_location_id ON assets(location_id);
CREATE INDEX idx_assets_system_type_id ON assets(system_type_id);
CREATE INDEX idx_assets_status ON assets(status);
CREATE INDEX idx_assets_next_maintenance ON assets(next_maintenance_date);

-- Índices de Maintenance
CREATE INDEX idx_maintenance_history_asset_id ON maintenance_history(asset_id);
CREATE INDEX idx_maintenance_history_performed_at ON maintenance_history(performed_at);

-- Índices de Compliance Documents
CREATE INDEX idx_compliance_docs_property_id ON compliance_documents(property_id);
CREATE INDEX idx_compliance_docs_expiry ON compliance_documents(expiry_date);
CREATE INDEX idx_compliance_docs_status ON compliance_documents(status);

-- Índices de Inspections
CREATE INDEX idx_inspections_property_id ON inspections(property_id);
CREATE INDEX idx_inspections_inspector_id ON inspections(inspector_id);
CREATE INDEX idx_inspections_status ON inspections(status);
CREATE INDEX idx_inspections_start_time ON inspections(start_time);
CREATE INDEX idx_scheduled_inspections_assigned_to ON scheduled_inspections(assigned_to);
CREATE INDEX idx_scheduled_inspections_scheduled_date ON scheduled_inspections(scheduled_date);
CREATE INDEX idx_inspection_checkpoints_inspection_id ON inspection_checkpoints(inspection_id);

-- Índices de Inspection Results
CREATE INDEX idx_inspection_results_inspection_id ON inspection_results(inspection_id);
CREATE INDEX idx_inspection_results_asset_id ON inspection_results(asset_id);
CREATE INDEX idx_inspection_results_compliance_status ON inspection_results(compliance_status);

-- Índices de Non-Conformities
CREATE INDEX idx_non_conformities_inspection_id ON non_conformities(inspection_id);
CREATE INDEX idx_non_conformities_asset_id ON non_conformities(asset_id);
CREATE INDEX idx_non_conformities_status ON non_conformities(status);
CREATE INDEX idx_non_conformities_deadline ON non_conformities(deadline);
CREATE INDEX idx_non_conformities_severity ON non_conformities(severity);
CREATE INDEX idx_action_plans_non_conformity_id ON action_plans(non_conformity_id);

-- Índices de Notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_sent_at ON notifications(sent_at);

-- Índices de Audit Logs
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- =============================================
-- DADOS INICIAIS (SEED)
-- =============================================

-- Inserir Roles Padrão
INSERT INTO roles (name, description) VALUES
('admin', 'Administrador do sistema com acesso total'),
('manager', 'Gerente - pode criar equipamentos, vistorias e usuários'),
('inspector', 'Inspetor - pode realizar vistorias'),
('client', 'Cliente - pode visualizar equipamentos e relatórios');

-- Inserir Permissions Padrão
INSERT INTO permissions (name, description, module) VALUES
-- Assets
('assets.view', 'Visualizar equipamentos', 'assets'),
('assets.create', 'Criar equipamentos', 'assets'),
('assets.edit', 'Editar equipamentos', 'assets'),
('assets.delete', 'Deletar equipamentos', 'assets'),
-- Inspections
('inspections.view', 'Visualizar vistorias', 'inspections'),
('inspections.create', 'Criar vistorias', 'inspections'),
('inspections.execute', 'Executar vistorias', 'inspections'),
('inspections.sign', 'Assinar vistorias', 'inspections'),
    nc.*,
    a.identifier as asset_identifier,
    a.qr_code as asset_qr_code,
    st.name as system_type_name,
    p.name as property_name,
    c.name as client_name,
    u.name as assigned_to_name,
    CASE 
        WHEN nc.deadline < CURRENT_DATE THEN 'overdue'
        WHEN nc.deadline <= CURRENT_DATE + INTERVAL '7 days' THEN 'urgent'
        ELSE 'normal'
    END as urgency_status
FROM non_conformities nc
LEFT JOIN assets a ON nc.asset_id = a.id
LEFT JOIN system_types st ON a.system_type_id = st.id
LEFT JOIN properties p ON a.property_id = p.id
LEFT JOIN clients c ON p.client_id = c.id
LEFT JOIN users u ON nc.assigned_to = u.id
WHERE nc.status IN ('open', 'in_progress');

-- View de Manutenções Vencendo
CREATE VIEW v_maintenance_due AS
SELECT 
    a.id,
    a.identifier,
    a.qr_code,
    a.next_maintenance_date,
    st.name as system_type_name,
    l.name as location_name,
    p.name as property_name,
    c.name as client_name,
    CURRENT_DATE - a.next_maintenance_date as days_overdue,
    CASE 
        WHEN a.next_maintenance_date < CURRENT_DATE THEN 'overdue'
        WHEN a.next_maintenance_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'due_soon'
        ELSE 'scheduled'
    END as maintenance_status
FROM assets a
LEFT JOIN system_types st ON a.system_type_id = st.id
LEFT JOIN locations l ON a.location_id = l.id
LEFT JOIN properties p ON a.property_id = p.id
LEFT JOIN clients c ON p.client_id = c.id
WHERE a.active = TRUE 
    AND a.next_maintenance_date IS NOT NULL
    AND a.next_maintenance_date <= CURRENT_DATE + INTERVAL '60 days'
ORDER BY a.next_maintenance_date ASC;

-- View de Documentos Expirando
CREATE VIEW v_documents_expiring AS
SELECT 
    cd.*,
    p.name as property_name,
    c.name as client_name,
    CURRENT_DATE - cd.expiry_date as days_until_expiry,
    CASE 
        WHEN cd.expiry_date < CURRENT_DATE THEN 'expired'
        WHEN cd.expiry_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'expiring_soon'
        ELSE 'valid'
    END as document_status
FROM compliance_documents cd
LEFT JOIN properties p ON cd.property_id = p.id
LEFT JOIN clients c ON p.client_id = c.id
WHERE cd.status = 'active'
    AND cd.expiry_date IS NOT NULL
ORDER BY cd.expiry_date ASC;

-- =============================================
-- FUNÇÕES ÚTEIS
-- =============================================

-- Função para calcular próxima data de manutenção
CREATE OR REPLACE FUNCTION calculate_next_maintenance_date(
    p_asset_id INTEGER,
    p_last_maintenance_date DATE
) RETURNS DATE AS $
DECLARE
    v_frequency_days INTEGER;
    v_next_date DATE;
BEGIN
    SELECT st.maintenance_frequency_days INTO v_frequency_days
    FROM assets a
    JOIN system_types st ON a.system_type_id = st.id
    WHERE a.id = p_asset_id;
    
    IF v_frequency_days IS NOT NULL THEN
        v_next_date := p_last_maintenance_date + (v_frequency_days || ' days')::INTERVAL;
    END IF;
    
    RETURN v_next_date;
END;
$ LANGUAGE plpgsql;

-- Função para gerar QR Code único
CREATE OR REPLACE FUNCTION generate_unique_qr_code(
    p_prefix VARCHAR
) RETURNS VARCHAR AS $
DECLARE
    v_qr_code VARCHAR;
    v_exists BOOLEAN;
BEGIN
    LOOP
        v_qr_code := p_prefix || '-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8));
        
        SELECT EXISTS(SELECT 1 FROM assets WHERE qr_code = v_qr_code) INTO v_exists;
        
        EXIT WHEN NOT v_exists;
    END LOOP;
    
    RETURN v_qr_code;
END;
$ LANGUAGE plpgsql;

-- =============================================
-- POLÍTICAS RLS (Row Level Security) - SUPABASE
-- =============================================

-- Habilitar RLS em tabelas principais
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE inspection_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE non_conformities ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Políticas para CLIENTS
-- Admins e Managers veem tudo
CREATE POLICY "Admins and Managers can view all clients"
    ON clients FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::INTEGER 
            AND users.role_id IN (1, 2)
        )
    );

-- Clientes veem apenas seus próprios dados
CREATE POLICY "Clients can view their own data"
    ON clients FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM client_users cu
            JOIN users u ON cu.user_id = u.id
            WHERE u.id = auth.uid()::INTEGER
            AND cu.client_id = clients.id
        )
    );

-- Políticas para PROPERTIES
CREATE POLICY "Authenticated users can view properties based on role"
    ON properties FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users u
            LEFT JOIN client_users cu ON u.id = cu.user_id
            WHERE u.id = auth.uid()::INTEGER
            AND (
                u.role_id IN (1, 2, 3) -- Admin, Manager, Inspector
                OR cu.client_id = properties.client_id -- Cliente próprio
            )
        )
    );

-- Políticas para ASSETS
CREATE POLICY "Authenticated users can view assets based on role"
    ON assets FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users u
            LEFT JOIN client_users cu ON u.id = cu.user_id
            LEFT JOIN properties p ON assets.property_id = p.id
            WHERE u.id = auth.uid()::INTEGER
            AND (
                u.role_id IN (1, 2, 3) -- Admin, Manager, Inspector
                OR cu.client_id = p.client_id -- Cliente próprio
            )
        )
    );

-- Apenas Admins e Managers podem criar/editar assets
CREATE POLICY "Only Admins and Managers can create assets"
    ON assets FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::INTEGER 
            AND users.role_id IN (1, 2)
        )
    );

CREATE POLICY "Only Admins and Managers can update assets"
    ON assets FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::INTEGER 
            AND users.role_id IN (1, 2)
        )
    );

-- Políticas para INSPECTIONS
CREATE POLICY "Users can view inspections based on role"
    ON inspections FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users u
            LEFT JOIN client_users cu ON u.id = cu.user_id
            LEFT JOIN properties p ON inspections.property_id = p.id
            WHERE u.id = auth.uid()::INTEGER
            AND (
                u.role_id IN (1, 2) -- Admin, Manager
                OR u.id = inspections.inspector_id -- Inspector assigned
                OR cu.client_id = p.client_id -- Cliente próprio
            )
        )
    );

-- Inspetores podem criar e editar suas próprias inspeções
CREATE POLICY "Inspectors can create inspections"
    ON inspections FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::INTEGER 
            AND users.role_id IN (1, 2, 3)
        )
    );

CREATE POLICY "Inspectors can update their own inspections"
    ON inspections FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid()::INTEGER 
            AND (
                users.role_id IN (1, 2)
                OR users.id = inspections.inspector_id
            )
        )
    );

-- Políticas para NOTIFICATIONS
CREATE POLICY "Users can view their own notifications"
    ON notifications FOR SELECT
    USING (user_id = auth.uid()::INTEGER);

CREATE POLICY "Users can update their own notifications"
    ON notifications FOR UPDATE
    USING (user_id = auth.uid()::INTEGER);

-- =============================================
-- COMENTÁRIOS NAS TABELAS (DOCUMENTAÇÃO)
-- =============================================

COMMENT ON TABLE clients IS 'Empresas/clientes que contratam os serviços de inspeção';
COMMENT ON TABLE properties IS 'Imóveis/patrimônios dos clientes que serão vistoriados';
COMMENT ON TABLE locations IS 'Hierarquia de localizações dentro dos imóveis (andares, áreas, salas)';
COMMENT ON TABLE assets IS 'Equipamentos e sistemas de prevenção e combate a incêndio';
COMMENT ON TABLE system_types IS 'Tipos de sistemas (Extintor, PCF, Hidrante, etc)';
COMMENT ON TABLE inspections IS 'Vistorias realizadas nos imóveis';
COMMENT ON TABLE inspection_checkpoints IS 'QR Codes escaneados durante a vistoria como checkpoints';
COMMENT ON TABLE inspection_results IS 'Resultados da vistoria para cada item do checklist';
COMMENT ON TABLE non_conformities IS 'Não conformidades identificadas durante as vistorias';
COMMENT ON TABLE compliance_documents IS 'AVCB, CLCB e outros documentos de conformidade';

-- =============================================
-- FIM DO SCHEMA
-- =============================================