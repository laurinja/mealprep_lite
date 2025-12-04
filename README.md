# MealPrep Lite 

![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)

**MealPrep Lite** é um aplicativo de planejamento de refeições **Offline-First**, focado em estudantes e pessoas ocupadas. Ele permite gerar, organizar e sincronizar um cardápio semanal completo (Segunda a Sábado), garantindo acesso aos dados mesmo sem internet.

---

## Funcionalidades Principais

### Planejador Semanal Completo
* **Organização Visual:** Navegação por abas para cada dia da semana (Segunda a Sábado).
* **Refeições por Tipo:** Divisão clara entre Café da Manhã, Almoço e Jantar.
* **Visualização Rica:** Fotos reais dos pratos para facilitar a identificação e apetite (integração Unsplash).

### Arquitetura Offline-First
* **Cache Local:** Os dados são salvos no dispositivo (`SharedPreferences`) para acesso instantâneo, sem depender de conexão.
* **Sincronização:** O app sincroniza automaticamente as alterações com a nuvem (`Supabase`) em segundo plano assim que houver conexão.

### Algoritmo Inteligente
* **Geração Automática:** Cria cardápios baseados em preferências (Rápido, Saudável, Vegetariano).
* **Distribuição Equilibrada:** Evita repetições excessivas de pratos durante a semana.
* **Troca Individual:** Função de "Refresh" para substituir apenas uma refeição específica sem alterar o resto da semana.

### Perfil do Usuário
* **Autenticação:** Login e Criação de Conta seguros.
* **Personalização:** Foto de perfil (Câmera/Galeria) com compressão automática de imagem.
* **Sincronização:** Dados do perfil e preferências sincronizados entre dispositivos.

---

## Tecnologias Utilizadas

* **Frontend:** [Flutter](https://flutter.dev/)
* **Gerenciamento de Estado:** [Provider](https://pub.dev/packages/provider)
* **Backend & Database:** [Supabase](https://supabase.com/) (PostgreSQL)
* **Persistência Local:** [Shared Preferences](https://pub.dev/packages/shared_preferences)
* **Imagens:** `image_picker` e `flutter_image_compress`

---

👩‍💻 Autora
Laura Bareto 
📧 Email: laurabareto@alunos.utfpr.edu.br

