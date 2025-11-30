# Recomendações para Aplicação Web de Vistoria (Web-Only)

Considerando a decisão de seguir com uma arquitetura **apenas Web** (sem aplicativo nativo Android/iOS), a aplicação deve ser construída como uma **PWA (Progressive Web App)** robusta. Isso garantirá que os inspetores consigam trabalhar em campo (muitas vezes sem internet) usando apenas o navegador do celular ou tablet.

Abaixo listo as recomendações técnicas e funcionais para viabilizar esse cenário.

## 1. Arquitetura e Tecnologia (PWA)

Para substituir a necessidade de um app nativo, a versão web deve se comportar como tal.

*   **Framework:** **Next.js** (React). É a escolha mais sólida para performance, SEO e facilidade de desenvolvimento.
*   **PWA (Progressive Web App):**
    *   **Manifesto:** Permitir que o usuário "instale" o site na tela inicial do celular.
    *   **Service Workers:** Essencial para cache de arquivos estáticos (HTML, CSS, JS), permitindo que o app abra mesmo sem internet.
*   **Banco de Dados Local (Offline-First):**
    *   Como a web não tem acesso direto ao SQLite do celular da mesma forma que um app nativo, recomenda-se usar **IndexedDB**.
    *   **Lib Recomendada:** `Dexie.js` ou `TanStack Query` (com persistência) para gerenciar o estado offline e sincronizar quando a conexão voltar.

## 2. Experiência do Usuário (UX/UI) Mobile-First

O inspetor usará o sistema em pé, em movimento e em telas pequenas.

*   **Design Responsivo Crítico:** A interface de vistoria NÃO pode ser apenas uma versão encolhida do desktop. Ela deve parecer um app.
    *   Botões grandes (touch targets de min. 44px).
    *   Navegação por abas inferiores (bottom navigation) no mobile.
    *   Evitar modais complexos; preferir "drawers" (gavetas) que sobem da parte inferior.
*   **Feedback Visual:** Indicadores claros de status de sincronização ("Salvando...", "Salvo no dispositivo", "Sincronizado com a nuvem").

## 3. Funcionalidades de Hardware via Web

A web moderna permite acesso a quase tudo que precisamos:

*   **Câmera e Fotos:**
    *   Usar o atributo HTML5 `capture="environment"` para abrir a câmera traseira diretamente.
    *   **Compressão no Cliente:** Implementar compressão de imagem (ex: `browser-image-compression`) *antes* do upload para economizar dados móveis e armazenamento.
*   **Leitura de QR Code:**
    *   Utilizar bibliotecas como `html5-qrcode` ou `react-qr-reader`.
    *   *Nota:* A leitura via web pode ser ligeiramente mais lenta que a nativa em ambientes com pouca luz. Prever uma opção de digitar o código manualmente como fallback.
*   **Geolocalização:**
    *   API de Geolocation do navegador (`navigator.geolocation`) para pegar as coordenadas no momento da foto/vistoria.
*   **Assinatura Digital:**
    *   Canvas HTML5 (`react-signature-canvas`) para coletar a assinatura na tela touch.

## 4. Estratégia de Dados e Sincronização

O maior desafio do "Web-Only" em vistorias é a internet intermitente (subsolos, casas de máquinas).

*   **Fluxo de "Check-in":**
    *   O inspetor deve clicar em "Baixar Vistoria" enquanto ainda tem Wi-Fi/4G. Isso carrega os dados do cliente, ativos e checklists para o IndexedDB.
*   **Operação Offline:**
    *   Durante a vistoria, o app lê e grava apenas no IndexedDB local.
*   **Fluxo de Sincronização:**
    *   Ao detectar conexão, o app envia as alterações em background.
    *   Implementar uma fila de requisições (Queue) para garantir que nada se perca se a internet cair no meio do envio.

## 5. Stack Recomendada

*   **Frontend:** Next.js + Tailwind CSS.
*   **Componentes:** Shadcn/UI (bonito, acessível e customizável).
*   **Backend:** Next.js Server Actions (para simplicidade) ou API separada.
*   **Banco de Dados:** PostgreSQL (Supabase, Neon ou Vercel Postgres).
*   **Armazenamento de Arquivos:** S3 (AWS, Cloudflare R2 ou Supabase Storage) para as fotos.
*   **Geração de PDF:** `react-pdf` ou uma API externa (como `Puppeteer` no backend) para gerar os relatórios finais.

## 6. O que perdemos vs. App Nativo? (E como mitigar)

*   **Notificações Push:** No iOS (iPhone), Web Push é suportado apenas em versões mais recentes (iOS 16.4+) e requer que o usuário adicione o app à tela inicial.
    *   *Mitigação:* Usar SMS ou Email para avisos críticos se o Push não for viável.
*   **Manter a tela ligada:** Apps nativos podem forçar a tela a ficar ligada. Na web, isso é experimental (`Screen Wake Lock API`).
    *   *Mitigação:* Orientar o usuário a aumentar o tempo de bloqueio do celular.

## Resumo

A abordagem Web-Only é **totalmente viável** e reduz drasticamente o custo e tempo de desenvolvimento (código único). O segredo está em investir pesado na **Sincronização Offline** e na **UX Mobile**, garantindo que o inspetor não sinta falta de um app nativo.
