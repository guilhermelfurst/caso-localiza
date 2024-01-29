CREATE OR REPLACE EXTERNAL TABLE `hale-brook-410903.clientes.et_cadastro_cliente`
(
	id_cliente	string
,	nome	string
,	email	string
,	cidade	string
,	status	string
,	data_cadastro	string
)
OPTIONS
(
  allow_jagged_rows=true,
  field_delimiter=",",
  skip_leading_rows=1,
--  encoding='UTF-8',
  encoding='ISO-8859-1',
--  quote= "¬",
  quote= '"',
  allow_quoted_newlines=true,
  ignore_unknown_values=true,
  format="CSV",
  max_bad_records=50,
  uris = ['https://storage.cloud.google.com/arvore-exemplo/data_*.csv']
);

