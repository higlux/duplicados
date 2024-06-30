#!/bin/bash

##Opções
# l - Local de verificação dos arquivos
# f - Formatos de verificação
# t - Tipo de verificação (MD5 padrão)
# p - execução padrão (Mover arquivo duplicado)
# d - Deleta os arquivos temporários
# h - exibe ajuda
# v - Versão do aplicativo
# c - Criar as pastas a partir de datas



###Preciso decidir como tratar os arquivos duplicados, pois tem dois modos
# 1 - Mesmo nome, mas com MD5 diferente
# 2 - Nome diferente, mas com MD5 igual
# 3 - Mesmo nome e com MD5 igual.


##Arquivos temporários
# .arquivos.tmp  - Resultado do find
# .arquivos2.tmp - Resultado do MD5 com caminho #Este arquivo ele não pode ser usado para buscar o caminho do arquivo senão vai dar problema na hora de extrair o conteúdo, por isso eu coloquei um novo arquivo com MD5 e data para facilitar a busca. adicionei numa terceira coluna a data de criação do arquivo, mas eu irei retirar e criar um novo arquivo de texto.
# .arquivos3.tmp - Só os códigos MD5
# .arquivos4.tmp - Arquivos duplicados
# .arquivos5.tmp - Código MD5 com data


#Declaração de variáveis
LOCAL="/home/higlux/Imagens/Fotografias"
#Nome da pasta duplicado
NOME_PASTA_DUPLICADOS=duplicados
PASTA_DUPLICADOS="$LOCAL/$NOME_PASTA_DUPLICADOS"

#Determina caso o LOCAL estiver vazio, a pasta atual como padrão
if [ $LOCAL = "" ]; then 
    LOCAL=$PWD
fi
if [ $DEBUG -eq 1 ]; then
    echo "**** Teste de variáveis"
    echo $LOCAL
    echo $SUM
    echo "**** Fim teste de variáveis"
fi

if [ -e .arquivos.tmp ]; then
    echo "O aquivo .arquivos.tmp existe"
else
    find $LOCAL -type f > .arquivo.tmp
    #Remove o nome da pasta - NOME_PASTA_DUPLICADOS = duplicados está definido como padrão
    cat .arquivo.tmp | sed /$NOME_PASTA_DUPLICADOS/d > .arquivos.tmp
    rm -rf .arquivo.tmp
fi
QTD=$(cat .arquivos.tmp | wc -l)

######### INÍCIO DAS FUNÇÕES PERSONALIZADAS
##PAUSE
function pause(){
    read -s -n 1 -p "Press any key to continue . . ."
    echo ""
}

#
cria_pastas() {
##LOCALIZAÇÃO DOS DADOS DENTRO DO ARQUIVO "DATAS.TMP"
# cut -b 1-4 #ano #cut -b 6-7 #mês #cut -b 9-10 #dia

    QTD_PASTA_ANOS=$(cat .arquivos5.tmp | awk '{print $2}' | sort | cut -b 1-4 | uniq -d | wc -l)
    for (( i=1; i<=$QTD_PASTA_ANOS; i+=1 )); do
        LINHA_PASTA_ANOS=$(cat .arquivos5.tmp | awk '{print $2}' | sort | cut -b 1-4 | uniq -d | head -$i | tail -1)

        #Aqui vai aparecer linha a linha do arquivo
        #DEU CERTO PRECISA MESCLAR COM O CAMINHO DO ARQUIVO POSSO COLOCAR COMO PARÂMETRO DESTA FUNÇÃO O LOCAL ONDE SERÁ CRIADO EXEMPLO $1 -> CAMINHO DA MODIFICAÇÃO, ISSO JÁ ENTRARÁ COMO PARÂMETRO NO SCRIPT ORIGINAL, SOMENTE REPASSAR

        if [[ $DEBUG=1 ]]; then
            echo "mkdir $LINHA_PASTA_ANOS"
            echo "    Meses do ano de $LINHA_PASTA_ANOS" #EXEMPLO: Meses do ano de 2020
        fi

        #CRIAÇÂO DA PASTA
        echo "Criando pasta do ano de "$LINHA_PASTA_ANOS

        DESTCRIAR=$(echo $LOCAL"/"$LINHA_PASTA_ANOS)
        
        test -d $DESTCRIAR || mkdir $DESTCRIAR && echo "Pasta existe"
        
        QTD_PASTA_MESES=$(cat .arquivos5.tmp | awk '{print $2}' | sort | cut -b 1-7 | uniq -d | grep $LINHA_PASTA_ANOS | cut -b 6-7 | wc -l)

        for (( j=1; j<=$QTD_PASTA_MESES; j+=1 )); do
            LINHA_PASTA_MES=$(cat .arquivos5.tmp | awk '{print $2}' | sort | cut -b 1-7 | uniq -d | grep $LINHA_PASTA_ANOS | cut -b 6-7 | head -$j | tail -1)
            ANOMES=$LINHA_PASTA_ANOS-$LINHA_PASTA_MES 
            if [[ $DEBUG=1 ]]; then
                echo "        mkdir ./"$LINHA_PASTA_ANOS"/"$LINHA_PASTA_MES #EXEMPLO: ./2020/01
                #cat datas.tmp | awk '{print $1}' | sort |  uniq -d | grep 2018-11 | cut -b 9-10 #Exibe os dias do mês
                echo "                 \$ANOMES: "$ANOMES
            fi
            echo "Criando pasta do ano "$LINHA_PASTA_ANOS" mês de "$LINHA_PASTA_MES
            DESTCRIAR=$(echo $LOCAL"/"$LINHA_PASTA_ANOS"/"$LINHA_PASTA_MES)
            
            test -d $DESTCRIAR || mkdir $DESTCRIAR && echo "Pasta existe"

            QTD_PASTA_DIAS=$(cat .arquivos5.tmp | awk '{print $2}' | sort | cut -b 1-7 | uniq -d | grep $ANOMES | cut -b 9-10 | wc -l)
            echo "        Quantidade de dias no mês de "$LINHA_PASTA_MES" : "$QTD_PASTA_DIAS
            for (( k=1; k<=$QTD_PASTA_DIAS; k+=1 )); do
                LINHA_PASTA_DIAS=$(cat .arquivos5.tmp | awk '{print $2}' | sort | cut -b 1-7 | uniq -d | grep $ANOMES | cut -b 9-10 | head -$k | tail -1)
                if [[ $DEBUG=1 ]]; then
                    echo "                            mkdir "$LINHA_PASTA_ANOS"/"$LINHA_PASTA_MES"/"$LINHA_PASTA_DIAS
                fi
                echo "Criando pasta do ano "$LINHA_PASTA_ANOS" mês de "$LINHA_PASTA_MES" dia de " $LINHA_PASTA_DIAS
                DESTCRIAR=$(echo $LOCAL"/"$LINHA_PASTA_ANOS"/"$LINHA_PASTA_MES"/"$LINHA_PASTA_DIAS)

                test -d $DESTCRIAR || mkdir $DESTCRIAR && echo "Pasta existe"
            done
        done
    done
    echo "Deseja mover os arquivos para essas pastas? [S/N]"
    read RESP
    if [[ $RESP = "S" || $RESP = "s" ]]; then
        classificar_mover
    else
        exit
    fi
    exit
}

classificar_mover() {
    QTD_MOVER=$(cat .arquivos5.tmp | wc -l)
    for (( mi=1; mi<=$QTD_MOVER; mi+=1 )); do
        echo "Foi"
        CAMINHO_MOVER=$LOCAL/$(cat .arquivos5.tmp | sed 's/-/\//g' | awk '{print $2}' | head -$mi | tail -1)
        if [[ -d $CAMINHO_MOVER ]]; then
            echo "Existe o caminho"
        else
        #PAREI AQUI PARA TESTAR
        ########BUG ENCONTRADO
        #FIZ O TESTE E EXISTEM CAMINHOS QUE NÃO FORAM CRIADOS.
        #PRECISO DEBUGAR O CÓDIGO COM CALMA
        #PARA RESOLVER CRIEI UM CÓDIGO PARA FAER A PASTA NOVAMENTE
        #
        #
        #
            echo "Crinado... "$CAMINHO_MOVER
            mkdir $CAMINHO_MOVER
        fi
    pause
    done
}
######### FIM DAS FUNÇÕES PERSONALIZADAS

#Entrada de parâmetros do script - teste
echo "Entrada de parâmetros - Por enquanto somente um parâmetro por vez"
echo "Parâmetros passados:  1:$1"
DEBUG=0
if [ $1 != "" ]; then
    case $1 in 
        -d)
        echo "Apagando arquivos temporários"
        rm -rf .arquivos*.tmp
        rm -rf datas.tmp
        exit
        ;;
        -h)
        echo "Opções disponíveis:
        -c  Cria pastas com base na data de criação.
        -d  Apaga os arquivos temporários
        -h  Exibe esta ajuda
        -v  Exbe a versãro do arquivo"
        exit
        ;;
        -v)
        echo "  Duplicados Versão 0.0.0.2 alfa"
        exit
        ;;
        --debug)
        echo "Modo debug ativado"
        DEBUG=1;
        ;;
        -c)
        echo "Criando as pastas de acordo com a lista de datas .arquivos5.tmp"
        cria_pastas
        exit
        ;;
        -t)
        echo "Insira o caminho do verificador: "
        echo "Esse comando ainda não funciona"
        pause
        exit
        ;;
        *)
        echo "O parâmetro $1 é um comando inválido"
        exit
        ;;
    esac
fi

#echo "1:$1"
#echo "2:$2"
#echo "3:$3"
echo "Fim verificação parãmetros"


#Verificação da existência do md5
#Inserir a possibilidade de escolher outro verificador
if [ -e /usr/bin/md5sum ]; then
   SUM=/usr/bin/md5sum
else
    echo "O md5 não está instalado"
    exit 1
fi

#Declaração de variáveis
    LOCAL="/home/higlux/Imagens/Fotografias"
    #Nome da pasta duplicado
    NOME_PASTA_DUPLICADOS=duplicados
    PASTA_DUPLICADOS="$LOCAL/$NOME_PASTA_DUPLICADOS"

#Determina caso o LOCAL estiver vazio, a pasta atual como padrão
    if [ $LOCAL = "" ]; then 
        LOCAL=$PWD
    fi
    if [ $DEBUG -eq 1 ]; then
        echo "**** Teste de variáveis"
        echo $LOCAL
        echo $SUM
        echo "**** Fim teste de variáveis"
    fi

###Início do Script
###.# Criação do arquivo .arquivos.tmp - Saída bruta do find 
    if [ -e .arquivos.tmp ]; then
        echo "O aquivo .arquivos.tmp existe"
    else
        find $LOCAL -type f > .arquivo.tmp
        #Remove o nome da pasta - NOME_PASTA_DUPLICADOS = duplicados está definido como padrão
        cat .arquivo.tmp | sed /$NOME_PASTA_DUPLICADOS/d > .arquivos.tmp
        rm -rf .arquivo.tmp
    fi
###.# Criação do arquivo .arquivos2.tmp - Saída do MD5

if [ -e .arquivos2.tmp ]; then
    echo "O Arquivo .arquivos2.tmp de busca existe"
    PROGRESSO2=1
else
    for (( i=1; i<=$QTD; i+=1 ));
    do
        ARQ=$(cat .arquivos.tmp | head -$i | tail -1)
        ######################################## BUG ENCONTRADO ########################################
        #Apresentando problema nesss comando acima, pois os arquivos da linha 6089 e 7156 por conta do fato deles serem arquivos de texto e com isso estão lendo o conteúdo dele. posso tentar resolver se eu tirar a variável e colocar o comando dentro da outra variável, com isso pode resolver.

        #Isso faz com que o maior espaço dê valores astronômicos que passa a dar erro quando precisar mover algum arquivo mais abaixo.
        #19JUN2024 - Fiz a alteração do comando "cat" para "echo" - Reolveu

        #Enquanto não dá certo, podemos ignorar esse erro? Para testes sim
        
            if [ $DEBUG -eq 1 ]; then
                echo "Variável ARQ: $ARQ"
                echo "Linha do arquivo .arquivos.tmp: $i"
                #pause 'Aperte Enter'0
            fi
        ##### ANTIGO
        #md5sum "$ARQ" >> .arquivos2.tmp 2>/dev/null
        #####NOVO
            ### O Resultado abaixo deve entrar em uma variável para depois unir com os dados EXIF e criar uma nova coluna
            MD5TMP=$(md5sum "$ARQ" 2>/dev/null)
            ### Captura dos dados EXIF
            #EXIFTMP=$(exif "$ARQ" | grep "Data e hora (ori" | awk '{print $4}' | sed 's/[a-z(|]//g')
            ### Informação do comando LS (Data de modificação)
            EXIFTMP=$(ls -lt --time-style=long-iso "$ARQ" | awk '{print $6}')
            ### Aqui deve fazer a concatenação entre o MD5 e o EXIF
            SAIDATESTE=$MD5TMP
###### Modificação 27JUN
           MD5COD=$(echo $MD5TMP | awk '{print $1}')
           echo $MD5COD" "$EXIFTMP >> .arquivos5.tmp
###### Fim modificação
            #Informação de DEBUG
            if [ $DEBUG -eq 1 ]; then
                echo "Variável ARQ" "$ARQ"
                echo "Variável EXITFTMP: $EXIFTMP"
                echo "Variável SAIDATESTE: $SAIDATESTE"
                pause 'Aperte Enter'
            fi
            echo "$SAIDATESTE" >> .arquivos2.tmp
        PROGRESSO=$(echo "scale=2; ($i / $QTD) * 100" | bc)
        echo -ne "\\r[$TRALHA] $PROGRESSO%"
    done
fi

if [ -e .arquivos3.tmp ]; then
    echo "Arquivo .arquivos3.tmp unico exite"
else
#Pega primeira coluna do arquivos 2 e passa para o arquivos 3
#Faz isso somente para não ficar usando o arquvio 2 para comparar com  o arquivo 4 (duplicados )
#É desnecessário, mas melhor não arriscar por enquanto corromper o arquivo 2
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
        QTD_MD5_LOC=$(cat .arquivos2.tmp | grep $MD5_LOC | wc -l) #Conta quantidade de arquivos repetidos
        echo "$i: $MD5_LOC Quantidade: $QTD_MD5_LOC"
        for (( j=1; j<=$QTD_MD5_LOC - 1; j+=1 )); do
            #BUG - Aqui dá o BUG que não sai o caminho completo do arquivo estou me baseando nos espaços para selecionar as colunas, porém tem arquivos com nome com espaço para resolver eu vou usar a seguinte estratégia: Ao invés de tentar descobrir a quantidade de espaços vou pegar a linha do arquivo na lista de MD5 somente códigos, e extrair do .arquivos.tmp que sai completo por ter uma coluna apenas.
            LINHA=$(cat -n .arquivos2.tmp | grep $MD5_LOC | cut -f2 -d: | awk '{print $1}' | head -$j | tail -1)
            ARQ_MOVER=$(cat .arquivos.tmp | head -$LINHA | tail -1)

            ARQ_NOVO="${ARQ_MOVER%.*}($j).${ARQ_MOVER##*.}"
            ARQ_SCAM=$(echo $ARQ_NOVO | sed 's:.*/::')
            
            #Aqui movemos os arquivos duplicados


             if [ $DEBUG -eq 1 ]; then
                echo "Movendo de:"
                echo \"$ARQ_MOVER\"
                echo "Movendo para:"
                echo $PASTA_DUPLICADOS/$ARQ_SCAM
                mv -nib \"$ARQ_MOVER\" \"$PASTA_DUPLICADOS/$ARQ_SCAM\" >> error.log
                pause
            else
                mv -nb \"$ARQ_MOVER\" \"$PASTA_DUPLICADOS/$ARQ_SCAM\"
             fi
             if [ $DEBUG -eq 1 ]; then
                echo "######## TESTE ########"
                echo "Linha detectada: $LINHA"
                echo "ARQMOVER: $ARQ_MOVER"
            fi
        done
    done
#Exibir a linha 2 do .arquivo2.tmp
#sed -n 2p .arquivo2.tmp

#Imprimir n linhas
#sed '2q' .arquivos2.tmp
#Exibe só o nome do arquivo
#cat .arquivos2.tmp | awk '{print$2}' | sed 's:.*/::'


mes() {
    long=true
  case $1 in 
        -01)
           [[ $long=false ]] || echo "Janeiro" && echo "Jan"
            exit
        ;;
        -02)
            [[ $long=false ]] || echo "Fevereiro" && echo "Fev"
            exit
        ;;
        -03)
            [[ $long=false ]] || echo "Março" && echo "Mar"
            exit
        ;;
        -04)
            [[ $long=false ]] || echo "Abril" && echo "Abr"
            exit
        ;;
        -05)
            [[ $long=false ]] || echo "Maio" && echo "Mai"
            exit
        ;;
        -06)
            [[ $long=false ]] || echo "Junho" && echo "Jun"
            exit
        ;;
        -07)
            [[ $long=false ]] || echo "Julho" && echo "Jul"
            exit
        ;;
        -08)
            [[ $long=false ]] || echo "Agosto" && echo "Ago"
            exit
        ;;
        -09)
            [[ $long=false ]] || echo "Setembro" && echo "Set"
            exit
        ;;
        -10)
            [[ $long=false ]] || echo "Outubro" && echo "Out"
            exit
        ;;
        -11)
            [[ $long=false ]] || echo "Novembro" && echo "Nov"
            exit
        ;;
        -12)
            [[ $long=false ]] || echo "Dezembro"  && echo "Dez"
            exit
        ;;
esac



}
