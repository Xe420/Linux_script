#! /bin/bash

# Padrão de arquivos originais  
INFILES=2020-0?-gasolina-etanol.csv

# Nome arquivo base consolidada
BASE=base.csv

# Consolidar todas bases
if [ ! -f $BASE ] 
then 
  # Gerar base consolidada
  for INFILE in $INFILES
  do
    # Converter para ASCII 
    # remover CR linha final
    iconv -f utf-16 -t ascii//translit < $INFILE | tr -d '\r' >> $BASE
  done
fi

# Argumentos existem?
if [ $# -lt 3 ]
then
	echo " Uso do script: $0 UF MUNICIPIO PRODUTO"
	exit 1
fi

# Criterios de selecao
UF=$1
MUNI=$2
PROD=$3

# colunas de interesse na base 
COL_REV=4
COL_BAND=11
COL_PRECO=8

#Arquivo com a selecao
SELECAO=$(mktemp)

# Filtrar a base c/ criterios 

grep -i "^..	$UF	$MUNI	 .*	.*	$PROD" < $BASE > $SELECAO

#Arquivo com os precos
PRECOS=$(mktemp)

cut -d '	' -f $COL_PRECO < $SELECAO | \
       	sed -e 's/"//g' -e  's/,/./' > $PRECOS

# Calculo media
MEDIA=$(cat $PRECOS | \
       	awk 'BEGIN {l=0; s=0} { l=l+1; s=s+$1} END {printf "%.2f", s/l}')

# Arquivos nomes postos
POSTOS=$(mktemp)
cut -d '	' -f $COL_REV,$COL_BAND < $SELECAO > $POSTOS

# Posto /c menor preco
MENOR_PRECO=$(paste $PRECOS $POSTOS | sort | head -n 5 | sed 's/	/ - /g')

echo " Valor medio = $MEDIA"
echo " Menor preço = $MENOR_PRECO"

