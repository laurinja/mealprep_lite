# MealPrep Lite 

![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)

MealPrep Lite é um aplicativo de planejamento de refeições **Offline-First**, focado em estudantes e pessoas ocupadas. Ele permite gerar, organizar e sincronizar um cardápio semanal completo (Segunda a Sábado), garantindo acesso aos dados mesmo sem internet.

## Funcionalidades Principais

* **Planejador Semanal Completo:**
    * Organização visual por abas (Segunda a Sábado).
    * Refeições divididas por tipo: Café da Manhã, Almoço e Jantar.
    * Visualização rica com fotos reais dos pratos (integração Unsplash).
* **Arquitetura Offline-First:**
    * **Cache Local:** Os dados são salvos no dispositivo (`SharedPreferences`) para acesso instantâneo.
    * **Sincronização:** O app sincroniza automaticamente as alterações com a nuvem (`Supabase`) em segundo plano.
* **Algoritmo Inteligente:**
    * Geração de cardápio baseada em preferências (Rápido, Saudável, Vegetariano).
    * Distribuição equilibrada para evitar repetições excessivas durante a semana.
    * Função de troca individual ("Refresh") para substituir uma refeição específica.
* **Perfil do Usuário:**
    * Login e Criação de Conta.
    * Foto de perfil personalizada (Câmera/Galeria) com compressão automática.
    * Sincronização de dados do perfil entre dispositivos.

## 🛠️ Tecnologias Utilizadas

* **Frontend:** [Flutter](https://flutter.dev/) (Framework UI)
* **Gerenciamento de Estado:** [Provider](https://pub.dev/packages/provider)
* **Backend & Database:** [Supabase](https://supabase.com/) (PostgreSQL)
* **Persistência Local:** [Shared Preferences](https://pub.dev/packages/shared_preferences)
* **Imagens:** `image_picker` e `flutter_image_compress`

## ⚙️ Configuração e Execução

Para rodar este projeto, você precisará configurar um projeto gratuito no Supabase.

### 1. Clonar e Instalar Dependências

```bash
git clone [URL_DO_REPOSITORIO]
cd mealprep_lite
flutter pub get
flutter pub run
```
## Estrutura

lib/features/: Código dividido por funcionalidades (Meal, User, Tag).
lib/pages/: Telas (Home, Login, Onboarding).
lib/services/: Serviços globais (PrefsService, Armazenamento Local).

### Autora
Laura bareto
*  email: laurabareto@alunos.utfpr.edu.br

