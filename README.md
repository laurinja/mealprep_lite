# MealPrep Lite 🥗

![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter)

MealPrep Lite é um aplicativo móvel de planejamento de refeições, desenvolvido em Flutter. O projeto foi criado para estudantes com pouco tempo, focando em uma maneira rápida e visual de gerar um plano base de refeições para a semana, sem sobrecarregar o usuário com detalhes.

## 📱 Telas Principais

(Em breve: Adicionar GIFs e screenshots do app)

* Tela de Onboarding (com imagens personalizadas e consentimento de privacidade)
* Tela Inicial (Home) com a seleção de preferências e o plano gerado
* Drawer (na direita) com configurações e Avatar do Usuário

## ✨ Funcionalidades

Este app é uma adaptação do FitWallet, reutilizando a arquitetura base para um novo propósito, e inclui:

* **Planejador de Refeições Simples:**
    * Selecione suas preferências de refeição (ex: 'Rápido', 'Saudável', 'Vegetariano').
    * Gere um plano base de 3 refeições com um único clique.
    * O app utiliza um cardápio de exemplo pré-definido, focado na primeira execução (sem dados pessoais).
* **Onboarding Visual:**
    * Um fluxo de introdução de várias etapas com imagens personalizadas para o app.
    * Coleta de consentimento de Política de Privacidade (simulando conformidade com a LGPD).
* **Design e UI:**
    * Interface totalmente adaptada para a nova identidade visual (Verde, Creme e Marrom).
    * Navegação principal através de um `endDrawer` (menu lateral na direita).
* **Perfil do Usuário com Avatar (Implementado conforme PRD):**
    * Adicione uma foto de perfil personalizada tirando uma foto com a **Câmera** ou escolhendo da **Galeria**.
    * **Compressão de Imagem:** As imagens são redimensionadas (máx 512x512) e comprimidas (qualidade 80) para economizar espaço.
    * **Privacidade (Remoção de EXIF):** Metadados sensíveis (como localização GPS) são removidos da imagem antes de salvar.
    * **Armazenamento Local:** A foto é salva com segurança no diretório de documentos do aplicativo.
    * **Fallback & Remoção:** O usuário pode remover sua foto a qualquer momento. Se nenhuma foto estiver definida, o app exibe um avatar com as iniciais do usuário.
* **Persistência de Dados:**
    * Preferências do usuário (como status do onboarding e consentimento) e o caminho da foto do avatar são salvos localmente usando `shared_preferences`.

## 🛠️ Tecnologias Utilizadas

* **Framework:** [Flutter](https://flutter.dev/)
* **Gerenciamento de Estado:** [Provider](https://pub.dev/packages/provider)
* **Armazenamento Local:** [Shared Preferences](https://pub.dev/packages/shared_preferences)
* **Seleção de Imagem (Câmera/Galeria):** [image_picker](https://pub.dev/packages/image_picker)
* **Processamento de Imagem:** [flutter_image_compress](https://pub.dev/packages/flutter_image_compress)
* **Gerenciamento de Caminhos de Arquivo:** [path_provider](https://pub.dev/packages/path_provider)

## 🚀 Como Executar o Projeto

1.  **Clone o repositório:**
    ```bash
    git clone [URL_DO_SEU_REPOSITORIO]
    cd mealprep_lite
    ```

2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Configure as Permissões (para o Avatar):**
    * Certifique-se de que as permissões de Câmera e Galeria estão configuradas:
    * **iOS:** A aplicação não tem suporte completo para IOS, resultando em erros ao executar o programa.
    * **Android:** Adicione a permissão `android.permission.CAMERA` ao `android/app/src/main/AndroidManifest.xml` (se necessário).

4.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

## 🎓 Contexto do Projeto

Este aplicativo foi desenvolvido como um projeto acadêmico. O desafio principal foi adaptar uma base de código existente (FitWallet) para atender a um novo conjunto de requisitos, implementando uma nova lógica de negócios (MealPrep), uma UI completamente diferente e funcionalidades complexas de nível profissional, como a gestão de avatares de usuário conforme um Documento de Requisitos de Produto (PRD).