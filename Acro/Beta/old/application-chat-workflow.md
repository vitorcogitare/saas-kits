Vou criar um schema SQL abrangente para o sistema de vistoria e depois explicar o funcionamento da aplicação.

## Schema SQL Completo

```sql
-- Tabela de clientes/empresas
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    document VARCHAR(20),
    email VARCHAR(255),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

-- Tabela de unidades/predios
CREATE TABLE properties (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(id),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

-- Tabela de tipos de sistemas
CREATE TABLE system_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL, -- 'Extintor', 'PCF', 'Hidrante', etc.
    description TEXT,
    active BOOLEAN DEFAULT TRUE
);

-- Tabela de equipamentos/ativos
CREATE TABLE assets (
    id SERIAL PRIMARY KEY,
    property_id INTEGER REFERENCES properties(id),
    system_type_id INTEGER REFERENCES system_types(id),
    parent_asset_id INTEGER REFERENCES assets(id), -- Para hierarquia
    qr_code VARCHAR(100) UNIQUE NOT NULL,
    identifier VARCHAR(100) NOT NULL, -- 'EXT-001', 'PCF-01A'
    location_description TEXT,
    technical_specs JSONB, -- Dados específicos por tipo
    installation_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

-- Tabela de modelos de checklist
CREATE TABLE checklist_templates (
    id SERIAL PRIMARY KEY,
    system_type_id INTEGER REFERENCES system_types(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    based_on_norm VARCHAR(100), -- 'NBR 12693', etc.
    version VARCHAR(20),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de itens do checklist
CREATE TABLE checklist_items (
    id SERIAL PRIMARY KEY,
    checklist_template_id INTEGER REFERENCES checklist_templates(id),
    question_text TEXT NOT NULL,
    help_text TEXT,
    item_order INTEGER NOT NULL,
    severity_level VARCHAR(20) DEFAULT 'medium', -- low, medium, high, critical
    is_required BOOLEAN DEFAULT TRUE,
    requires_photo BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE
);

-- Tabela de vistorias agendadas/programadas
CREATE TABLE scheduled_inspections (
    id SERIAL PRIMARY KEY,
    property_id INTEGER REFERENCES properties(id),
    assigned_to INTEGER REFERENCES users(id),
    scheduled_date DATE NOT NULL,
    deadline_date DATE,
    status VARCHAR(20) DEFAULT 'pending', -- pending, in_progress, completed, cancelled
    priority VARCHAR(20) DEFAULT 'normal',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela principal de vistorias
CREATE TABLE inspections (
    id SERIAL PRIMARY KEY,
    scheduled_inspection_id INTEGER REFERENCES scheduled_inspections(id),
    property_id INTEGER REFERENCES properties(id),
    inspector_id INTEGER REFERENCES users(id),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(20) DEFAULT 'draft', -- draft, in_progress, completed, signed
    weather_conditions VARCHAR(100),
    temperature DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de vistoria por sistema
CREATE TABLE inspection_systems (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER REFERENCES inspections(id),
    system_type_id INTEGER REFERENCES system_types(id),
    status VARCHAR(20) DEFAULT 'pending',
    completed_at TIMESTAMP,
    notes TEXT
);

-- Tabela de resultados da vistoria por asset
CREATE TABLE inspection_results (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER REFERENCES inspections(id),
    asset_id INTEGER REFERENCES assets(id),
    checklist_item_id INTEGER REFERENCES checklist_items(id),
    compliance_status VARCHAR(20) NOT NULL, -- compliant, non_compliant, not_applicable, not_verified
    observations TEXT,
    severity VARCHAR(20), -- Pode herdar do template ou ser sobrescrito
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de mídia/evidências
CREATE TABLE inspection_media (
    id SERIAL PRIMARY KEY,
    inspection_result_id INTEGER REFERENCES inspection_results(id),
    asset_id INTEGER REFERENCES assets(id),
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(10), -- jpg, png, mp4, etc.
    caption TEXT,
    coordinates POINT, -- Geolocalização
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de assinaturas
CREATE TABLE inspection_signatures (
    id SERIAL PRIMARY KEY,
    inspection_id INTEGER REFERENCES inspections(id),
    signer_name VARCHAR(255) NOT NULL,
    signer_role VARCHAR(100),
    signature_data TEXT NOT NULL, -- Base64 ou path para imagem
    signed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    signer_type VARCHAR(20) -- inspector, client, witness
);

-- Tabela de não conformidades
CREATE TABLE non_conformities (
    id SERIAL PRIMARY KEY,
    inspection_result_id INTEGER REFERENCES inspection_results(id),
    asset_id INTEGER REFERENCES assets(id),
    description TEXT NOT NULL,
    severity VARCHAR(20) NOT NULL,
    deadline DATE,
    assigned_to INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'open', -- open, in_progress, resolved, cancelled
    resolution_notes TEXT,
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de usuários
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL, -- inspector, manager, admin, client
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela para configurações de notificação
CREATE TABLE notification_settings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    notification_type VARCHAR(50),
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de logs de sincronização offline
CREATE TABLE sync_logs (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100),
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(50), -- upload, download
    records_count INTEGER,
    sync_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'completed'
);

-- Índices para performance
CREATE INDEX idx_assets_qr_code ON assets(qr_code);
CREATE INDEX idx_assets_property_id ON assets(property_id);
CREATE INDEX idx_inspections_property_id ON inspections(property_id);
CREATE INDEX idx_inspections_inspector_id ON inspections(inspector_id);
CREATE INDEX idx_inspection_results_asset_id ON inspection_results(asset_id);
CREATE INDEX idx_inspection_results_inspection_id ON inspection_results(inspection_id);
CREATE INDEX idx_non_conformities_status ON non_conformities(status);
CREATE INDEX idx_non_conformities_deadline ON non_conformities(deadline);
```

## Funcionamento da Aplicação em Tese

### 1. **Pré-Configuração (Backoffice)**
- **Cadastro de Clientes e Propriedades**: Empresas e seus imóveis são cadastrados no sistema
- **Configuração de Templates**: Checklists padronizados por tipo de sistema (Extintor, PCF, Hidrante) baseados em normas
- **Cadastro de Ativos**: Cada equipamento recebe um QR Code único e é registrado com suas especificações

### 2. **Fluxo Principal de Vistoria**

#### **Fase 1: Planejamento**
```
Cliente/Propriedade → Agenda Vistoria → Atribui Inspetor → Gera Checklist
```

#### **Fase 2: Execução no Campo (App Móvel)**
```
Inspector Chega no Local → Abre App (Offline/Online)
```
**Para cada equipamento:**
1. Escaneia QR Code → App carrega dados do ativo e checklist específico
2. Percorre itens do checklist → Marca conformidade/não conformidade
3. Para não conformidades: 
   - Tira fotos/evidências (com carimbo data/hora e geolocalização)
   - Registra observações
   - Classifica severidade
4. Assinatura digital do cliente no local

#### **Fase 3: Sincronização e Relatórios**
- Dados sincronizados com nuvem quando online
- Geração automática de relatórios PDF com:
  - Sumário executivo
  - Fotos das não conformidades
  - Planilha de ações corretivas
  - Assinaturas digitais

### 3. **Módulos Específicos por Sistema**

#### **Extintores:**
- Verificação de pressão, lacre, data validade, sinalização
- Histórico de recargas e manutenções

#### **Portas Corta-Fogo (PCF):**
- Verificação de folgas, molas de fechamento, guarnições
- Teste de funcionalidade dos componentes

#### **Hidrantes:**
- Verificação de mangueiras, acessórios, pressão
- Estado de conservação do abrigo

#### **Sistema de Alarme:**
- Teste de acionadores manuais e detectores
- Verificação da central e baterias

### 4. **Workflows Pós-Vistoria**

#### **Gestão de Não Conformidades:**
```
Não Conformidade Identificada → Cria Chamado → Atribui Responsável
→ Acompanha Prazo → Verifica Resolução → Fecha Ciclo
```

#### **Alertas e Notificações:**
- Prazos de vencimento de manutenções
- Não conformidades críticas não resolvidas
- Vistorias pendentes

### 5. **Funcionalidades Avançadas**

#### **Offline First:**
- Todos os dados necessários baixados para o dispositivo
- Sincronização bidirecional quando conectado
- Resolução de conflitos por timestamp

#### **Business Intelligence:**
- Dashboard com métricas de conformidade
- Análise de tendências de falhas
- Mapa de calor de problemas por sistema

#### **Integrações:**
- Exportação para sistemas do Corpo de Bombeiros
- Integração com ERPs de facilities
- API para terceiros

### 6. **Fluxo de Dados**

```
App Móvel (Field) ←→ API REST ←→ Banco de Dados
                         ↑
              Relatórios ← Dashboard (Web)
                         ↑
                 Notificações ← Sistema de Alertas
```

### 7. **Benefícios do Sistema**

1. **Padronização**: Todos os inspetores seguem mesma metodologia
2. **Rastreabilidade**: Histórico completo de cada equipamento
3. **Confiabilidade**: Evidências fotográficas e assinaturas digitais
4. **Eficiência**: Redução de tempo em relatórios manuais
5. **Conformidade Legal**: Baseado em normas técnicas oficiais
6. **Prevenção**: Alertas proativos baseados em dados históricos

Esta arquitetura permite um ciclo completo de gestão da segurança contra incêndio, desde a inspeção até a correção de problemas, com total transparência e rastreabilidade.