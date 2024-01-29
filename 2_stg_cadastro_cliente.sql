CREATE OR REPLACE TABLE `hale-brook-410903.clientes.stg_cadastro_cliente`
(
	id_cliente	string
,	ds_nome	string
,	ds_email	string
,	ds_cidade	string
,	ds_status	string
,	dh_data_cadastro	string
, 	dh_extracao 	datetime
, 	dh_execucao 	datetime
, 	no_arquivo 	string
)
PARTITION BY DATE(dh_execucao);