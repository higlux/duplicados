#!/bin/env bash
########
#PROGRAMA PARA DESMOVER OS ARQUIVOS DE FOTO
# INTUITO DE TESTE APENAS
########
destino=$1
[[ -d "$destino" ]] || echo "Pasta não existe";
arquivos=$(find "$destino" -type f)
quantidade=$(echo "$arquivos" | wc -l)


for (( i=1; i<="$quantidade"; i+=1 )); do
    linha=$(echo "$arquivos" | head -"$i" | tail -1)
    #echo "$i: mv $linha $destino"
    mv -i "$linha" "$destino"
done