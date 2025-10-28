-- Criação do banco
CREATE DATABASE IF NOT EXISTS amigo_fiel
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE amigo_fiel;

-- Tabela: Cliente
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    endereco VARCHAR(255),
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabela: Veterinário
CREATE TABLE veterinario (
    id_vet INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    especialidade VARCHAR(100),
    telefone VARCHAR(20),
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabela: Animal
CREATE TABLE animal (
    id_animal INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    especie VARCHAR(50),
    raca VARCHAR(80),
    sexo ENUM('M','F','Outro') DEFAULT 'M',
    data_nascimento DATE,
    id_cliente INT NOT NULL,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_animal_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Tabela: Consulta
CREATE TABLE consulta (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    data_consulta DATETIME NOT NULL,
    motivo VARCHAR(255),
    observacoes TEXT,
    id_animal INT NOT NULL,
    id_vet INT NOT NULL,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_consulta_animal FOREIGN KEY (id_animal)
        REFERENCES animal(id_animal)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_consulta_vet FOREIGN KEY (id_vet)
        REFERENCES veterinario(id_vet)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Tabela: Tratamento
CREATE TABLE tratamento (
    id_trat INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    id_consulta INT NOT NULL,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_trat_consulta FOREIGN KEY (id_consulta)
        REFERENCES consulta(id_consulta)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Índices
CREATE INDEX idx_animal_cliente ON animal(id_cliente);
CREATE INDEX idx_consulta_animal ON consulta(id_animal);
CREATE INDEX idx_consulta_vet ON consulta(id_vet);
CREATE INDEX idx_trat_consulta ON tratamento(id_consulta);

-- Inserção de dados
INSERT INTO cliente (nome, telefone, email, endereco) VALUES
('Ana Pereira', '91-91234-0000', 'ana@mail.com', 'Rua A, 123'),
('Carlos Silva', '91-92345-1111', 'carlos@mail.com', 'Av. B, 45'),
('Mariana Costa', '91-93456-2222', 'mariana@mail.com', 'Travessa C, 9');

INSERT INTO veterinario (nome, especialidade, telefone) VALUES
('Dra. Joana Martins', 'Clinica Geral', '91-98877-0001'),
('Dr. Pedro Almeida', 'Cirurgia', '91-97766-0002');

INSERT INTO animal (nome, especie, raca, sexo, data_nascimento, id_cliente) VALUES
('Rex', 'Cachorro', 'Labrador', 'M', '2018-05-10', 1),
('Mimi', 'Gato', 'SRD', 'F', '2020-07-20', 1),
('Bolt', 'Cachorro', 'Pinscher', 'M', '2019-12-01', 2),
('Luna', 'Gato', 'Siamês', 'F', '2021-03-14', 3);

INSERT INTO consulta (data_consulta, motivo, observacoes, id_animal, id_vet) VALUES
('2025-10-01 09:00:00', 'Vacinação', 'Vacina anual', 1, 1),
('2025-10-10 14:30:00', 'Corte de unha', 'Sem complicações', 2, 1),
('2025-10-15 11:00:00', 'App: tosse', 'Prescrito xarope', 3, 2),
('2025-10-20 16:00:00', 'Cirurgia pequena', 'Retorno em 7 dias', 1, 2),
('2025-10-21 10:00:00', 'Check-up', 'Exames normais', 4, 1);

INSERT INTO tratamento (descricao, valor, id_consulta) VALUES
('Vacina anti-rábica', 80.00, 1),
('Vacina múltipla', 120.00, 1),
('Corte de unhas', 30.00, 2),
('Antitussígeno', 45.00, 3),
('Sutura e medicação', 300.00, 4),
('Analgesia pós-op', 70.00, 4),
('Exames de rotina', 90.00, 5);

-- Views obrigatórias

-- 1. Clientes e seus animais
CREATE OR REPLACE VIEW vw_animais_clientes AS
SELECT 
    c.nome AS cliente_nome,
    a.nome AS animal_nome,
    a.especie,
    a.raca,
    a.sexo
FROM 
    cliente c
JOIN 
    animal a ON c.id_cliente = a.id_cliente;

-- 2. Consultas por período
CREATE OR REPLACE VIEW vw_consultas_periodo AS
SELECT 
    con.id_consulta,
    con.data_consulta,
    con.motivo,
    a.nome AS animal_nome,
    v.nome AS veterinario_nome
FROM 
    consulta con
JOIN 
    animal a ON con.id_animal = a.id_animal
JOIN 
    veterinario v ON con.id_vet = v.id_vet;

-- 3. Veterinários e número de consultas
CREATE OR REPLACE VIEW vw_vet_consultas AS
SELECT 
    v.nome AS veterinario_nome,
    COUNT(con.id_consulta) AS total_consultas
FROM 
    veterinario v
LEFT JOIN 
    consulta con ON v.id_vet = con.id_vet
GROUP BY 
    v.id_vet, v.nome;

-- 4. Animais com mais de um tratamento
CREATE OR REPLACE VIEW vw_animais_multitratamento AS
SELECT 
    a.nome AS animal_nome,
    COUNT(t.id_trat) AS total_tratamentos
FROM 
    animal a
JOIN 
    consulta con ON a.id_animal = con.id_animal
JOIN 
    tratamento t ON con.id_consulta = t.id_consulta
GROUP BY 
    a.id_animal, a.nome
HAVING 
    COUNT(t.id_trat) > 1;

-- 5. Gastos por cliente e animal
CREATE OR REPLACE VIEW vw_gastos_clientes_animais AS
SELECT 
    c.nome AS cliente_nome,
    a.nome AS animal_nome,
    SUM(t.valor) AS total_gasto
FROM 
    cliente c
JOIN 
    animal a ON c.id_cliente = a.id_cliente
JOIN 
    consulta con ON a.id_animal = con.id_animal
JOIN 
    tratamento t ON con.id_consulta = t.id_consulta
GROUP BY 
    c.nome, a.nome;

-- Consultas baseadas nas views

-- 1. Listar todos os clientes e seus respectivos animais.
SELECT * FROM vw_animais_clientes ORDER BY cliente_nome, animal_nome;

-- 2.Mostrar as consultas realizadas em um determinado período.
SELECT * FROM vw_consultas_periodo
WHERE data_consulta BETWEEN '2025-10-01' AND '2025-10-20'
ORDER BY data_consulta;

-- 3. Exibir os veterinários e a quantidade de consultas que cada um realizou.
SELECT * FROM vw_vet_consultas ORDER BY total_consultas DESC;

-- 4. Mostrar os animais que receberam mais de um tratamento.
SELECT * FROM vw_animais_multitratamento ORDER BY total_tratamentos DESC;

-- 5. Listar o nome do cliente, o nome do animal e o valor total gasto em tratamentos.
SELECT * FROM vw_gastos_clientes_animais ORDER BY total_gasto DESC;
