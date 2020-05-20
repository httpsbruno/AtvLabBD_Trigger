CREATE DATABASE Exerc_triggers
go
USE Exerc_triggers
 
CREATE TABLE servico(
id INT NOT NULL,
nome VARCHAR(100),
preco DECIMAL(7,2)
PRIMARY KEY(ID))
 
CREATE TABLE depto(
codigo INT not null,
nome VARCHAR(100),
total_salarios DECIMAL(7,2)
PRIMARY KEY(codigo))
 
CREATE TABLE funcionario(
id INT NOT NULL,
nome VARCHAR(100),
salario DECIMAL(7,2),
depto INT NOT NULL
PRIMARY KEY(id)
FOREIGN KEY (depto) REFERENCES depto(codigo))
 
INSERT INTO servico VALUES
(1, 'Orçamento', 20.00),
(2, 'Manutenção preventiva', 85.00)
 
INSERT INTO depto (codigo, nome) VALUES
(1,'RH'),
(2,'DTI')
 
INSERT INTO funcionario VALUES
(1, 'Fulano', 1537.89,2)
INSERT INTO funcionario VALUES
(2, 'Cicrano', 2894.44, 1)
INSERT INTO funcionario VALUES
(3, 'Beltrano', 984.69, 1)
INSERT INTO funcionario VALUES
(4, 'Tirano', 2487.18, 2)


--Exercício Triggers: Cada depto tem um total_salario, que significa a soma dos salários de 
--cada funcionário que está alocado no depto. Cada vez que um funcionário for inserido, excluído
--ou tiver seu salário modificado (Tabela funcionário), um gatilho deverá ser disparado para 
--atualizar o total de salários do depto ao qual ele está alocado (Relacionamento 1:N). Todos os
--campos total_salário iniciam com NULL.

/*CREATE drop TRIGGER t_atualizatotal ON funcionario
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE	@total DECIMAL(7,2),
			@dep_insert	INT,
			@dep_delete INT

	SELECT @dep_insert = depto FROM INSERTED
	SELECT @dep_delete = depto FROM DELETED

	SET @total = (SELECT SUM(salario) FROM  funcionario WHERE depto = @dep_insert OR depto = @dep_delete)
	
	UPDATE depto SET total_salarios = @total WHERE codigo = @dep_insert OR codigo = @dep_delete
END*/

CREATE TRIGGER t_atualizatotal ON funcionario
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE	@salario    DECIMAL(7,2),
			@sal_antigo DECIMAL(7,2),
			@dep_insert	INT,
			@dep_delete INT,
			@dep_cod INT,
			@dep_salario DECIMAL(7,2)

	SET @dep_insert= (SELECT COUNT(*) FROM INSERTED)
	SET @dep_delete= (SELECT COUNT(*) FROM DELETED)
	
	IF(@dep_insert = 1)
	BEGIN
		SET @dep_cod = (SELECT depto FROM INSERTED)
	END
	ELSE
	BEGIN
		SET @dep_cod = (SELECT depto FROM DELETED)
	END

	SET @salario = (SELECT salario FROM INSERTED)
	SET @sal_antigo = (SELECT salario FROM DELETED)
	
	SET @dep_salario = (SELECT total_salarios FROM depto WHERE codigo = @dep_cod)
	
	IF(@dep_salario IS NULL)
	BEGIN
		SET @dep_salario = 0.0
	END
	
	IF(@dep_insert = 1 AND @dep_delete = 0)
	BEGIN
		UPDATE depto SET total_salarios = @dep_salario + @salario WHERE codigo = @dep_cod
	END

	IF (@dep_insert = 0 AND @dep_delete = 1)
    BEGIN
		UPDATE depto SET total_salarios = @dep_salario - @sal_antigo WHERE codigo = @dep_cod
	END

	IF(@dep_insert = 1 AND @dep_delete = 1)
	   BEGIN 
			IF(@sal_antigo > @salario) BEGIN
				UPDATE depto SET total_salarios = @dep_salario - (@sal_antigo - @salario) WHERE codigo = @dep_cod
			END
			ELSE
			BEGIN
				UPDATE depto SET total_salarios = @dep_salario + (@salario - @sal_antigo) WHERE codigo = @dep_cod
			END
	   END
END


