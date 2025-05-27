
-- 1. Criar banco de dados
CREATE DATABASE IF NOT EXISTS EmpresaDB;
USE EmpresaDB;

-- 2. Criar tabela Departamento
CREATE TABLE Departamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);

-- 3. Criar tabela Projeto
CREATE TABLE Projeto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    localizacao VARCHAR(100),
    departamento_id INT,
    FOREIGN KEY (departamento_id) REFERENCES Departamento(id)
);

-- 4. Criar tabela Funcionario
CREATE TABLE Funcionario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(150),
    data_nascimento DATE,
    salario DECIMAL(10,2),
    supervisor_id INT,
    departamento_id INT,
    FOREIGN KEY (supervisor_id) REFERENCES Funcionario(id),
    FOREIGN KEY (departamento_id) REFERENCES Departamento(id)
);

-- 5. Inserir departamentos base
INSERT INTO Departamento (nome) 
VALUES ('Administrativo'), ('Pesquisa'), ('Tecnologia');

-- 6. Inserir projetos
INSERT INTO Projeto (nome, localizacao, departamento_id)
VALUES ('Novo Projeto', 'Buritis', 1);

-- 7. Inserir funcionário Edgar Marinho
INSERT INTO Funcionario (nome, endereco, data_nascimento, salario, supervisor_id, departamento_id)
VALUES ('Edgar Marinho', 'R. Alameda, 111', STR_TO_DATE('13/11/1959', '%d/%m/%Y'), 2000.00, NULL, 2);

-- 8. Inserir funcionário João Silva (para testes)
INSERT INTO Funcionario (nome, endereco, data_nascimento, salario, supervisor_id, departamento_id)
VALUES ('Joao Silva', 'Av. Brasil, 123', STR_TO_DATE('05/06/1990', '%d/%m/%Y'), 900.00, NULL, 2);

-- 9. Atualizar salário de João Silva
UPDATE Funcionario
SET salario = 1000.00
WHERE nome = 'Joao Silva';

-- 10. Funcionários dos departamentos 2 e 3 com salário entre 800 e 1200, usando LEFT JOIN
SELECT f.nome, f.salario, d.nome AS departamento
FROM Funcionario f
LEFT JOIN Departamento d ON f.departamento_id = d.id
WHERE f.departamento_id IN (2, 3)
  AND f.salario BETWEEN 800.00 AND 1200.00;

-- 11. Nome e endereço de funcionários do departamento 'Pesquisa' usando RIGHT JOIN
SELECT f.nome, f.endereco
FROM Funcionario f
RIGHT JOIN Departamento d ON f.departamento_id = d.id
WHERE d.nome = 'Pesquisa';

-- 12. Nome e data de nascimento formatada de 'Joao Silva'
SELECT nome, DATE_FORMAT(data_nascimento, '%d/%m/%y') AS nascimento_formatado
FROM Funcionario
WHERE nome = 'Joao Silva';

-- 13. Total de funcionários por departamento (função agregada + GROUP BY)
SELECT d.nome AS departamento, COUNT(f.id) AS total_funcionarios
FROM Departamento d
LEFT JOIN Funcionario f ON d.id = f.departamento_id
GROUP BY d.nome;

-- 14. Média salarial por departamento (função agregada + GROUP BY)
SELECT d.nome AS departamento, AVG(f.salario) AS media_salarial
FROM Departamento d
LEFT JOIN Funcionario f ON d.id = f.departamento_id
GROUP BY d.nome;

-- 15. Criar tabela Trabalha
CREATE TABLE Trabalha (
    funcionario_id INT,
    projeto_id INT,
    horas INT,
    PRIMARY KEY (funcionario_id, projeto_id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionario(id),
    FOREIGN KEY (projeto_id) REFERENCES Projeto(id)
);

-- 16. Criar tabela hora_extra
CREATE TABLE hora_extra (
    funcionario_id INT PRIMARY KEY,
    horas_excedentes INT,
    FOREIGN KEY (funcionario_id) REFERENCES Funcionario(id)
);

-- 17. Procedure para aplicar taxa no salário
DELIMITER //
CREATE PROCEDURE AplicarTaxaSalario(
    IN p_funcionario_id INT,
    IN p_taxa DECIMAL(5,2)
)
BEGIN
    UPDATE Funcionario
    SET salario = salario + (salario * p_taxa / 100)
    WHERE id = p_funcionario_id;
END //
DELIMITER ;

-- 18. Procedure para verificar hora extra
DELIMITER //
CREATE PROCEDURE VerificarHoraExtra(
    IN p_funcionario_id INT
)
BEGIN
    DECLARE total_horas INT;
    DECLARE excedente INT;

    SELECT SUM(horas) INTO total_horas
    FROM Trabalha
    WHERE funcionario_id = p_funcionario_id;

    IF total_horas > 40 THEN
        SET excedente = total_horas - 40;
        INSERT INTO hora_extra (funcionario_id, horas_excedentes)
        VALUES (p_funcionario_id, excedente)
        ON DUPLICATE KEY UPDATE horas_excedentes = excedente;
    END IF;
END //
DELIMITER ;

-- 19. Trigger para chamar a procedure após inserir em Trabalha
DELIMITER //
CREATE TRIGGER trg_verifica_horas
AFTER INSERT ON Trabalha
FOR EACH ROW
BEGIN
    CALL VerificarHoraExtra(NEW.funcionario_id);
END //
DELIMITER ;
