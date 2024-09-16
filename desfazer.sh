#!/usr/bin/env bash
########
#PROGRAMA PARA DESMOVER OS ARQUIVOS DE FOTO
# INTUITO DE TESTE APENAS
########
destino=$1
[[ -d "$destino" ]] || echo "Pasta não existe";
arquivos=$(find "$destino" -type f)
quantidade=$(echo "$arquivos" | wc -l)

echo -n "[1/3] - Movendo os arquivos..."
for (( i=1; i<="$quantidade"; i+=1 )); do
    linha=$(echo "$arquivos" | head -"$i" | tail -1)
    #echo "$i: mv $linha $destino"
    mv -i "$linha" "$destino" 2> /dev/null
done
unset $arquivos
unset $quantidade
unset $i
echo "Concluído"
echo -n "[2/3] - Apagando as pastas..."
pastas=$(find $destino -type d | sed '1d' | sort -r)
quantidade=$(echo "$pastas" | wc -l)

for (( i=1; i<=$quantidade; i+=1 ));
do
    rm -d $( echo $pastas | head -"$i" | tail -1) 2> /dev/null
done
echo "Concluído"
echo -n "[3/3] - Removendo os arquivos temporários..."
rm -rf "$destino""/.arquivos.tmp"
rm -rf "$destino""/.arquivos2.tmp"
rm -rf "$destino""/.arquivos3.tmp"
rm -rf "$destino""/.arquivos4.tmp"
rm -rf "$destino""/.arquivos5.tmp"
rm -rf "$destino""/.arquivos6.tmp"
echo "Concluído"
