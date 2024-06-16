#!/bin/bash
#
# Essa é a primeira versão do arquivo.
# Finalizado em 09JUN2024
#
#


#Opções
# l - Local de verificação dos arquivos
# f - Formatos de verificação
# t - Tipo de verificação (MD5 padrão)

#Preciso decidir como tratar os arquivos duplicados, pois tem dois modos
# 1 - Mesmo nome, mas com MD5 diferente
# 2 - Nome diferente, mas com MD5 igual
# 3 - Mesmo nome e com MD5 igual.

# p - execução padrão (Mover arquivo duplicado)

# .arquivos.tmp - Resultado do find
# .arquivos2.tmp - Resultado do MD5
# .arquivos3.tmp - Só os códigos MD5
# .arquivos4.tmp - Arquivos duplicados


#Verificação da existência do md5
if [ -e /usr/bin/md5sum ]; then
   SUM=/usr/bin/md5sum
else
    echo "O md5 não está instalado"
    exit 1
fi

#Remover os arquivos.
#if [ -e .arquivos.tmp ]; then
    #rm -rf .arquivos.tmp
    #rm -rf .arquivos2.tmp
#fi

#Declaração de variáveis
    LOCAL="/home/higlux/Imagens/Fotografias"
    #Nome da pasta duplicado
    NOME_PASTA_DUPLICADOS=duplicados
    PASTA_DUPLICADOS="$LOCAL/$NOME_PASTA_DUPLICADOS"
#Determina caso o LOCAL estiver vazio, a pasta atual como padrão
    if [ $LOCAL = "" ]; then 
        LOCAL=$PWD
    fi

    echo "**** Teste de variáveis"
    echo $LOCAL
    echo $SUM
    echo "**** Fim teste de variáveis"

    if [ -e .arquivos.tmp ]; then
        echo "O aquivo .arquivos.tmp existe"
    else
        find $LOCAL > .arquivo.tmp
        #Remove o nome da pasta - NOME_PASTA_DUPLICADOS = duplicados está definido como padrão
        cat .arquivo.tmp | sed /$NOME_PASTA_DUPLICADOS/d > .arquivos.tmp
        rm -rf .arquivo.tmp
    fi

    QTD=$(cat .arquivos.tmp | wc -l)

    echo 'Arquivos encontrados: '$QTD
#extract IMG_20180224_115006.jpg -p "data de criação" | grep -e ....":"..":".." "..":"..":"..

#Para a barra de progresso
BARRA_PROGRESSO="##########"

#Teste para saber se a linha é um diretório, se não for ele vai adicionar o md5
if [ -e .arquivos2.tmp ]; then
    echo "O Arquivo .arquivos2.tmp de busca existe"
    PROGRESSO2=1
else
    for (( i=1; i<=$QTD; i+=1 ));
    do
        ARQ=$(cat .arquivos.tmp | head -$i | tail -1)
        md5sum "$ARQ" >> .arquivos2.tmp
        PROGRESSO=$(echo "scale=2; ($i / $QTD) * 100" | bc)
            if [ $PROGRESSO2 > $PROGRESSO ]; then
                TRALHA+="#"
                $PROGRESSO2 = $PROGRESSO + 1 | bc
            fi
        echo -ne "\\r[$TRALHA] $PROGRESSO%"
    done
fi

if [ -e .arquivos3.tmp ]; then
    echo "Arquivo .arquivos3.tmp unico exite"
else
#Pega primeira coluna do arquivos 2 e passa para o arquivos 3
    cat .arquivos2.tmp | sort | awk '{print $1}' > .arquivos3.tmp 
fi
#Pega o arquivos 3 e passa para o arquivos 4 sem duplicados
sort .arquivos3.tmp | uniq -d > .arquivos4.tmp

#Criar pasta para mover arquivos duplicados

if [[ -d $PASTA_DUPLICADOS ]]; then 
    echo "Pasta de arquivos duplicados existe"
else
    mkdir "$LOCAL/duplicados"
fi
QTD_DUP=$(cat .arquivos4.tmp | wc -l)
for (( i=1; i<=$QTD_DUP; i+=1 ));
    do
        MD5_DUP=$(cat .arquivos4.tmp | head -$i | tail -1)
        cat .arquivos2.tmp | grep `cat .arquivos4.tmp | head -$i | tail -1` >> saida.txt          
        #Outro LOOP
        #for (( j=1; j<=$QTD; j+=1 ));
        #do
         #   MD5_ORIG=$(cat .arquivos2.tmp | awk '{print $1}'| head -$j | tail -1)
          #  ARQ_MOVER=$(cat .arquivos2.tmp | awk '{print $2}'| head -$j | tail -1)
           # if [ $MD5_ORIG == $MD5_DUP ]; then
                #mv $ARQ_MOVER $PASTA_DUPLICADOS
            #    echo "$MD5_ORIG = $MD5_DUP" >> saida.txt
             #   echo "Movendo o arqvivo $ARQ_MOVER para $PASTA_DUPLICADOS" >> saida.txt
            #fi
            #echo "Verificando Arquivo $i de $j"
        #done
    done
    echo "Quantidade de arquivos detectados: $QTD
    Quantidade de arquivos duplicados:$QTD_DUP"

#Aqui moverei os arquivos que estão duplicados
#arquivos4 -> MD5 Duplicados
#saida.txt -> Arquivos duplicados s/ tratamento com caminho

    for (( i=1; i<=$QTD_DUP; i+=1 )); do
        MD5_LOC=$(cat .arquivos4.tmp | head -$i | tail -1) #Aqui sai o MD5 para procurar no outro arquivo
        QTD_MD5_LOC=$(cat .arquivos2.tmp | grep $MD5_LOC | wc -l)
        echo "$i: $MD5_LOC Quantidade: $QTD_MD5_LOC"
        for (( j=1; j<=$QTD_MD5_LOC - 1; j+=1 )); do
            ARQ_MOVER=$(cat .arquivos2.tmp | grep $MD5_LOC | head -$j | tail -1 | awk '{print $2}')
            ARQ_NOVO="${ARQ_MOVER%.*}($j).${ARQ_MOVER##*.}"
            ARQ_SCAM=$(echo $ARQ_NOVO | sed 's:.*/::')
            #echo "$ARQ_MOVER $PASTA_DUPLICADOS" >> .arquivos5.tmp
            #echo $ARQ_NOVO
            echo "Movendo $ARQ_MOVER para $PASTA_DUPLICADOS/$ARQ_SCAM"
            mv $ARQ_MOVER $PASTA_DUPLICADOS/$ARQ_SCAM 2>/dev/null
        done
    done
#Exibir a linha 2 do .arquivo2.tmp
#sed -n 2p .arquivo2.tmp

#Imprimir n linhas
#sed '2q' .arquivos2.tmp
#Exibe só o nome do arquivo
#cat .arquivos2.tmp | awk '{print$2}' | sed 's:.*/::'
