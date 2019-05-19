#!/bin/bash

#set -x


# Definindo as constantes:
SITE="http://portaldatransparencia.gov.br/download-de-dados/despesas"
INIT_DAY=$(printf "%02d" $1)
FINAL_DAY=$(printf "%02d" $2)
MONTH=$(printf "%02d" $3)
YEAR=$4
DATA_DIR="dados"
TMP_DIR="tmp"
DATA_DIR_PATH="./$DATA_DIR"
TMP_DIR_PATH="./$TMP_DIR"
FILENAME_PAG="Despesas_Pagamento.csv"
FILENAME_EMP="Despesas_Empenho.csv"
OUT_PAG=$YEAR$MONTH$INIT_DAY'-'$FINAL_DAY'_'$FILENAME_PAG
OUT_EMP=$YEAR$MONTH$INIT_DAY'-'$FINAL_DAY'_'$FILENAME_EMP
OUT_PAG_PATH=$DATA_DIR_PATH/$OUT_PAG
OUT_EMP_PATH=$DATA_DIR_PATH/$OUT_EMP


# Criando diretórios necessarios:
mkdir $DATA_DIR 2> /dev/null
mkdir $TMP_DIR 2> /dev/null


# Baixando, descompactando e removendo os arquivos:
for day in $(seq -f "%02g" $INIT_DAY$FINAL_DAY); do
  zipFile=$YEAR$MONTH$day.zip

  echo -n "Baixando arquivo $zipFile ..."
  wget $SITE/$zipFile 2> /dev/null && echo OK


  echo -n "Descompactando arquivo $zipFile ..."
  unzip -o $zipFile '*'$FILENAME_PAG -d $TMP_DIR_PATH > /dev/null
  unzip -o $zipFile '*'$FILENAME_EMP -d $TMP_DIR_PATH > /dev/null
  echo OK

  echo -n "Removendo arquivo $zipFile ..."
  rm -f $zipFile && echo OK


  ## Redirecionando os headers:
  if [ $day -eq $INIT_DAY ]; then
    head -1 $TMP_DIR_PATH/$YEAR$MONTH$day'_'$FILENAME_PAG > $OUT_PAG_PATH
    head -1 $TMP_DIR_PATH/$YEAR$MONTH$day'_'$FILENAME_EMP > $OUT_EMP_PATH
  fi
 
done


# Concatenando os arquivos:
cd $TMP_DIR_PATH

echo -n "Concatenando arquivo $OUT_PAG ..."
for file in *$FILENAME_PAG; do
  tail -n +2 $file >> ../$OUT_PAG_PATH
  rm $file
done
echo OK

echo -n "Concatenando arquivo $OUT_EMP ... "
for file in *$FILENAME_EMP; do
  tail -n +2 $file >> ../$OUT_EMP_PATH
  rm $file
done
echo OK