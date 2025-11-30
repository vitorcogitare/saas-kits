# 🔥 Recomendações Frontend - Sistema de Inspeção contra Incêndio

## 📱 Stack Tecnológica Recomendada (v0.dev)

### **Framework Base**
- **Next.js 14+** (App Router)
- **React 18+**
- **TypeScript**
- **Tailwind CSS** (já vem no v0)

### **Bibliotecas Essenciais**
```json
{
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0",
    "@supabase/auth-helpers-nextjs": "^0.10.0",
    "zustand": "^4.5.0", // State management
    "react-hook-form": "^7.49.0", // Forms
    "zod": "^3.22.0", // Validation
    "@tanstack/react-query": "^5.17.0", // Data fetching
    "react-qr-scanner": "^1.0.0", // QR Code scanner
    "html5-qrcode": "^2.3.8", // QR Code scanner alternativo
    "react-signature-canvas": "^1.0.6", // Assinaturas digitais
    "recharts": "^2.10.0", // Gráficos e dashboards
    "date-fns": "^3.0.0", // Manipulação de datas
    "react-hot-toast": "^2.4.1", // Notificações
    "framer-motion": "^10.18.0", // Animações
    "lucide-react": "^0.263.1", // Ícones
    "cmdk": "^0.2.0", // Command palette
    "vaul": "^0.9.0", // Bottom sheets (mobile)
    "@radix-ui/react-*": "latest", // Componentes acessíveis
    "react-hook-geolocation": "^1.0.11", // Geolocalização
    "workbox-*": "^7.0.0" // PWA/Offline
  }
}
```

---

## 🎨 Estrutura de Pastas (Next.js App Router)

```
src/
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   └── register/
│   ├── (dashboard)/
│   │   ├── layout.tsx
│   │   ├── page.tsx (Dashboard principal)
│   │   ├── clients/
│   │   ├── properties/
│   │   ├── assets/
│   │   ├── inspections/
│   │   │   ├── page.tsx (Lista)
│   │   │   ├── [id]/
│   │   │   │   ├── page.tsx (Detalhes)
│   │   │   │   └── execute/page.tsx (Executar vistoria)
│   │   │   └── new/page.tsx
│   │   ├── non-conformities/
│   │   ├── reports/
│   │   └── settings/
│   ├── api/
│   │   ├── webhooks/
│   │   └── cron/
│   └── layout.tsx
├── components/
│   ├── ui/ (shadcn/ui components)
│   ├── shared/
│   │   ├── Header.tsx
│   │   ├── Sidebar.tsx
│   │   ├── BottomNav.tsx (Mobile)
│   │   └── PWAInstallPrompt.tsx
│   ├── inspection/
│   │   ├── QRScanner.tsx
│   │   ├── ChecklistItem.tsx
│   │   ├── PhotoCapture.tsx
│   │   └── SignaturePad.tsx
│   ├── assets/
│   │   ├── AssetCard.tsx
│   │   └── AssetMap.tsx
│   └── dashboard/
│       ├── StatCard.tsx
│       └── MaintenanceAlert.tsx
├── lib/
│   ├── supabase/
│   │   ├── client.ts
│   │   ├── server.ts
│   │   └── middleware.ts
│   ├── stores/
│   │   ├── authStore.ts
│   │   ├── inspectionStore.ts
│   │   └── offlineStore.ts
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useInspection.ts
│   │   ├── useQRScanner.ts
│   │   └── useOfflineSync.ts
│   ├── utils/
│   │   ├── offline.ts
│   │   ├── geolocation.ts
│   │   └── formatters.ts
│   └── validations/
│       └── schemas.ts
├── types/
│   ├── database.types.ts (Gerado pelo Supabase)
│   └── app.types.ts
└── public/
    ├── icons/
    ├── manifest.json
    └── sw.js
```

---

## 🎯 Páginas Principais e Funcionalidades

### **1. Dashboard Principal** 
**Rota:** `/dashboard`

**Componentes:**
```tsx
<Dashboard>
  {/* Cards de Estatísticas */}
  <StatGrid>
    <StatCard title="Vistorias Pendentes" value={12} icon={ClipboardList} />
    <StatCard title="Não Conformidades" value={5} icon={AlertTriangle} />
    <StatCard title="Manutenções Vencendo" value={8} icon={Wrench} />
    <StatCard title="Documentos Expirando" value={3} icon={FileWarning} />
  </StatGrid>

  {/* Gráficos */}
  <ChartGrid>
    <InspectionTrendChart />
    <NonConformitiesBySeverityChart />
  </ChartGrid>

  {/* Listas Rápidas */}
  <QuickLists>
    <UpcomingInspections />
    <RecentNonConformities />
  </QuickLists>
</Dashboard>
```

**Permissões por Role:**
- **Cliente:** Vê apenas dados de seus imóveis
- **Inspetor:** Vê vistorias atribuídas a ele
- **Gerente/Admin:** Vê tudo

---

### **2. Patrimônios (Properties)**
**Rota:** `/dashboard/properties`

**Funcionalidades:**
- Lista de imóveis em cards com mapa
- Filtros: cliente, cidade, status
- Visualização em mapa (Google Maps/Mapbox)
- Detalhes do imóvel com:
  - Equipamentos instalados
  - Histórico de vistorias
  - Documentos (AVCB/CLCB)
  - Não conformidades ativas

**Componente Principal:**
```tsx
<PropertyList>
  <PropertyMap locations={properties} />
  <PropertyGrid>
    {properties.map(property => (
      <PropertyCard
        key={property.id}
        property={property}
        onViewDetails={() => router.push(`/properties/${property.id}`)}
      />
    ))}
  </PropertyGrid>
</PropertyList>
```

---

### **3. Equipamentos (Assets)**
**Rota:** `/dashboard/assets`

**Funcionalidades:**
- Lista de equipamentos com filtros avançados
- Busca por QR Code
- Visualização por tipo de sistema (Extintor, PCF, etc)
- Status de manutenção (ok, vencendo, vencido)
- Geração de QR Codes para impressão
- Upload de fotos dos equipamentos

**Filtros:**
```tsx
<AssetFilters>
  <PropertySelect />
  <SystemTypeSelect />
  <StatusSelect />
  <LocationSelect />
  <MaintenanceStatusSelect />
</AssetFilters>
```

**Card de Equipamento:**
```tsx
<AssetCard>
  <AssetQRCode value={asset.qr_code} />
  <AssetInfo>
    <Badge>{asset.system_type_name}</Badge>
    <h3>{asset.identifier}</h3>
    <p>{asset.location_name}</p>
  </AssetInfo>
  <MaintenanceStatus status={asset.maintenance_status} />
  <AssetActions>
    <Button>Ver Detalhes</Button>
    <Button>Histórico</Button>
  </AssetActions>
</AssetCard>
```

---

### **4. Execução de Vistoria (CRÍTICO - Mobile First)**
**Rota:** `/dashboard/inspections/[id]/execute`

**Fluxo da Vistoria:**

#### **Passo 1: Escanear QR Code do Local**
```tsx
<QRScannerStep>
  <QRScanner
    onScan={(location) => {
      // Registra checkpoint
      registerCheckpoint(location.id)
      // Carrega equipamentos do local
      loadAssetsForLocation(location.id)
    }}
  />
  <LocationInfo>
    <h2>{currentLocation.name}</h2>
    <Badge>{currentLocation.code}</Badge>
  </LocationInfo>
</QRScannerStep>
```

#### **Passo 2: Escanear QR Code do Equipamento**
```tsx
<AssetScannerStep>
  <QRScanner
    onScan={(asset) => {
      // Carrega checklist para o equipamento
      loadChecklistForAsset(asset)
    }}
  />
  <AssetPreview asset={currentAsset} />
</AssetScannerStep>
```

#### **Passo 3: Checklist do Equipamento**
```tsx
<ChecklistStep>
  <ChecklistProgress current={5} total={12} />
  
  {checklistItems.map((item, index) => (
    <ChecklistItemCard key={item.id}>
      <QuestionText>{item.question_text}</QuestionText>
      {item.help_text && <HelpText>{item.help_text}</HelpText>}
      
      {/* Tipos de Resposta */}
      {item.type === 'yes_no' && (
        <YesNoButtons
          onChange={(value) => saveResponse(item.id, value)}
        />
      )}
      
      {item.type === 'compliant' && (
        <ComplianceSelect
          options={['compliant', 'non_compliant', 'not_applicable']}
          onChange={(value) => saveResponse(item.id, value)}
        />
      )}
      
      {item.type === 'numeric' && (
        <NumericInput
          min={item.validation_rules.min}
          max={item.validation_rules.max}
          onChange={(value) => saveResponse(item.id, value)}
        />
      )}
      
      {/* Campo de Observações */}
      <Textarea placeholder="Observações (opcional)" />
      
      {/* Captura de Foto (se obrigatória) */}
      {item.requires_photo && (
        <PhotoCapture
          onCapture={(photo) => uploadPhoto(item.id, photo)}
        />
      )}
      
      {/* Indicador de Severidade */}
      {item.severity_level === 'critical' && (
        <Badge variant="destructive">Item Crítico</Badge>
      )}
    </ChecklistItemCard>
  ))}
  
  <NavigationButtons>
    <Button variant="outline" onClick={previousItem}>Anterior</Button>
    <Button onClick={nextItem}>Próximo</Button>
  </NavigationButtons>
</ChecklistStep>
```

#### **Passo 4: Revisão e Assinatura**
```tsx
<ReviewStep>
  <InspectionSummary>
    <StatCard title="Itens Verificados" value={totalItems} />
    <StatCard title="Conformes" value={compliantItems} />
    <StatCard title="Não Conformes" value={nonCompliantItems} />
  </InspectionSummary>
  
  <NonConformitiesList>
    {nonConformities.map(nc => (
      <NonConformityCard key={nc.id} nc={nc} />
    ))}
  </NonConformitiesList>
  
  <SignatureSection>
    <SignaturePad
      onSave={(signature) => saveSignature('inspector', signature)}
    />
    <SignaturePad
      label="Assinatura do Responsável"
      onSave={(signature) => saveSignature('client', signature)}
    />
  </SignatureSection>
  
  <Button size="lg" onClick={finalizeInspection}>
    Finalizar Vistoria
  </Button>
</ReviewStep>
```

---

### **5. Não Conformidades**
**Rota:** `/dashboard/non-conformities`

**Funcionalidades:**
- Lista com filtros (status, severidade, prazo)
- Kanban board (Aberto → Em Progresso → Resolvido)
- Criação de planos de ação
- Anexar fotos de resolução
- Timeline de ações

**Componente Kanban:**
```tsx
<NonConformitiesKanban>
  <Column title="Aberto" status="open">
    {openNCs.map(nc => (
      <NCCard 
        key={nc.id} 
        nc={nc}
        onDrag={handleDrag}
      />
    ))}
  </Column>
  <Column title="Em Progresso" status="in_progress">
    {/* ... */}
  </Column>
  <Column title="Resolvido" status="resolved">
    {/* ... */}
  </Column>
</NonConformitiesKanban>
```

---

### **6. Relatórios**
**Rota:** `/dashboard/reports`

**Funcionalidades:**
- Seleção de template
- Visualização prévia
- Geração em PDF (usando jsPDF ou react-pdf)
- Download e compartilhamento
- Histórico de relatórios gerados

**Tipos de Relatórios:**
1. Relatório Completo de Vistoria
2. Sumário Executivo
3. Relatório de Não Conformidades
4. Inventário de Equipamentos
5. Relatório de Manutenções

```tsx
<ReportGenerator>
  <ReportTemplateSelect />
  <ReportFilters>
    <DateRangePicker />
    <PropertySelect />
    <InspectionSelect />
  </ReportFilters>
  <ReportPreview>
    <PDFViewer document={reportDocument} />
  </ReportPreview>
  <ReportActions>
    <Button onClick={downloadPDF}>Download PDF</Button>
    <Button onClick={sharePDF}>Compartilhar</Button>
  </ReportActions>
</ReportGenerator>
```

---

## 📱 Componentes Mobile-First Essenciais

### **1. Bottom Navigation (Mobile)**
```tsx
<BottomNav>
  <NavItem icon={Home} label="Início" href="/dashboard" />
  <NavItem icon={Building} label="Imóveis" href="/properties" />
  <NavItem icon={QrCode} label="Escanear" href="/scan" />
  <NavItem icon={ClipboardList} label="Vistorias" href="/inspections" />
  <NavItem icon={User} label="Perfil" href="/profile" />
</BottomNav>
```

### **2. QR Scanner Component**
```tsx
<QRScanner>
  <Camera />
  <ScanOverlay>
    <ScanFrame />
    <Instructions>Aponte para o QR Code</Instructions>
  </ScanOverlay>
  <FlashlightToggle />
  <ManualEntryButton />
</QRScanner>
```

### **3. Photo Capture Component**
```tsx
<PhotoCapture>
  <CameraView />
  <CaptureButton onClick={takePhoto} />
  <Gallery photos={capturedPhotos} />
  <PhotoPreview>
    <Image src={currentPhoto} />
    <Actions>
      <Button onClick={retake}>Refazer</Button>
      <Button onClick={confirm}>Confirmar</Button>
    </Actions>
  </PhotoPreview>
</PhotoCapture>
```

### **4. Offline Indicator**
```tsx
<OfflineIndicator>
  {isOffline && (
    <Toast>
      <WifiOff />
      <span>Modo Offline - Dados serão sincronizados</span>
    </Toast>
  )}
  {isSyncing && (
    <Toast>
      <RefreshCw className="animate-spin" />
      <span>Sincronizando... {syncProgress}%</span>
    </Toast>
  )}
</OfflineIndicator>
```

---

## 🔐 Autenticação e Permissões (Supabase)

### **Setup Supabase Client**
```typescript
// lib/supabase/client.ts
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { Database } from '@/types/database.types'

export const supabase = createClientComponentClient<Database>()
```

### **Middleware de Autenticação**
```typescript
// middleware.ts
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'

export async function middleware(req: Request) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req, res })
  
  const { data: { session } } = await supabase.auth.getSession()
  
  if (!session && req.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', req.url))
  }
  
  return res
}
```

### **Hook de Permissões**
```typescript
// lib/hooks/usePermissions.ts
export function usePermissions() {
  const { user } = useAuth()
  
  const hasPermission = (permission: string) => {
    return user?.role?.permissions.includes(permission)
  }
  
  const canViewAssets = hasPermission('assets.view')
  const canCreateAssets = hasPermission('assets.create')
  const canExecuteInspections = hasPermission('inspections.execute')
  
  return {
    hasPermission,
    canViewAssets,
    canCreateAssets,
    canExecuteInspections
  }
}
```

---

## 💾 Funcionalidade Offline (PWA)

### **Service Worker Configuration**
```javascript
// public/sw.js
const CACHE_NAME = 'fire-inspection-v1'
const urlsToCache = [
  '/',
  '/dashboard',
  '/offline',
  '/manifest.json'
]

// Cache strategies
self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('/api/')) {
    // Network first for API calls
    event.respondWith(networkFirst(event.request))
  } else {
    // Cache first for static assets
    event.respondWith(cacheFirst(event.request))
  }
})
```

### **Offline Store (Zustand)**
```typescript
// lib/stores/offlineStore.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface OfflineStore {
  pendingInspections: Inspection[]
  pendingPhotos: Photo[]
  addPendingInspection: (inspection: Inspection) => void
  syncPendingData: () => Promise<void>
}

export const useOfflineStore = create<OfflineStore>()(
  persist(
    (set, get) => ({
      pendingInspections: [],
      pendingPhotos: [],
      
      addPendingInspection: (inspection) => {
        set(state => ({
          pendingInspections: [...state.pendingInspections, inspection]
        }))
      },
      
      syncPendingData: async () => {
        const { pendingInspections } = get()
        // Sync logic here
      }
    }),
    {
      name: 'offline-storage'
    }
  )
)
```

### **Auto-Sync Hook**
```typescript
// lib/hooks/useAutoSync.ts
export function useAutoSync() {
  const { syncPendingData } = useOfflineStore()
  const [isOnline, setIsOnline] = useState(navigator.onLine)
  
  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true)
      syncPendingData()
    }
    
    window.addEventListener('online', handleOnline)
    return () => window.removeEventListener('online', handleOnline)
  }, [])
  
  return { isOnline }
}
```

---

## 🎨 Design System (Tailwind + shadcn/ui)

### **Paleta de Cores**
```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        // Brand colors
        primary: {
          50: '#fef2f2',
          500: '#ef4444', // Vermelho fogo
          900: '#7f1d1d'
        },
        // Status colors
        success: '#22c55e',
        warning: '#f59e0b',
        danger: '#ef4444',
        // Severity colors
        severity: {
          low: '#3b82f6',
          medium: '#f59e0b',
          high: '#f97316',
          critical: '#dc2626'
        }
      }
    }
  }
}
```

### **Componentes Base (shadcn/ui)**
Instalar via CLI:
```bash
npx shadcn-ui@latest init
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add form
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add dropdown-menu
npx shadcn-ui@latest add toast
npx shadcn-ui@latest add badge
npx shadcn-ui@latest add tabs
npx shadcn-ui@latest add select
npx shadcn-ui@latest add calendar
```

---

## 📦 Integração com Supabase Storage

### **Upload de Fotos**
```typescript
// lib/utils/uploadPhoto.ts
export async function uploadInspectionPhoto(
  inspectionId: string,
  assetId: string,
  file: File
) {
  const fileName = `${inspectionId}/${assetId}/${Date.now()}-${file.name}`
  
  const { data, error } = await supabase.storage
    .from('inspection-photos')
    .upload(fileName, file, {
      cacheControl: '3600',
      upsert: false
    })
  
  if (error) throw error
  
  const { data: { publicUrl } } = supabase.storage
    .from('inspection-photos')
    .getPublicUrl(fileName)
  
  return publicUrl
}
```

### **Buckets do Supabase Storage**
```sql
-- Criar buckets no Supabase
INSERT INTO storage.buckets (id, name, public) VALUES
  ('inspection-photos', 'inspection-photos', false),
  ('asset-photos', 'asset-photos', false),
  ('reports', 'reports', false),
  ('signatures', 'signatures', false),
  ('documents', 'documents', false);

-- Políticas de acesso
CREATE POLICY "Authenticated users can upload photos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'inspection-photos' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Users can view their own photos"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'inspection-photos'
  AND auth.role() = 'authenticated'
);
```

---

## 🚀 Otimizações de Performance

### **1. Image Optimization**
```tsx
import Image from 'next/image'

<Image
  src={asset.photo_url}
  alt={asset.identifier}
  width={400}
  height={300}
  loading="lazy"
  placeholder="blur"
/>
```

### **2. Code Splitting**
```tsx
import dynamic from 'next/dynamic'

const QRScanner = dynamic(() => import('@/components/QRScanner'), {
  loading: () => <Skeleton />,
  ssr: false
})
```

### **3. React Query Cache**
```typescript
// app/providers.tsx
<QueryClientProvider client={queryClient}>
  <ReactQueryDevtools />
  {children}
</QueryClientProvider>

// Query com cache
const { data: assets } = useQuery({
  queryKey: ['assets', propertyId],
  queryFn: () => fetchAssets(propertyId),
  staleTime: 1000 * 60 * 5, // 5 minutos
  cacheTime: 1000 * 60 * 30 // 30 minutos
})
```

---

## 📲 PWA Configuration

### **manifest.json**
```json
{
  "name": "Fire Inspection System",
  "short_name": "Fire Inspect",
  "description": "Sistema de Gestão e Inspeção de Sistemas contra Incêndio",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#ef4444",
  "orientation": "portrait",
  "icons": [
    {
      "src": "/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshots/dashboard.png",
      "sizes": "540x720",
      "type": "image/png"
    }
  ],
  "shortcuts": [
    {
      "name": "Nova Vistoria",
      "url": "/dashboard/inspections/new",
      "icons": [{ "src": "/icons/inspection.png", "sizes": "96x96" }]
    },
    {
      "name": "Escanear QR Code",
      "url": "/scan",
      "icons": [{ "src": "/icons/qr.png", "sizes": "96x96" }]
    }
  ]
}
```

---

## 🎯 Prioridades de Implementação

### **Sprint 1 - MVP (2-3 semanas)**
1. ✅ Setup Next.js + Supabase
2. ✅ Autenticação e roles
3. ✅ CRUD de Assets
4. ✅ CRUD de Properties/Locations
5. ✅ QR Code scanner básico
6. ✅ Checklist execution (sem fotos)

### **Sprint 2 - Core Features (2-3 semanas)**
1. ✅ Photo capture e upload
2. ✅ Assinaturas digitais
3. ✅ Não conformidades
4. ✅ Geração de relatórios básicos
5. ✅ Dashboard com estatísticas

### **Sprint 3 - Advanced Features (2-3 semanas)**
1. ✅ Funcionalidade offline (PWA)
2. ✅ Sync automático
3. ✅ Notificações push
4. ✅ Relatórios avançados com templates
5. ✅ Mapa de equipamentos

### **Sprint 4 - Polish (1-2 semanas)**
1. ✅ Otimizações de performance
2. ✅ Testes E2E
3. ✅ Melhorias de UX/UI
4. ✅ Documentação

---

## 🧪 Testes Recomendados

```bash
# Unit tests
npm install -D @testing-library/react @testing-library/jest-dom vitest

# E2E tests
npm install -D @playwright/test

# Visual regression
npm install -D @chromatic-com/storybook
```

---

## ✅ Checklist Final

- [ ] Setup do projeto no v0.dev
- [ ] Configurar Supabase (database + auth + storage)
- [ ] Implementar RLS policies
- [ ] Criar componentes base (shadcn/ui)
- [ ] Implementar autenticação
- [ ] Desenvolver fluxo de vistoria
- [ ] Implementar QR scanner
- [ ] Adicionar funcionalidade offline
- [ ] Configurar PWA
- [ ] Testar em dispositivos móveis
- [ ] Deploy (Vercel)

---

**Próximos Passos:**
1. Iniciar projeto no v0.dev com Next.js
2. Configurar Supabase e executar o schema SQL
3. Gerar tipos do Supabase: `npx supabase gen types typescript`
4. Começar pelo fluxo de autenticação e dashboard