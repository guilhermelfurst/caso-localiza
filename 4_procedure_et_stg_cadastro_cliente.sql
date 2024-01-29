CREATE OR REPLACE PROCEDURE `hale-brook-410903.clientes.sp_ins_stg_cadastro_cliente`(param_no_arquivo STRING)
BEGIN
    DECLARE tabela STRING;
    DECLARE qtd_reg_source INT64; 
    DECLARE dh_extracao_source DATETIME;   
    DECLARE qtde_reg INT64;
    DECLARE qtd_registros_inseridos INT64;

    SET tabela = 'stg_cadastro_cliente';

    SET qtd_reg_source = (
        SELECT COUNT(*)
        FROM `hale-brook-410903.clientes.et_cadastro_cliente`
        WHERE _file_name = param_no_arquivo
    );

    SET dh_extracao_source = (
        SELECT 
            PARSE_DATETIME('%Y%m%d%H%M%S', REGEXP_EXTRACT(param_no_arquivo, r'data_(\d{14})\.csv')) AS dh_extracao_source
        FROM 
            `hale-brook-410903.clientes.et_cadastro_cliente`
        ORDER BY 
            PARSE_DATETIME('%Y%m%d%H%M%S', REGEXP_EXTRACT(param_no_arquivo, r'data_(\d{14})\.csv'))
        LIMIT 1
    );       

    SET qtde_reg = (
        SELECT COUNT(*) 
        FROM `hale-brook-410903.clientes.lg_execucao_processo`
        WHERE tabela = tabela
        AND dh_extracao = dh_extracao_source
        AND no_arquivo = param_no_arquivo
        AND codigo = 0
    );

    IF (qtde_reg > 0) THEN 
        INSERT INTO `hale-brook-410903.clientes.lg_execucao_processo` 
        VALUES (tabela, 5, qtd_reg_source, 0, dh_extracao_source, DATETIME(CURRENT_TIMESTAMP(), "America/Sao_Paulo"), param_no_arquivo);
        RETURN;
    END IF;
  
    INSERT INTO `hale-brook-410903.clientes.stg_cadastro_cliente` (
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
        nome,
        email,
        cidade,
        status,
        data_cadastro,
        PARSE_DATETIME('%Y%m%d%H%M%S', REGEXP_EXTRACT(param_no_arquivo, r'data_(\d{14})\.csv')) AS dh_extracao,
        DATETIME(FORMAT_DATETIME("%Y-%m-%dT%H:%M:%S", CURRENT_DATETIME("America/Sao_Paulo"))) as dh_execucao,
        _file_name 
    FROM `hale-brook-410903.clientes.et_cadastro_cliente`
    WHERE _file_name = param_no_arquivo;

    SET qtd_registros_inseridos = @@row_count;
   
    INSERT INTO `hale-brook-410903.clientes.lg_execucao_processo` 
    VALUES (tabela, 0, qtd_reg_source, qtd_registros_inseridos, dh_extracao_source, DATETIME(CURRENT_TIMESTAMP(), "America/Sao_Paulo"), param_no_arquivo);
END;
