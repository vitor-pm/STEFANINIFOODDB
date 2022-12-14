CREATE DATABASE STEFANINIFOODDB;
USE STEFANINIFOODDB;

CREATE TABLE TB_USUARIO
  (
     ID              INT IDENTITY(1, 1) NOT NULL,
     NOME            VARCHAR(100) NOT NULL,
     CPF             CHAR(11) NOT NULL,
     DATA_NASCIMENTO DATE,
     TELEFONE        VARCHAR(15),
     EMAIL           VARCHAR(100),
     SENHA           VARCHAR(30),
     CONSTRAINT PK_USUARIO PRIMARY KEY (ID),
     CONSTRAINT UK_CPF UNIQUE (CPF),
     CONSTRAINT UK_EMAIL UNIQUE (EMAIL)
  )

  CREATE TABLE TB_LOJA
  (
     ID         INT IDENTITY(1, 1) NOT NULL,
     NOME       VARCHAR(100) NOT NULL,
     DESCRICAO  VARCHAR(20),
     TELEFONE   VARCHAR(15) NOT NULL,
     ID_USUARIO INT NOT NULL,
     CONSTRAINT PK_LOJA PRIMARY KEY (ID),
     CONSTRAINT FK_LOJA_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES TB_USUARIO(
     ID)
  )

CREATE TABLE TB_ENDERECO
  (
     ID          INT IDENTITY(1, 1) NOT NULL,
     LOGRADOURO  VARCHAR(100) NOT NULL,
     COMPLEMENTO VARCHAR(20),
     CEP         CHAR(8),
     UF          CHAR(2) NOT NULL,
     CIDADE      VARCHAR(50) NOT NULL,
     ID_USUARIO  INT NULL,
	 ID_LOJA INT NULL,
     CONSTRAINT PK_ENDERECO PRIMARY KEY (ID),
     CONSTRAINT FK_ENDERECO_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES TB_USUARIO (ID),
	 CONSTRAINT FK_ENDERECO_LOJA FOREIGN KEY(ID_LOJA) REFERENCES TB_LOJA(ID)
  )

CREATE TABLE TB_PAGAMENTO
  (
     ID           INT IDENTITY(1, 1) NOT NULL,
     APELIDO      VARCHAR(100),
     NUMERO       VARCHAR(20) NOT NULL,
     CVV          CHAR(3) NOT NULL,
     NOME_TITULAR VARCHAR(100) NOT NULL,
     ID_USUARIO   INT NOT NULL,
     CONSTRAINT PK_PAGAMENTO PRIMARY KEY (ID),
     CONSTRAINT FK_PAGAMENTO_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES
     TB_USUARIO (ID)
  )

CREATE TABLE TB_CATEGORIA
  (
     ID        INT IDENTITY(1, 1) NOT NULL,
     NOME      VARCHAR(100),
     DESCRICAO VARCHAR(100),
     CONSTRAINT PK_CATEGORIA PRIMARY KEY (ID)
  )

CREATE TABLE TB_PRODUTO
  (
     ID           INT IDENTITY(1, 1) NOT NULL,
     NOME         VARCHAR(100) NOT NULL,
     DESCRICAO    VARCHAR(20),
     PRECO        FLOAT NOT NULL,
     CONSTRAINT PK_PRODUTO PRIMARY KEY (ID),
  )

CREATE TABLE TB_PEDIDO
  (
     ID         INT IDENTITY(1, 1) NOT NULL,
     DESCRICAO  VARCHAR(100),
     PRECO      FLOAT NOT NULL,
     ID_LOJA    INT NOT NULL,
     ID_USUARIO INT NOT NULL,
	 ID_ENDERECO INT NOT NULL,
	 ID_PAGAMENTO INT NOT NULL,
     CONSTRAINT PK_PEDIDO PRIMARY KEY (ID),
     CONSTRAINT FK_PEDIDO_LOJA FOREIGN KEY (ID_LOJA) REFERENCES TB_LOJA(ID),
     CONSTRAINT FK_PEDIDO_USUARIO FOREIGN KEY (ID_USUARIO) REFERENCES TB_USUARIO
     (ID),
	 CONSTRAINT FK_PEDIDO_PAGAMENTO FOREIGN KEY (ID_PAGAMENTO) REFERENCES TB_PAGAMENTO (ID),
	 CONSTRAINT FK_PEDIDO_ENDERECO FOREIGN KEY (ID_ENDERECO) REFERENCES TB_ENDERECO (ID)
  )

CREATE TABLE TB_PEDIDO_PRODUTO
  (
     ID              INT IDENTITY NOT NULL,
     ID_PEDIDO       INT NOT NULL,
     ID_PRODUTO      INT NOT NULL,
     PRECO_PRATICADO FLOAT,
     CONSTRAINT PEDIDO_PRODUTO PRIMARY KEY (ID),
     CONSTRAINT FK_PEDIDO_PRODUTO_PEDIDO FOREIGN KEY (ID_PEDIDO) REFERENCES
     TB_PEDIDO (ID),
     CONSTRAINT FK_PEDIDO_PRODUTO_PRODUTO FOREIGN KEY (ID_PRODUTO) REFERENCES
     TB_PRODUTO (ID),
  )

CREATE TABLE TB_PRODUTO_CATEGORIA
  (
     ID_PRODUTO   INT NOT NULL,
     ID_CATEGORIA INT NOT NULL,
     CONSTRAINT FK_PRODUTO_CATEGORIA_PRODUTO FOREIGN KEY (ID_PRODUTO) REFERENCES
     TB_PRODUTO (ID),
     CONSTRAINT FK_PRODUTO_CATEGORIA_CATEGORIA FOREIGN KEY (ID_CATEGORIA)
     REFERENCES TB_CATEGORIA (ID),
  ) 

  CREATE TABLE TB_PRODUTO_LOJA(
  ID_PRODUTO INT NOT NULL,
  ID_LOJA INT NOT NULL,
  PRECO FLOAT NULL,
  CONSTRAINT FK_PRODUTO_LOJA_PRODUTO FOREIGN KEY(ID_PRODUTO) REFERENCES TB_PRODUTO(ID),
  CONSTRAINT FK_PRODUTO_LOJA_LOJA FOREIGN KEY(ID_LOJA) REFERENCES TB_LOJA(ID)
  )

  -- FUNCTIONS
  CREATE FUNCTION EXISTEEMAIL(@EMAIL VARCHAR(100))
RETURNS TABLE
AS
    RETURN
      (SELECT CASE
                WHEN Count(*) < 1 THEN 'Email n??o cadastrado'
                ELSE 'Email j?? cadastrado'
              END AS Email
       FROM   TB_USUARIO
       WHERE  EMAIL = @EMAIL);


CREATE FUNCTION LOJAVENDE(@IDLOJA INT, @IDPRODUTO INT)
RETURNS BIT
AS
BEGIN
	DECLARE @VENDE AS BIT

	SET @VENDE = (
	SELECT CASE 
			WHEN COUNT(*) > 0 THEN 1 
			ELSE 0 END 
			FROM TB_PRODUTO_LOJA WHERE ID_PRODUTO = @IDPRODUTO AND ID_LOJA = @IDLOJA);

    RETURN @VENDE
	END

CREATE OR ALTER FUNCTION	 CHECAPEDIDO(@IDENDERECO INT, @IDPAGAMENTO INT, @IDUSUARIO INT)
RETURNS BIT
AS
BEGIN
	DECLARE @BitENDERECO AS BIT
	DECLARE @BitPAGAMENTO AS BIT
	DECLARE @VALIDA AS BIT

	SET @BitENDERECO = (SELECT COUNT(*) FROM TB_ENDERECO WHERE ID = @IDENDERECO AND ID_USUARIO = @IDUSUARIO);
	SET @BitPAGAMENTO = (SELECT COUNT(*) FROM TB_PAGAMENTO WHERE ID = @IDPAGAMENTO AND ID_USUARIO = @IDUSUARIO);

	IF (@BitENDERECO = 0 OR @BitPAGAMENTO = 0)
		SET @VALIDA = 0
	ELSE
		SET @VALIDA = 1

	RETURN @VALIDA
	END;
      
	   
CREATE FUNCTION dbo.ValidaEmail(@EMAIL VARCHAR(100))
returns BIT
AS
  BEGIN
      DECLARE @ehEmail AS BIT

      IF (@EMAIL NOT LIKE '_%@__%.__%' )
        SET @ehEmail = 0 -- Invalido
      ELSE
        SET @ehEmail = 1 -- Valido

      RETURN @ehEmail
  END 


  -- VIEWS
CREATE VIEW VIEW_PEDIDOS AS
SELECT P.ID, U.NOME AS CLIENTE, U.CPF, U.TELEFONE AS [TELEFONE USUARIO], L.NOME AS LOJA, L.TELEFONE AS [TELEFONE LOJA], P.DESCRICAO, P.PRECO, E.LOGRADOURO, E.COMPLEMENTO, PA.NUMERO AS CARTAO
FROM   TB_PEDIDO P
       INNER JOIN TB_USUARIO U
               ON P.ID_USUARIO = U.ID
       INNER JOIN TB_ENDERECO E
               ON P.ID_ENDERECO = E.ID
       INNER JOIN TB_PAGAMENTO PA
               ON P.ID_PAGAMENTO = PA.ID
       INNER JOIN TB_LOJA L
               ON P.ID_LOJA = L.ID 

CREATE VIEW VIEW_PEDIDO_PRODUTOS AS
SELECT PP.ID_PEDIDO, P.NOME, P.DESCRICAO, P.PRECO FROM TB_PEDIDO_PRODUTO PP
INNER JOIN TB_PRODUTO P ON PP.ID_PRODUTO = P.ID;

-- INDICES
CREATE INDEX IDX_CPF ON TB_USUARIO (CPF);
CREATE INDEX IDX_LOJA_NOME ON TB_LOJA (NOME);


-- STORED PROCEDURE
CREATE OR ALTER   PROCEDURE [dbo].[INSERIRPEDIDO] (@DESCRICAO  VARCHAR(100),
                                  @PRECO FLOAT,
                                  @LOJA        INT,
                                  @USUARIO        INT,
                                  @ENDERECO     INT,
                                  @PAGAMENTO   INT,
								  @QTD INT, -- 4
								  @PRODUTOS VARCHAR(100)) -- '4'
AS
  BEGIN
      BEGIN TRANSACTION;

      SAVE TRANSACTION MYSAVEPOINT;

      BEGIN TRY

	  DECLARE @VALIDA BIT

	  SET @VALIDA = [dbo].[CHECAPEDIDO] (@ENDERECO,@PAGAMENTO,@USUARIO)

	  DECLARE @ID INT

	  IF (@VALIDA = 1)
          INSERT INTO TB_PEDIDO
          VALUES      (@DESCRICAO,
                       @PRECO,
                       @LOJA,
                       @USUARIO,
                       @ENDERECO,
                       @PAGAMENTO)
	  ELSE
			RAISERROR('ERRO: ENDERECO OU PAGAMENTO N??O PERTENCE AO USUARIO',1,1);

		SET @ID = @@IDENTITY

		DECLARE @cnt INT = 1;
		DECLARE @adiciona INT
		DECLARE @LOJAVENDE AS BIT

		WHILE @cnt < @QTD
		BEGIN
			
			SET @adiciona = SUBSTRING(@PRODUTOS, 1,CHARINDEX(',', @PRODUTOS)-1)
			set @PRODUTOS = STUFF(@PRODUTOS, 1, CHARINDEX(',', @PRODUTOS), '');

			SET @LOJAVENDE = [dbo].LOJAVENDE(@LOJA, @adiciona)

			IF (@LOJAVENDE <> 1)
				BEGIN
					SET @cnt = @QTD +1
					SELECT 'PRODUTO NAO PERTENCE A LOJA'
					ROLLBACK TRANSACTION
				END
			ELSE
				BEGIN
					INSERT INTO TB_PEDIDO_PRODUTO (ID_PEDIDO,ID_PRODUTO) VALUES (@ID,@adiciona)
				END

			SET @cnt = @cnt + 1
		END

		SET @LOJAVENDE = [dbo].LOJAVENDE(@LOJA, @PRODUTOS)

			IF (@LOJAVENDE <> 1)
				BEGIN
					SELECT 'PRODUTO NAO PERTENCE A LOJA'
					ROLLBACK TRANSACTION
				END
			ELSE
				BEGIN
					INSERT INTO TB_PEDIDO_PRODUTO (ID_PEDIDO,ID_PRODUTO) VALUES (@ID,@PRODUTOS)
				END
					  
					  
          COMMIT TRANSACTION
      END TRY

      BEGIN CATCH
          IF @@TRANCOUNT > 0
            BEGIN
                SELECT 'Erro: n??o foi possivel inserir'

                ROLLBACK TRANSACTION MYSAVEPOINT;
            END
      END CATCH
  END;