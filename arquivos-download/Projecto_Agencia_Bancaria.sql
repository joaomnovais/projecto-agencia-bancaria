
Você foi contratado para desenvolver e gerenciar um banco de dados para um banco 
que possui várias agências espalhadas pelo país. 
O banco precisa armazenar informações sobre suas agências, clientes, contas e transações. 
Cada cliente pode ter uma ou mais contas, e cada conta pertence a uma agência específica. 
As transações (depósitos, saques, transferências) são registradas para cada conta, 
e o saldo da conta deve ser atualizado conforme as transações são realizadas.

Requisitos do Banco de Dados**

1. *Agências*:
   - Cada agência possui um código único, nome, endereço e telefone.
   - As agências são a base para a localização das contas.

2. *Clientes*:
   - Cada cliente possui um numero de documento de indentificação único, nome, endereço e telefone.
   - Um cliente pode ter uma ou mais contas em uma ou mais agências.

3. *Contas*:
   - Cada conta possui um número único, tipo (corrente, poupança, etc.), saldo e está vinculada a uma agência.
   - O saldo da conta deve ser atualizado automaticamente conforme as transações são realizadas.

4. *Transações*:
   - Cada transação possui um código único, tipo (depósito, saque, transferência), valor, data/hora e está vinculada a uma conta.
   - As transações devem ser registradas de forma que o saldo da conta seja sempre consistente.

CREATE DATABASE BANCO;

USE BANCO;

CREATE TABLE TELEFONE(
	IDTELEFONE INT PRIMARY KEY AUTO_INCREMENT,
	TIPO ENUM('COM','FAX') NOT NULL,
	NUMERO INT NOT NULL UNIQUE,
	ID_CLIENTE INT,
	ID_AGENCIA INT 
);

CREATE TABLE ENDERECO(
	IDENDERECO INT PRIMARY KEY AUTO_INCREMENT,
	PAIS ENUM('ANGOLA') NOT NULL,
	PROVINCIA VARCHAR(30) NOT NULL,
	MUNICIPIO VARCHAR(30) NOT NULL,
	BAIRRO VARCHAR(30) NOT NULL,
	RUA VARCHAR(30) NOT NULL,
	ID_CLIENTE INT,
	ID_AGENCIA INT
);

CREATE TABLE CLIENTE(
	IDCLIENTE INT PRIMARY KEY AUTO_INCREMENT,
	NOME VARCHAR(30) NOT NULL,
	SEXO ENUM('M','F') NOT NULL,
	TIPO ENUM('BILHETE_IDENT','PASSPORT') NOT NULL,
	NUMDOC VARCHAR(15) UNIQUE
);

CREATE TABLE AGENCIA(
	IDAGENCIA INT PRIMARY KEY AUTO_INCREMENT,
	NOME VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE CONTA(
	IDCONTA INT PRIMARY KEY AUTO_INCREMENT,
	TIPO ENUM('CORRENTE','POUPANCA') NOT NULL,
	SALDO FLOAT(10,2) DEFAULT -1.0,
	ID_AGENCIA INT NOT NULL,
	ID_CLIENTE INT NOT NULL
);

CREATE TABLE TRANSACAO(
	IDTRANSACAO INT PRIMARY KEY AUTO_INCREMENT,
	TIPO ENUM('DEPOSITO','SAQUE','TRANSFERENCIA') NOT NULL,
	VALOR FLOAT(10,2) NOT NULL,
	DATA DATETIME NOT NULL,
	ID_CONTA INT NOT NULL
);

/*O saldo da conta deve ser atualizado automaticamente conforme as transações são realizadas.*/

CREATE TABLE BKP_TRANSACAO(
	IDBKPTRANSACAO INT PRIMARY KEY AUTO_INCREMENT,
	IDTRANSACAO INT,
	TIPO ENUM('DEPOSITO','SAQUE','TRANSFERENCIA'),
	VALOR_ORIGINAL FLOAT(10,2),
	VALOR_ALTERADO FLOAT(10,2),
	DATA DATETIME,
	ID_CONTA INT
);

DELIMITER $

CREATE TRIGGER BACKUP_TRANSACAO
AFTER UPDATE ON TRANSACAO
FOR EACH ROW
BEGIN
	INSERT INTO BKP_TRANSACAO 
	VALUES(NULL,OLD.IDTRANSACAO,OLD.TIPO,OLD.VALOR,NEW.VALOR,NOW(),OLD.ID_CONTA);
END
$

DELIMITER ;

UPDATE TRANSACAO
SET VALOR = 100
WHERE IDTRANSACAO = 1;

SELECT * FROM TRANSACAO;

SELECT * FROM BKP_TRANSACAO;
+-------------+---------------+---------+---------------------+----------+
| IDTRANSACAO | TIPO          | VALOR   | DATA                | ID_CONTA |
+-------------+---------------+---------+---------------------+----------+
|           1 | SAQUE         |  100.00 | 2025-02-05 13:00:02 |        1 |
|           2 | TRANSFERENCIA | 1000.00 | 2025-02-05 13:00:02 |        2 |
|           3 | DEPOSITO      | 1000.00 | 2025-02-05 13:00:02 |        3 |
|           4 | DEPOSITO      | 2000.00 | 2025-02-05 13:00:03 |        1 |
+-------------+---------------+---------+---------------------+----------+
4 rows in set (0.001 sec)

SELECT * FROM BKP_TRANSACAO;
+----------------+-------------+-------+----------------+----------------+---------------------+----------+
| IDBKPTRANSACAO | IDTRANSACAO | TIPO  | VALOR_ORIGINAL | VALOR_ALTERADO | DATA                | ID_CONTA |
+----------------+-------------+-------+----------------+----------------+---------------------+----------+
|              1 |           1 | SAQUE |        1000.00 |         100.00 | 2025-02-05 13:17:05 |        1 |
+----------------+-------------+-------+----------------+----------------+---------------------+----------+
1 row in set (0.001 sec)


/*ADICIONA CHAVE ESTRANGEIRA-FK NAS RESPETIVAS TABELAS*/
ALTER TABLE TELEFONE ADD CONSTRAINT FK_TELEFONE_CLIENTE
FOREIGN KEY(ID_CLIENTE) REFERENCES CLIENTE(IDCLIENTE);

ALTER TABLE TELEFONE ADD CONSTRAINT FK_TELEFONE_AGENCIA
FOREIGN KEY(ID_AGENCIA) REFERENCES AGENCIA(IDAGENCIA);

ALTER TABLE ENDERECO ADD CONSTRAINT FK_ENDERECO_CLIENTE
FOREIGN KEY(ID_CLIENTE) REFERENCES CLIENTE(IDCLIENTE);

ALTER TABLE ENDERECO ADD CONSTRAINT FK_ENDERECO_AGENCIA
FOREIGN KEY(ID_AGENCIA) REFERENCES AGENCIA(IDAGENCIA);

ALTER TABLE CONTA ADD CONSTRAINT FK_CONTA_AGENCIA
FOREIGN KEY(ID_AGENCIA) REFERENCES CONTA(IDCONTA);

ALTER TABLE CONTA ADD CONSTRAINT FK_CONTA_CLIENTE
FOREIGN KEY(ID_CLIENTE) REFERENCES CLIENTE(IDCLIENTE);

ALTER TABLE TRANSACAO ADD CONSTRAINT FK_TRANSACAO_CONTA
FOREIGN KEY(ID_CONTA) REFERENCES TRANSACAO(IDTRANSACAO);

ALTER TABLE BKP_TRANSACAO ADD CONSTRAINT FK_BKPTRANSACAO_TRANSACAO
FOREIGN KEY(ID_CONTA) REFERENCES BKP_TRANSACAO(IDBKPTRANSACAO);

/*CLIENTE*/
INSERT INTO CLIENTE VALUES(NULL,'NOVAIS','M','BILHETE_IDENT','14642LA034');
INSERT INTO CLIENTE VALUES(NULL,'TECAS','F','BILHETE_IDENT','29843BA036');
INSERT INTO CLIENTE VALUES(NULL,'MARIO','M','BILHETE_IDENT','19283LA048');
INSERT INTO CLIENTE VALUES(NULL,'LENO','M','BILHETE_IDENT','16787LA022');
INSERT INTO CLIENTE VALUES(NULL,'VICTO','F','PASSPORT','16787AO022');
/*CLINTES SEM CONTAS TESTAR*/
INSERT INTO CLIENTE VALUES(NULL,'TERESA','F','PASSPORT','45787BR012');
INSERT INTO CLIENTE VALUES(NULL,'VICTO','F','PASSPORT','22787NO002');

/*AGENCIA*/
INSERT INTO AGENCIA VALUES(NULL,'AGENCIA1');
INSERT INTO AGENCIA VALUES(NULL,'AGENCIA2');
INSERT INTO AGENCIA VALUES(NULL,'AGENCIA3');
INSERT INTO AGENCIA VALUES(NULL,'AGENCIA4');
INSERT INTO AGENCIA VALUES(NULL,'AGENCIA5');

/*TELEFONE CLIENTE*/
INSERT INTO TELEFONE VALUES(NULL,'COM',933191210,1,NULL);
INSERT INTO TELEFONE VALUES(NULL,'FAX',222195512,2,NULL);
INSERT INTO TELEFONE VALUES(NULL,'COM',923201267,3,NULL);
INSERT INTO TELEFONE VALUES(NULL,'COM',922230900,4,NULL);
INSERT INTO TELEFONE VALUES(NULL,'FAX',222640800,5,NULL);
INSERT INTO TELEFONE VALUES(NULL,'FAX',222700045,1,NULL);

/*TELEFONE AGENCIA*/
INSERT INTO TELEFONE VALUES(NULL,'COM',923191211,NULL,1);
INSERT INTO TELEFONE VALUES(NULL,'FAX',222205613,NULL,2);
INSERT INTO TELEFONE VALUES(NULL,'COM',922021168,NULL,3);
INSERT INTO TELEFONE VALUES(NULL,'COM',927220800,NULL,4);
INSERT INTO TELEFONE VALUES(NULL,'COM',925596887,NULL,5);
INSERT INTO TELEFONE VALUES(NULL,'FAX',222640812,NULL,1);

/*TELEFONE CLIENTE_AGENCIA*/
INSERT INTO TELEFONE VALUES(NULL,'COM',952880900,1,1);
INSERT INTO TELEFONE VALUES(NULL,'COM',952778909,2,1);
INSERT INTO TELEFONE VALUES(NULL,'FAX',222000900,1,1);


/*ENDERECO CLIENTE*/
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','LUANDA','MAIANGA','CASSEQUEL','22',1,NULL);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','BENGUELA','CATUMBELA','PALHACO','10',2,NULL);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','LUANDA','VIANA','ZANGO||','QUADRA_B',3,NULL);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','NAMIBE','TOMBUA','CENTRALIDADE','QUADRA_A',4,NULL);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','NAMIBE','TOMBUA','CENTRALIDADE','QUADRA_A',5,NULL);

/*ENDERECO AGENCIA*/
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','LUANDA','MAIANGA','CASSEQUEL','22',NULL,1);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','BENGUELA','CATUMBELA','PALHACO','10',NULL,2);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','LUANDA','VIANA','ZANGO||','QUADRA_B',NULL,3);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','NAMIBE','TOMBUA','CENTRALIDADE','QUADRA_A',NULL,4);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','NAMIBE','TOMBUA','CENTRALIDADE','QUADRA_B',NULL,5);

/*ENDERECO CLIENTE_AGENCIA*/
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','LUANDA','MAIANGA','CASSEQUEL','22',1,1);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','BENGUELA','CATUMBELA','PALHACO','10'2,2);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','LUANDA','VIANA','ZANGO||','QUADRA_B',3,3);
INSERT INTO ENDERECO VALUES(NULL,'ANGOLA','LUANDA','VIANA','ZANGO||','QUADRA_B',1,3);

/*CONTA*/
INSERT INTO CONTA VALUES(NULL,'CORRENTE',2000,1,1);
INSERT INTO CONTA VALUES(NULL,'CORRENTE',1000,1,2);
INSERT INTO CONTA VALUES(NULL,'POUPANCA',3000,2,3);
INSERT INTO CONTA VALUES(NULL,'CORRENTE',4000,3,4);
INSERT INTO CONTA VALUES(NULL,'POUPANCA',3000,4,5);
INSERT INTO CONTA VALUES(NULL,'POUPANCA',5000,1,1);
/*TESTAR COM CONTAS NEGATIVAS*/
INSERT INTO CONTA VALUES(NULL,'POUPANCA',-1.0,1,2);
INSERT INTO CONTA VALUES(NULL,'CORRENTE',1000,2,2);
INSERT INTO CONTA VALUES(NULL,'POUPANCA',-1.0,1,2);
INSERT INTO CONTA VALUES(NULL,'CORRENTE',-1.0,3,4);


/*TRANSACAO*/
INSERT INTO TRANSACAO VALUES(NULL,'SAQUE',1000,NOW(),1);
INSERT INTO TRANSACAO VALUES(NULL,'TRANSFERENCIA',1000,NOW(),2);
INSERT INTO TRANSACAO VALUES(NULL,'DEPOSITO',1000,NOW(),3);
INSERT INTO TRANSACAO VALUES(NULL,'DEPOSITO',2000,NOW(),1);


SELECT * FROM AGENCIA;
+-----------+----------+
| IDAGENCIA | NOME     |
+-----------+----------+
|         1 | AGENCIA1 |
|         2 | AGENCIA2 |
|         3 | AGENCIA3 |
|         4 | AGENCIA4 |
|         5 | AGENCIA5 |
+-----------+----------+
5 rows in set (0.001 sec)

SELECT * FROM CLIENTE;
+-----------+--------+------+---------------+------------+
| IDCLIENTE | NOME   | SEXO | TIPO          | NUMDOC     |
+-----------+--------+------+---------------+------------+
|         1 | NOVAIS | M    | BILHETE_IDENT | 14642LA034 |
|         2 | TECAS  | F    | BILHETE_IDENT | 29843BA036 |
|         3 | MARIO  | M    | BILHETE_IDENT | 19283LA048 |
|         4 | LENO   | M    | BILHETE_IDENT | 16787LA022 |
|         5 | VICTO  | F    | PASSPORT      | 16787AO022 |
+-----------+--------+------+---------------+------------+
5 rows in set (0.001 sec)

SELECT * FROM ENDERECO;
+------------+--------+-----------+-----------+--------------+----------+------------+------------+
| IDENDERECO | PAIS   | PROVINCIA | MUNICIPIO | BAIRRO       | RUA      | ID_CLIENTE | ID_AGENCIA |
+------------+--------+-----------+-----------+--------------+----------+------------+------------+
|          1 | ANGOLA | LUANDA    | MAIANGA   | CASSEQUEL    | 22       |          1 |       NULL |
|          2 | ANGOLA | BENGUELA  | CATUMBELA | PALHACO      | 10       |          2 |       NULL |
|          3 | ANGOLA | LUANDA    | VIANA     | ZANGO||      | QUADRA_B |          3 |       NULL |
|          4 | ANGOLA | NAMIBE    | TOMBUA    | CENTRALIDADE | QUADRA_A |          4 |       NULL |
|          5 | ANGOLA | NAMIBE    | TOMBUA    | CENTRALIDADE | QUADRA_A |          5 |       NULL |
|          6 | ANGOLA | LUANDA    | MAIANGA   | CASSEQUEL    | 22       |       NULL |          1 |
|          7 | ANGOLA | BENGUELA  | CATUMBELA | PALHACO      | 10       |       NULL |          2 |
|          8 | ANGOLA | LUANDA    | VIANA     | ZANGO||      | QUADRA_B |       NULL |          3 |
|          9 | ANGOLA | NAMIBE    | TOMBUA    | CENTRALIDADE | QUADRA_A |       NULL |          4 |
|         10 | ANGOLA | NAMIBE    | TOMBUA    | CENTRALIDADE | QUADRA_B |       NULL |          5 |
|         11 | ANGOLA | LUANDA    | MAIANGA   | CASSEQUEL    | 22       |          1 |          1 |
|         12 | ANGOLA | LUANDA    | VIANA     | ZANGO||      | QUADRA_B |          3 |          3 |
|         13 | ANGOLA | LUANDA    | VIANA     | ZANGO||      | QUADRA_B |          1 |          3 |
+------------+--------+-----------+-----------+--------------+----------+------------+------------+
13 rows in set (0.001 sec)

SELECT * FROM TELEFONE;
+------------+------+-----------+------------+------------+
| IDTELEFONE | TIPO | NUMERO    | ID_CLIENTE | ID_AGENCIA |
+------------+------+-----------+------------+------------+
|          1 | COM  | 933191210 |          1 |       NULL |
|          2 | COM  | 923201267 |          3 |       NULL |
|          3 | COM  | 922230900 |          4 |       NULL |
|          4 | FAX  | 222195512 |          2 |       NULL |
|          7 | FAX  | 222640800 |          5 |       NULL |
|          8 | FAX  | 222700045 |          1 |       NULL |
|          9 | COM  | 923191211 |       NULL |          1 |
|         10 | FAX  | 222205613 |       NULL |          2 |
|         11 | COM  | 922021168 |       NULL |          3 |
|         12 | COM  | 927220800 |       NULL |          4 |
|         13 | COM  | 925596887 |       NULL |          5 |
|         15 | FAX  | 222640812 |       NULL |          1 |
|         16 | COM  | 952880900 |          1 |          1 |
|         17 | COM  | 952778909 |          2 |          1 |
|         18 | FAX  | 222000900 |          1 |          1 |
+------------+------+-----------+------------+------------+
15 rows in set (0.042 sec)


SELECT * FROM CONTA;
+---------+----------+---------+------------+------------+
| IDCONTA | TIPO     | SALDO   | ID_AGENCIA | ID_CLIENTE |
+---------+----------+---------+------------+------------+
|       1 | CORRENTE | 2000.00 |          1 |          1 |
|       2 | CORRENTE | 1000.00 |          1 |          2 |
|       3 | POUPANCA | 3000.00 |          2 |          3 |
|       4 | CORRENTE | 4000.00 |          3 |          4 |
|       5 | POUPANCA | 3000.00 |          4 |          5 |
|       6 | POUPANCA | 5000.00 |          1 |          1 |
|       7 | POUPANCA |   -1.00 |          1 |          2 |
|       8 | CORRENTE | 1000.00 |          2 |          2 |
|       9 | CORRENTE |   -1.00 |          3 |          4 |
+---------+----------+---------+------------+------------+
9 rows in set (0.001 sec)

SELECT * FROM TRANSACAO;
+-------------+---------------+---------+---------------------+----------+
| IDTRANSACAO | TIPO          | VALOR   | DATA                | ID_CONTA |
+-------------+---------------+---------+---------------------+----------+
|           1 | SAQUE         | 1000.00 | 2025-02-04 13:35:09 |        1 |
|           2 | TRANSFERENCIA | 1000.00 | 2025-02-04 13:35:27 |        2 |
|           3 | DEPOSITO      | 1000.00 | 2025-02-04 13:35:29 |        3 |
|           4 | DEPOSITO      | 2000.00 | 2025-02-04 17:43:55 |        1 |
+-------------+---------------+---------+---------------------+----------+
4 rows in set (0.036 sec)

USE BACKUP;
Database changed
MariaDB [BACKUP]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| aula40             |
| aula44             |
| backup             |
| banco              |
| bancoteste         |
| comercio           |
| consultorio        |
| cursores           |
| information_schema |
| kuma_kwa_bana      |
| loja               |
| mysql              |
| pautacolegio       |
| performance_schema |
| projecto           |
| projeto            |
| sys                |
| xdserver           |
+--------------------+
18 rows in set (0.159 sec)


### *Consultas e Relatórios Avançados*

1. *Relatório de Contas com Saldo Negativo*:
   - Liste o nome do cliente, o número da conta, o saldo e o nome da agência para todas as contas que estão com saldo negativo.
   - Esse relatório é crucial para identificar clientes que podem precisar de assistência financeira.
   
SELECT C.NOME, CO.IDCONTA, CO.SALDO, AG.NOME
     FROM CLIENTE C
     INNER JOIN CONTA CO
     ON C.IDCLIENTE = CO.ID_CLIENTE
     INNER JOIN AGENCIA AG
     ON AG.IDAGENCIA = CO.ID_AGENCIA
     WHERE CO.SALDO = -1.0;
+-------+---------+-------+----------+
| NOME  | IDCONTA | SALDO | NOME     |
+-------+---------+-------+----------+
| TECAS |       7 | -1.00 | AGENCIA1 |
| LENO  |       9 | -1.00 | AGENCIA3 |
+-------+---------+-------+----------+
2 rows in set (0.203 sec)

2. *Total de Transações por Agência*:
   - Liste o nome de cada agência e o total de transações realizadas em suas contas, ordenado pelo total de transações em ordem decrescente.
   - Esse relatório ajuda a identificar as agências mais movimentadas.
   
   SELECT AG.NOME,T.TIPO,CO.IDCONTA
    ->      FROM TRANSACAO T
    ->      INNER JOIN CONTA CO
    ->      ON T.ID_CONTA = CO.IDCONTA
    ->      INNER JOIN AGENCIA AG
    ->      ON CO.ID_AGENCIA = AG.IDAGENCIA
    ->      ORDER BY TIPO DESC;
+----------+---------------+---------+
| NOME     | TIPO          | IDCONTA |
+----------+---------------+---------+
| AGENCIA1 | TRANSFERENCIA |       2 |
| AGENCIA1 | SAQUE         |       1 |
| AGENCIA2 | DEPOSITO      |       3 |
| AGENCIA1 | DEPOSITO      |       1 |
+----------+---------------+---------+
4 rows in set (0.001 sec)
   
3. *Contas com Alta Movimentação*:
   - Liste o nome do cliente, o número da conta, o saldo e o nome da agência para todas as contas que tiveram mais de 5 transações no último mês.
   - Esse relatório é útil para identificar contas com alta atividade e possíveis necessidades de suporte.

4. *Contas Inativas*:
   - Liste o nome do cliente, o número da conta, o saldo e o nome da agência para todas as contas que não tiveram transações no último mês.
   - Esse relatório ajuda a identificar contas que podem estar inativas ou abandonadas.

5. *Contas com Saldo Médio Alto*:
   - Liste o nome do cliente, o número da conta, o saldo e o nome da agência para todas as contas que tiveram um saldo médio superior a R$ 10.000,00 no último trimestre.
   - Esse relatório é útil para identificar clientes com alto poder aquisitivo.
### *Desafios Avançados*

1. *Stored Procedure para Consulta de Contas de um Cliente*:
   - Crie uma stored procedure que receba o CPF de um cliente e retorne o nome do cliente, o número da conta, o saldo e o nome da agência para todas as contas desse cliente.
   - Essa procedure deve ser eficiente e retornar os resultados rapidamente, mesmo para clientes com muitas contas.

 DELIMITER $
 CREATE PROCEDURE CONSULTA_CONTA_CLIENTE(IDCLIENTE INT)
 BEGIN
      SELECT C.IDCLIENTE,C.NOME,CO.IDCONTA,CO.SALDO,AG.NOME
      FROM CLIENTE C
      INNER JOIN CONTA CO
      ON C.IDCLIENTE = CO.ID_CLIENTE
      INNER JOIN AGENCIA AG
      ON AG.IDAGENCIA = CO.ID_AGENCIA;
 END
 $
 DELIMITER ;
CALL CONSULTA_CONTA_CLIENTE(1);
+-----------+--------+---------+---------+----------+
| IDCLIENTE | NOME   | IDCONTA | SALDO   | NOME     |
+-----------+--------+---------+---------+----------+
|         1 | NOVAIS |       1 | 2000.00 | AGENCIA1 |
|         1 | NOVAIS |       6 | 5000.00 | AGENCIA1 |
|         2 | TECAS  |       2 | 1000.00 | AGENCIA1 |
|         2 | TECAS  |       7 |   -1.00 | AGENCIA1 |
|         2 | TECAS  |       8 | 1000.00 | AGENCIA2 |
|         3 | MARIO  |       3 | 3000.00 | AGENCIA2 |
|         4 | LENO   |       4 | 4000.00 | AGENCIA3 |
|         4 | LENO   |       9 |   -1.00 | AGENCIA3 |
|         5 | VICTO  |       5 | 3000.00 | AGENCIA4 |
+-----------+--------+---------+---------+----------+
9 rows in set (0.002 sec)

2. *View para Contas com Total de Transações*:
   - Crie uma view que mostre o nome do cliente, o número da conta, o saldo, o nome da agência e o total de transações realizadas em cada conta.
   - Essa view deve ser otimizada para consultas frequentes e deve ser atualizada automaticamente conforme novas transações são registradas.

3. *Trigger para Verificação de Saldo*:
   - Crie uma trigger que impeça a inserção de uma transação de saque se o saldo da conta for insuficiente.
   - A trigger deve lançar uma mensagem de erro clara e impedir a transação de ser registrada, garantindo a integridade do saldo da conta.

 *Considerações Finais*
Este exercício avançado exige um profundo entendimento de bancos de dados relacionais, 
incluindo modelagem de dados, consultas complexas, stored procedures, views e triggers. 
A implementação deve ser eficiente e garantir a integridade dos dados, 
além de fornecer relatórios úteis para a gestão do banco.


CREATE DATABASE BANCOTESTE;

USE BANCOTESTE;

CREATE TABLE TRANSACAO(
	IDTRANSACAO INT PRIMARY KEY AUTO_INCREMENT,
	TIPO ENUM('DEPOSITO','SAQUE','TRANSFERENCIA'),
	VALOR FLOAT(10,2) DEFAULT 0.0,
	DATA DATETIME
);

CREATE TABLE BKP_TRANSACAO(
	IDBKP INT PRIMARY KEY AUTO_INCREMENT,
	IDTRANSACAO INT,
	TIPO ENUM('DEPOSITO','SAQUE','TRANSFERENCIA'),
	VALOR_ORIGINAL FLOAT(10,2),
	VALOR_ALTERADO FLOAT(10,2),
	DATA DATETIME,
	UTILIZADOR VARCHAR(30)
);

INSERT INTO TRANSACAO VALUES(NULL,'SAQUE',2000,NOW());
INSERT INTO TRANSACAO VALUES(NULL,'TRANSFERENCIA',4000,NOW());
INSERT INTO TRANSACAO VALUES(NULL,'DEPOSITO',500,NOW());

DELIMITER $

CREATE TRIGGER BACKUP_TRANSACAO
AFTER UPDATE ON TRANSACAO
FOR EACH ROW
BEGIN
	
	INSERT INTO BKP_TRANSACAO VALUES(NULL,OLD.IDTRANSACAO,OLD.TIPO,OLD.VALOR,NEW.VALOR,
	NOW(),CURRENT_USER());
	
END	
$

DELIMITER ;

UPDATE TRANSACAO 
SET VALOR = 1000
WHERE IDTRANSACAO = 1;

SELECT * FROM TRANSACAO;

SELECT * FROM BKP_TRANSACAO;  /*É SEMPRE BOM COLOCAR O BKP EM OUTRO BANCO PARA PREVINIR CASO PERDE-SE A BD*/
