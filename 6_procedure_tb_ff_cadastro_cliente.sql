CREATE OR REPLACE PROCEDURE `hale-brook-410903.clientes.sp_ins_tb_ff_cadastro_cliente`()
BEGIN
    DECLARE tabela STRING;
    DECLARE qtd_reg_source INT64; 
    DECLARE dh_extracao_source DATETIME;   
    DECLARE qtde_reg INT64;
    DECLARE qtd_registros_inseridos INT64;
    DECLARE nome_arquivo STRING;
    SET tabela = 'tb_fi_cadastro_cliente';
    
    -- Criação de tabela temporária
    CREATE TEMPORARY TABLE STG_TEMP AS
    SELECT
        B.id_cliente,
        B.ds_nome,
        B.ds_email,
        B.ds_cidade,
        B.ds_status,
        B.dh_data_cadastro,
        B.dh_extracao,
        B.dh_execucao,
        B.no_arquivo
    FROM `hale-brook-410903.clientes.stg_cadastro_cliente` B
    INNER JOIN (SELECT MAX(dh_execucao) AS max_dh_execucao FROM `hale-brook-410903.clientes.stg_cadastro_cliente`) C
    ON B.dh_execucao = C.max_dh_execucao;
    
    -- Determinando nome do arquivo
    SET nome_arquivo = (SELECT no_arquivo FROM STG_TEMP LIMIT 1);
    
    -- Contagem de registros da fonte
    SET qtd_reg_source = (SELECT COUNT(*) FROM STG_TEMP);
    
    -- Data de extração da fonte
    SET dh_extracao_source = (SELECT dh_execucao FROM STG_TEMP LIMIT 1);
    
    -- Verificação de registros existentes
    SET qtde_reg = (
        SELECT COUNT(*) 
        FROM `hale-brook-410903.clientes.lg_execucao_processo`
        WHERE tabela = tabela
        AND dh_extracao = dh_extracao_source
        AND codigo in (0,2)
    );
    
    -- Condicional para inserção de log
    IF (qtde_reg > 0) THEN 
        INSERT INTO `hale-brook-410903.clientes.lg_execucao_processo` 
        VALUES (tabela, 5, qtd_reg_source, 0, dh_extracao_source, DATETIME(CURRENT_TIMESTAMP(), "America/Sao_Paulo"), nome_arquivo);
        RETURN;
    END IF;
    
    -- Operação MERGE para atualização e inserção de dados
        INSERT INTO  `hale-brook-410903.clientes.tb_fi_cadastro_cliente`  (
            id_cliente,
            ds_nome,
            ds_email,
            ds_cidade,
            ds_status,
            dh_data_cadastro,
            dh_extracao,
            dh_execucao,
            no_arquivo
        )
		 SELECT 
			id_cliente,
            ds_nome,
            ds_email,
            ds_cidade,
            ds_status,
            dh_data_cadastro,
            dh_extracao,
            dh_execucao,
            no_arquivo
			from STG_TEMP
		;

    -- Contagem de registros inseridos
    SET qtd_registros_inseridos = @@row_count;

    -- Inserção de logs baseada na contagem de registros inseridos
    IF (qtd_registros_inseridos = 0) THEN
        INSERT INTO `hale-brook-410903.clientes.lg_execucao_processo` 
        VALUES (tabela, 2, qtd_reg_source, 0, dh_extracao_source, DATETIME(CURRENT_TIMESTAMP(), "America/Sao_Paulo"), nome_arquivo);
    ELSEIF (qtd_registros_inseridos > 0) THEN
        INSERT INTO `hale-brook-410903.clientes.lg_execucao_processo` 
        VALUES (tabela, 0, qtd_reg_source, qtd_registros_inseridos, dh_extracao_source, DATETIME(CURRENT_TIMESTAMP(), "America/Sao_Paulo"), nome_arquivo);
    END IF;
END;
