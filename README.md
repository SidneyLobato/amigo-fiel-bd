# 🐾 Banco de Dados — Clínica Veterinária Amigo Fiel

Este repositório contém o projeto completo de banco de dados para a clínica veterinária fictícia **Amigo Fiel**, desenvolvido como parte do trabalho acadêmico da disciplina **Banco de Dados II** — FASI/UFPA.

---

## 📦 Estrutura do Projeto

- `amigo_fiel.sql`: Script completo com criação de tabelas, inserção de dados, índices e views.
- Consultas obrigatórias implementadas via views:
  - Clientes e seus animais
  - Consultas por período
  - Veterinários e número de consultas
  - Animais com múltiplos tratamentos
  - Gastos por cliente e animal

---

## 🧠 Modelo de Dados

O banco de dados é composto pelas seguintes entidades:

- **cliente**: dados dos tutores
- **animal**: dados dos pets
- **veterinario**: profissionais da clínica
- **consulta**: atendimentos realizados
- **tratamento**: procedimentos aplicados

Relacionamentos:
- Um cliente pode ter vários animais
- Um animal pode passar por várias consultas
- Uma consulta é realizada por um veterinário
- Uma consulta pode ter vários tratamentos

---

## 🛠️ Como usar

1. Importe o arquivo `amigo_fiel.sql` no seu SGBD (ex: MySQL Workbench)
2. Execute o script para criar e popular o banco
3. Utilize as views para realizar as consultas obrigatórias

---

## 📊 Consultas obrigatórias

```sql
-- Clientes e seus animais
SELECT * FROM vw_animais_clientes;

-- Consultas por período
SELECT * FROM vw_consultas_periodo
WHERE data_consulta BETWEEN '2025-10-01' AND '2025-10-20';

-- Veterinários e número de consultas
SELECT * FROM vw_vet_consultas;

-- Animais com múltiplos tratamentos
SELECT * FROM vw_animais_multitratamento;

-- Gastos por cliente e animal
SELECT * FROM vw_gastos_clientes_animais;
