# PRD - MealPrep Lite: Planejamento Rápido de Refeições

## 0) Metadados do Projeto

* **Nome do Produto/Projeto:** MealPrep Lite
* **Responsável:** Laura Bareto
* **Curso/Disciplina:** Ciências da Computação/ Desenvolvimento de Aplicações Móveis
* **Versão do PRD:** v1.0
* **Data:** 2025-10-23

## 1) Visão Geral

* **Resumo:** O MealPrep Lite é um aplicativo móvel (Flutter) focado em ajudar estudantes com pouco tempo a planejar um cardápio base para a semana. O foco é na extrema simplicidade: gerar 3 refeições principais com base em preferências, sem exigir dados pessoais.
* **Problemas que ataca:** Fadiga de decisão na hora de cozinhar; falta de tempo para planejamento de refeições complexo; sobrecarga de apps de nutrição.
* **Resultado desejado:** Uma primeira experiência de usuário rápida (onboarding), coleta de consentimento (mínimo) e uma tela inicial que permite ao usuário gerar um plano em dois cliques.

## 2) Personas & Cenários de Primeiro Acesso

* **Persona principal:** Estudante de graduação com pouco tempo, busca inspiração rápida para refeições da semana ("o que vou comer hoje?").
* **Cenário (Happy Path):** Abrir app → Splash (decide rota) → Onboarding (3-4 telas) → Visualizar Política de Privacidade → Dar consentimento explícito → Home → Selecionar preferências → Gerar plano.
* **Cenários Alternativos:**
    * Pular onboarding para a tela de consentimento.
    * Revogar consentimento no Drawer (Configurações) → Retorna ao fluxo de consentimento.
    * Adicionar/Alterar/Remover foto de perfil no Drawer.

## 3) Identidade do Tema (Design)

### 3.1 Paleta e Direção Visual

* **Primária (Green):** `#22C55E`
* **Secundária (Brown):** `#78350F`
* **Acento (Cream):** `#FEF3C7` (Usado como `background`)
* **Superfície/Texto:** `#FFFFFF` (Branco), `#78350F` (Marrom para textos)
* **Direção:** Flat minimalista, amigável, `useMaterial3: true`.

### 3.2 Prompts (Imagens/Ícone)

* **Ícone do app:** "App icon design. A thin-line vector illustration of a simple, modern meal prep container (bento box style). A prominent emerald green checkmark (#22C55E) is stylishly integrated on the container's lid. White background. Minimalist aesthetic."
* **Onboarding Hero (Tela 1):** "A minimalist flat vector illustration of a happy student looking at a weekly meal planner on a tablet. Next to the tablet, there's a simple bento box. Color palette: green (#22C55E), cream (#FEF3C7), and brown (#78350F) on a white background."

## 4) Jornada & Funcionalidades (Escopo)

### 4.1 Onboarding e Consentimento
* **RF-1 (Onboarding):** Fluxo de 4 telas em PageView (`Bem-vindo`, `Como Funciona`, `Privacidade`, `Tudo Pronto!`). Página de privacidade não possui imagem.
* **RF-2 (Consentimento):** Leitura de política (simulada) com rolagem forçada (`_showPrivacyPolicy`). Checkbox de aceite só habilita após a leitura.
* **RF-3 (Revogação):** Opção no Drawer para "Limpar Consentimento". Redireciona para o Onboarding na página de consentimento.

### 4.2 Perfil do Usuário (Avatar)
* **RF-4 (UI do Avatar):** O Drawer (lado direito, `endDrawer`) exibe um `UserAccountsDrawerHeader`.
* **RF-5 (Exibição):** Mostra a foto do usuário (lida do `userPhotoPath` ) usando `FileImage`.
* **RF-6 (Fallback):** Se a foto for nula, exibe um `CircleAvatar` com as iniciais (ex: "A" de Aluna).
* **RF-7 (Ação):** Um botão de "Editar" sobreposto ao avatar abre um `BottomSheet`.
* **RF-8 (Seleção):** O BottomSheet oferece "Câmera", "Galeria" e "Remover Foto".
* **RF-9 (Processamento):** Imagem selecionada é comprimida (máx 512x512, Q80) e metadados EXIF são removidos usando `flutter_image_compress`.
* **RF-10 (Persistência):** A imagem comprimida é salva localmente (`avatar.jpg`) e o caminho é armazenado no `PrefsService`.
* **RF-11 (Remoção):** Ação "Remover" apaga o arquivo local e limpa a chave no `PrefsService`.

### 4.3 Planejador de Refeições (Core Loop)
* **RF-12 (Preferências):** `HomePage` exibe `FilterChip` para o usuário selecionar tags (ex: 'Rápido', 'Saudável').
* **RF-13 (Geração):** Um botão "Gerar Cardápio" chama o `MealService`.
* **RF-14 (Lógica do Serviço):** O serviço filtra uma lista de exemplo (`_cardapioExemplo`) com base nas preferências e retorna 3 refeições aleatórias.
* **RF-15 (Exibição):** `HomePage` exibe os 3 cards de refeição gerados.

## 5) Requisitos Não Funcionais (RNF)

* **RNF-1 (A11Y):** Áreas de toque $\ge 48$dp, `Semantics` e `Tooltip` no avatar.
* **RNF-2 (Privacidade):** Armazenamento da foto é local (MVP). Remoção de EXIF/GPS da imagem. App não coleta dados pessoais para o core loop.
* **RNF-3 (Arquitetura):** Separação de responsabilidades:
    * `HomePage` (UI)
    * `MealService` (Estado das Refeições, via Provider)
    * `PrefsService` (Estado de Configurações, via `SharedPreferences`).
* **RNF-4 (Testabilidade):** Serviços mockáveis para testes de widget.

## 6) Dados & Persistência (Chaves `PrefsService`)

* `onboarding_completed: bool`
* `marketing_consent: bool`
* `user_photo_path: string | null`
* *(O `_cardapioExemplo` e o `_planoSemanal` são gerenciados em memória pelo `MealService` e não persistem ao fechar o app, conforme escopo do MVP "sem dados pessoais").*

## 7) Roteamento 

* `/` → `SplashPage` (Decide rota baseado em `onboarding_completed`)
* `/onboarding` → `OnboardingPage`
* `/home` → `HomePage`
