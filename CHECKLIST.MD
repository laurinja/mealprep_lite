# Checklist de Entrega - Arquitetura de Domínio

Projeto: **MealPrep Lite**
Aluno: **Laura Kauana Bareto**

Este checklist confirma a implementação da arquitetura Entity/DTO/Mapper para as quatro entidades de domínio solicitadas.

---

### 1. Entidade: `Usuario`
- [x] **Entity:** `lib/features/user/domain/entities/usuario.dart`
- [x] **Value Object:** `lib/features/user/domain/value_objects/email.dart` (Garante tipo forte e invariante)
- [x] **DTO:** `lib/features/user/data/dtos/usuario_dto.dart`
- [x] **Mapper:** `lib/features/user/data/mappers/usuario_mapper.dart` (Converte `String` ↔ `Email`)
- [x] **Exemplo/Teste:** `lib/example_mapper_test.dart` (Função `runMapperExamples()`)

### 2. Entidade: `Refeicao`
- [x] **Entity:** `lib/features/meal/domain/entities/refeicao.dart` (Garante nome não vazio)
- [x] **DTO:** `lib/features/meal/data/dtos/refeicao_dto.dart`
- [x] **Mapper:** `lib/features/meal/data/mappers/refeicao_mapper.dart`
- [x] **Exemplo/Teste:** `lib/example_mapper_test.dart` (Função `runMapperExamples()`)

### 3. Entidade: `Tag`
- [x] **Entity:** `lib/features/tag/domain/entities/tag.dart` (Garante nome não vazio)
- [x] **DTO:** `lib/features/tag/data/dtos/tag_dto.dart`
- [x] **Mapper:** `lib/features/tag/data/mappers/tag_mapper.dart`
- [x] **Exemplo/Teste:** `lib/example_mapper_test.dart` (Função `runMapperExamples()`)

### 4. Entidade: `Ingrediente`
- [x] **Entity:** `lib/features/ingredient/domain/entities/ingrediente.dart` (Garante nome não vazio)
- [x] **DTO:** `lib/features/ingredient/data/dtos/ingrediente_dto.dart`
- [x] **Mapper:** `lib/features/ingredient/data/mappers/ingrediente_mapper.dart`
- [x] **Exemplo/Teste:** `lib/example_mapper_test.dart` (Função `runMapperExamples()`)