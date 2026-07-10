#!/usr/bin/env bash

ENCERREI POR HOJE, CORRIJI O ERRO DE NÃO CRIAR PASTA E TAMBÉM MOVER ARQUIVOS, ESTÁ FAZENDO.

FALTA:  COLOCAR O SCRIPT DE ARQUVIOS CORROMPIDOS PARA FUNCIONAR
        TESTAR PARA VER SE ESTÁ MOVENDO TODOS OS ARQUVIOS (COMPARAR O ANTES COM O DEPOIS)
        COLOCAR O DESFAZEDOR PARA FUNCIONAR


######################################################################
# 
# AUTOR:        Higlux Morales
# EMAIL:        higluxmorales@gmail.com
# PROGRAMA:     duplicados.sh
# LICENÇA:      GPL 3
# VERSÃO:       1.4 Beta
# DESCRIÇÃO:    Programa que busca arquivos duplicados
#
# CHANGELOG:
#   (05AGO2024) - 0.0.1 - bETA 
#   (10AGO2024) - 1.0 - Higlux Morales
#       Melhorei a estrutura do programa que poderá ser utilizado.
#       Adaptando boas práticas de programação em shell 
#   PASSAR O SHELLCHECK PARA VERIFICAR ERROS
#   (11AGO2024) - 1.0 - Higlux Morales
#       Adicionei um código para detectar arquivo duplicado e renomear o arquivo - ainda não está pronto
#   (14AGO2024) - 1.0 - Higlux Morales
#       Encontrei um BUG na função CLASSIFICAR_MOVER que permite funcionar a função sem o caminho de destino.
#   (31AGO2024) - 1.0 - Higlux Morales
#       Correção de vários BUGS dentro do código, corrigindo script a script
#   (06SET2024) - 1.1 - Higlux Morales
#       Correção de erros do Shellcheck - Colocar aspas nas variáveis
#       Correção de erros do Shellcheck - Useless cat
#   (15SET2024) - 1.1 - Higlux Morales
#       Ajuste do código
#       Criação do código que coloca o nome dos meses por extenso tanto curto como longo
#       Melhoria de prática
#   (19OUT2024) - 1.2 - Higlux Morales
#       Adição de comentário para investigação de um BUG
#   (30OUT2024) - 1.2 - Higlux Morales
#       Adição de código para identificar arquivo jpeg com problema
#   (03NOV2024) - 1.2 - Higlux Morales
#       Unificação dos códigos de mensagem
#   (03NOV2024) - 1.3 - Higlux Morales
#       Simplificação de código
#   (09JUL2026) - 1.4 - Higlux Morales
#       Adicionar verificador de comandos faltantes
#       Adicionado verificação de sistema operacional e distribuição
#       Adicionando verificação de arquivos corrompidos (BADFILE jpg)
#   (10JUL2026) - 1.4 - Higlux Morales
#       Corrigido BUG que não criava pastas mês e dia (cut errado)
######################################################################

##################################
#           BUGS CONHECIDOS
##################################

# Pasta vazia após criação: Um BUG muito comum é encontar pastas sem conteúdo após a conclusão do script, suspeito que as pastas vazias estão ligadas aos arquivos duplicados que foram movidos para outra pasta e assim essas pastas ficam vazias.

#ESSE CÓDIGO ELE FAZ O SCRIPT SAIR QUANDO DÁ ERRO
#set -e #Não dá por enquanto.

##################################
#           VARIÁVEIS
##################################
readonly prg='Duplicados'
readonly vers='1.4 Beta'
#Por padrão deixar isso ligado
declare debug
declare local_destino
declare local_destino_duplicado
declare ignore
#Informações sobre o sistema atual
source /etc/os-release

entradas=($*)
readonly RESET='\e[0m'      #Volta o texto ao nomal
readonly DBG='\e[1;33m'     #Laranja
readonly INFO='\e[1;36m'    #Ciano # Informações
readonly ERROS='\e[1;31m'   #Vermelho
readonly EXIST='\e[1;32m'   #VERDE
##################################
#           FUNÇÕES
##################################
ignore='S'
debug=1
badfile=0
#################
# INÍCIO FUNÇÃO PERSONALIZADA
#################

RELP() {
############
# TIPO:      FUNÇÃO DE INFORMAÇÃO
# FUNÇÃO:    Exibir os parâmetros
# ALTERAÇÃO: 15SET2024
############
                    echo "Opções disponíveis:           
                -h --help      Exibe ajuda
                -l --local     Local de verificação dos arquivos (Requerido)
                -f --filtrar   Remove extensões da busca (filtro)
                -t --tipo      Tipo de verificação (MD5 padrão)
                -o --copy      Execução alternativa (Mover arquivo duplicado padrão)
                -a --apagar    Deleta os arquivos temporários
                -v --version   Versão do aplicativo
                -u --mudar     Muda o formato do mês para
                               (c - Curto Ex. JAN) (l - Longo Ex. Janeiro).
                               Sem parâmetro as datas serão numéricas
                -debug         Exibe debug do código
                -m --mover     Pasta para onde irá mover ou copiar os arquivos duplicados
                -d --destino   Destino dos arquivos (Requerido)
                -y --yes       Define sim para todas as perguntas
                -b --badfile   Localiza arquivos corrompidos (Desativado padrão)
                $prg - $vers
                "
}
#BUG - 10JUL2026: Está saindo o nome do mês com 2 dígitos enquanto não passa o parãmentro de curto ou longo.
#                 o correto seria aparecer números, o que não ocorre.


################# FUNÇÕES DE SAÍDA
MSG() {
############
# TIPO:      FUNÇÃO DE SAÍDA
# FUNÇÃO:    Exibir mensagens durante o script e código de saida
# CRIAÇÃO:   03NOV2024
# OBS:       Cada tipo de mensagem será uma cor:
#               ENDBAD    -> Saída do script com status de saída 1 (ERRO)
#               ENDGOOD   -> Saída do script com status de saída 0 (OK)
#               DBG       -> Mensagem de Debug - Cor Laranja
#               INFRM     -> Mensagem de informação - Cor Azul
#               ERR       -> Mensagem de erro - Cor Vermelho
############
    local tipo
    local msg
    local sts_saida

    tipo=$1
    msg=$2

    [[ -z "$msg" ]] && echo -e "$ERROS""[ERRO] - INFRM requer uma mensagem""$RESET" \ exit;

     case $tipo in 
        "ENDBAD")
        echo -e "$ERROS[ERRO]$RESET - $msg"
        echo -e "Muito obrigado por usar $prg $vers"
        exit 1
        ;;
        "ENDGOOD")
        echo -e "$msg"
        echo -e "Muito obrigado por usar $prg $vers"
        exit 0
        ;;
        "DBG")
            cor=$DBG
            tipo="DEBUG"
        ;;
        "INFRM")
            cor=$INFO
            tipo="INFORMAÇÃO"
        ;;
        "ERR")
            cor=$ERROS
            tipo="ERRO"
        ;;
        *)
        ;;
     esac
     echo -e "$cor [$tipo] - $msg $RESET"
}

PAUSE(){
############
# TIPO:      FUNÇÃO DE INFORMAÇÃO
# FUNÇÃO:    Pausa a execução do script
# ALTERAÇÃO: 06SET2024
############
    read -srp "Press any key to continue . . ."
    echo ""
}

BADFILE_TEST() {
############
# TIPO:      FUNÇÃO DE TRANSFORMAÇÃO
# FUNÇÃO:    Testa para ver se a foto não está corrompida
# ALTERAÇÃO: 30OUT2024
# ALTERAÇÃO: 09JUL2026
# OBS:       VARIÁVEIS: 
#                       $1 ORIGEM - Onde estão os arquivos temporários
#                       $2 BADFILE - DIZ SE ESTÁ HABILITADO
#           Não sei qual é a melhor alternativa para retirar os arquivos corrompidos
#           
#           $1 - Origem
#           
############

 ############ DECLARAÇÃO DE VARIÁVEIS
    local arq1
    local arq2
    local arq3
    local arq4
    local arq5
    local arq6
    local arq7
    local arq8

    local arq1_exist
    local arq2_exist
    local arq3_exist
    local arq4_exist
    local arq5_exist
    local arq6_exist
    local arq7_exist
    local arq8_exist

    local qtd_arq1

    local dest_bad
    local origem
    ############ FIM DECLARAÇÃO DE VARIÁVEIS
    
    ######## BLOQUEIO PARA NÃO ENTRAR VALOR VAZIO
    [[ -z "$1" ]] && MSG "ENDBAD" "Origem não pode ser vazio"
    #AQUI PRECISO TESTAR SE O COMANDO EXISTE
    [[ -z "$2" ]] && MSG "INFRM" "Usando o MD5 como verificador"
    ######## FIM BLOQUEIO PARA NÃO ENTRAR VALOR VAZIO
    
    ############ ATRIBUIÇÃO DE VARIÁVEIS
    origem="$1"
    arq1="$origem"/.arquivos.tmp
    arq8="$origem"/.arquivos8.tmp
    arq9="$origem"/.arquivos9.tmp
    ############ FIM ATRIBUIÇÃO DE VARIÁVEIS

    ############ TESTE DE VARIÁVEIS
    arq1_exist=$([[ -e "$arq1" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq8_exist=$([[ -e "$arq8" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq9_exist=$([[ -e "$arq9" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    ############ FIM TESTE DE VARIÁVEIS

  if [[ "$debug" -eq 1 ]]; then
        MSG "DBG" "Debug: Entrou na função BADFILE_TEST com os dados:$RESET
        \$arq1: $arq1 - $arq1_exist - Lista Bruta (*)
        \$arq2: $arq2 - $arq2_exist - Lista MD5
        \$arq3: $arq3 - $arq3_exist - Lista MD5 pura
        \$arq4: $arq4 - $arq4_exist - Lista MD5 duplicados
        \$arq5: $arq5 - $arq5_exist - Lista MD5 com data
        \$arq6: $arq6 - $arq6_exist - Lista MD5 com data extenso
        \$arq7: $arq7 - $arq7_exist - Lista MD5 com data extenso
        \$arq8: $arq8 - $arq8_exist - Lista arquivos não corrompidos (*)
        \$arq8: $arq9 - $arq9_exist - Lista arquivos corrompidos (*)
        \$cmd_sum: $cmd_sum - Formatos a serem buscados"
    fi
    #Aqui irá criar o arquivo origem se ele não existir
    #BUG: MOVER ARQUIVOS .TMP, .SH
    #GUGU
    if [[ ! -e "$arq1" ]]; then
        find -type f > .arquivos.tmp
    fi
    #NOVA FUNÇÃO - 09JUL26
    #FILTRA ENTRADAS NA LISTA
    FILTRA_LISTA $arq1
    #FIM NOVA FUNÇÃO

    for (( linha=1;linha<="$arq1_qtd";linha+=1 ));
    do
        arq1="$(cat .arquivos.tmp | head -$linha | tail -1)"
        magick identify -regard-warnings "$arq1"
        if [ "$?" -eq 0 ]; then
            echo "$arq" >> "$arq8" #Arquivos não corrompidos
        else
            echo "$arq" >> "$arq9" #Arquivos corrompidos
    fi
    done
    #Quantidade de arquivos:
    echo "Arquivos não corrompidos: $(cat .arquivos8.tmp | wc -l)"
    echo "Arquivos corrompidos: $(cat .arquivos9.tmp | wc -l)"
    #PERGUNTA - Saber se pode mover os arquivos corrompidos
    echo 'Gostaria de [M/m]over arquivos corrompidos, [A/a]pagar arquivos corrompidos ou [C/c]ancelar?'
    MSG "INFRM" "Essa ação não poderá ser desfeita."
    echo "Mover arquivos corrompidos [M/A/C]: "
    read -n 1 -r resp
    case $resp in
        M|m)
        mkdir "$origem\badfile"
        dest="$orige\badfile"
        BADFILE_ACAO "$orig" "$dest" "$arq9" "mv"
        ;;
        A|a)
        BADFILE_ACAO "$orig" "$dest" "$arq9" "rm -rf"
        ;;
        C|c)
        exit 0
        ;;
    esac
#Remover os arquivos corrompidos do arquivo original
mv "$arq1" "$arq1.old"
mv "$arq8" "$arq1"
}

BADFILE_ACAO() {
############
# TIPO:      FUNÇÃO DE TRANSFORMAÇÃO
# FUNÇÃO:    Move ou apaga a foto corrompida
# ALTERAÇÃO: 09JUL2026
# OBS:       Função criada para mover os arquivos duplicados
#           
############
    local destino
    local arq
    local origem
    origem=$1
    destino=$2
    arq=$3
    cmd=$4
    qtd_arq="$(cat $arq | wc -l)"

    if [[ -e "$destino" ]]; then 
        echo "diretório $destino existe"
    else
        mkdir "$destino"
    fi
#Separado somente por medo.
    if [[ "$cmd" == "mv" ]]; then
        for ((vez=1;vez<=qtd_arq;vez+=1));
        do
            file="$(cat $arq | head -"$vez" | tail -1)"
            echo "Movendo $file para $destino"
            "$cmd" "$file" "$destino"
        done
    fi
    if [[ "$cmd" == "rm -rf" ]]; then
        for ((vez=1;vez<=qtd_arq;vez+=1));
        do
            file="$(cat $arq | head -"$vez" | tail -1)"
            echo "Apagando $file para $destino"
            "$cmd" "$file" "$destino"
        done
    fi
}
CRIA_DESTINO() {
############
# TIPO:      FUNÇÃO DE CRIAÇÃO
# FUNÇÃO:    Cria as pastas de destino dos arquivos e pasta duplicada
# ALTERAÇÃO: 06SET2024
# COMENTÁRIOS:  Destino dos arquivos, pode ser um caminho completo ou um nome, Obrigatório
#               Primeiro testa pra ver se é vazio ou se a próxima string é um - do próximo parâmetro
############
    

    ####### DECLARAÇÃO DE VARIÁVEIS
    local nz
    local origem
    local dest #para onde irão os arquivos
    local dest_dup #para onde irão os duplicados
    dest="$2"
    origem="$1"
    echo "$dest"
    if [[ -z "$2" ]]; then
        MSG ENDBAD "O local de destino não pode ser vazio"
    else
        nz=$(echo "$dest" | cut -b 1)
        echo "$nz"
        if [[ "$nz" = "\-" ]]; then
            MSG ENDBAD "O local de destino não pode ser vazio"
        fi
    fi

    #Segundo testa para ver se a entrada ela é um diretório ou um nome
    ##### BUG ENCONTRADO!
    # Aqui ele testa para saber se o caminho existe, quando ele não existe concatena o caminho com o destino dando erro!!!!!

    echo "$1" | grep "/"
    if [[ "$?" = 0 ]]; then
        local destino="$1"
    else
        #Aqui insere o caminho antes do nome criando o caminho completo
        local destino="$origem/$1"
    fi

    if [ "$debug" = "1" ]; then
        MSG "DBG" "Entrou em CRIAR_DESTINO"
        echo -e" Entrada: $1
                 Destino: $destino"
    fi

    [[ -z "$destino" ]] && MSG "ENDBAD" "O local de destino não pode ser vazio"
    [[ -d "$destino" ]] && MSG "INFRM" "Usando diretório válido: $destino"
    
    if [[ ! -d "$destino" ]]; then
        if [[ "$ignore" = "S" ]]; then
            mkdir "$destino"
        else
            read -p "Deseja Criar? [S/N]" resp
            resp=${resp^^} #passando o conteúdo para uppercase
            if [ "$resp" = "S" ]; then
                INFORM "Criando $destino:"
                mkdir "$destino"
            else
                MSG ENDBAD "Insira um diretório válido"
            fi
        fi
    fi
    echo "Usando destino: $destino"
    echo "$param"
    if [[ "$param" == "-d" ]]; then
        local_destino="$destino"
    elif [[ "$param" == "-m" ]]; then
        local_destino_duplicado="$destino"
    fi
    echo "$local_destino"
    echo "$local_destino_duplicado"
}


CRIA_LISTAS(){
############
# TIPO:      FUNÇÃO DE CRIAÇÃO
# FUNÇÃO:    Cria os arquivos temporários
# ALTERAÇÃO: 06SET2024
# COMENTÁRIOS: CRIA OS ARQUIVOS
#               .arquivos.tmp  - Lista Bruta
#               .arquivos2.tmp - Lista MD5
#               .arquivos3.tmp - Lista MD5 pura
#               .arquivos4.tmp - Lista MD5 duplicados
#               .arquivos5.tmp - Lista MD5 com data
#               .arquivos6.tmp - Lista MD5 com data por extenso
#               .arquivos7.tmp - Lista MD5 com formatos
#               .arquivos8.tmp - Lista sem arquivos corrompidos
#               .arquivos8.tmp - Lista com arquivos corrompidos
############
    ############ DECLARAÇÃO DE VARIÁVEIS
    local arq1
    local arq2
    local arq3
    local arq4
    local arq5
    local arq6
    local arq7
    local arq8

    local arq1_exist
    local arq2_exist
    local arq3_exist
    local arq4_exist
    local arq5_exist
    local arq6_exist
    local arq7_exist
    local arq8_exist

    local qtd_arq1

    local dest_dup
    local fmt
    local origem
    dest_dup="$4"
    ############ FIM DECLARAÇÃO DE VARIÁVEIS
    
    ######## BLOQUEIO PARA NÃO ENTRAR VALOR VAZIO
    [[ -z "$1" ]] && MSG "ENDBAD" "Origem não pode ser vazio"
    [[ -z "$2" ]] && MSG "INFRM" "Usando o MD5 como verificador"
    ######## FIM BLOQUEIO PARA NÃO ENTRAR VALOR VAZIO
    
    ############ ATRIBUIÇÃO DE VARIÁVEIS
    origem="$1"
    arq1="$origem"/.arquivos.tmp
    arq2="$origem"/.arquivos2.tmp
    arq3="$origem"/.arquivos3.tmp
    arq4="$origem"/.arquivos4.tmp
    arq5="$origem"/.arquivos5.tmp
    arq6="$origem"/.arquivos6.tmp
    arq7="$origem"/.arquivos7.tmp
    arq8="$origem"/.arquivos8.tmp
    arq9="$origem"/.arquivos9.tmp

    fmt="$3"
    ############ FIM DECLARAÇÃO DE VARIÁVEIS

    ############ TESTE DE VARIÁVEIS
    arq1_exist=$([[ -e "$arq1" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq2_exist=$([[ -e "$arq2" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq3_exist=$([[ -e "$arq3" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq4_exist=$([[ -e "$arq4" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq5_exist=$([[ -e "$arq5" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq6_exist=$([[ -e "$arq6" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq7_exist=$([[ -e "$arq7" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq8_exist=$([[ -e "$arq8" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq9_exist=$([[ -e "$arq9" ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    ############ FIM TESTE DE VARIÁVEIS


  if [[ "$debug" -eq 1 ]]; then
        MSG "DBG" "Debug: Entrou na função CRIAR_LISTAS com os dados:$RESET
        \$arq1: $arq1 - $arq1_exist - Lista Bruta (*)
        \$arq2: $arq2 - $arq2_exist - Lista MD5 (*)
        \$arq3: $arq3 - $arq3_exist - Lista MD5 pura (*)
        \$arq4: $arq4 - $arq4_exist - Lista MD5 duplicados (*)
        \$arq5: $arq5 - $arq5_exist - Lista MD5 com data (*)
        \$arq6: $arq6 - $arq6_exist - Lista MD5 com data extenso
        \$arq7: $arq7 - $arq7_exist - Lista MD5 com data extenso
        \$arq8: $arq8 - $arq8_exist - Lista sem arquivos corrompidos
        \$arq9: $arq9 - $arq8_exist - Lista dos arquivos corrompidos
        \$cmd_sum: $cmd_sum - Formatos a serem buscados"
    fi

    ######## SAÍDA PARA NÃO ENTRAR VALOR VAZIO
    if [[ -z "$origem" ]]; then 
        MSG "ENDBAD" "Origem não pode ser vazio"
    fi

    ######## VERIFICAÇÃO SE O ARQUIVO EXISTE
    if [[ ! -e "$arq1" ]]; then
        MSG "INFRM" "Criação do .arquivos.tmp"

        #Aqui cria a lista de arquvios
        # 15SET2024 - AQUI ENTRARÁ A PARTE DE SELEÇÃO DO TIPO DE ARQUIVO
        find "$origem" -type f > "$arq1"
        qtd_arq1=$(wc -l < "$arq1")

        #CÓDIGO PARA REMOVER A PASTA INDICADA COMO DUPLICADO DO BANCO DE BUSCA
        #Remove o nome da pasta - nome_pasta_duplicados = duplicados estava definido como padrão

        remover=$(basename "$local_destino_duplicado")
        echo "A remover $remover"
        #NOVA FUNÇÃO - FILTRAR OS DADOS DA LISTA 1
        FILTRA_LISTA $arq1
        #FIM NOVA FUNÇÃO - FILTRAR OS DADOS DA LISTA 1
    fi
    MSG "INFRM" "FIM da ciração do .arquivos.tmp"

    
    if [[ "$debug" -eq 1 ]]; then
        MSG "INFRM" "INÍCIO CRIAÇÃO DA LISTA MD5"
        MSG "DBG" "Variáveis usadas:
    Local arquivo: $origem
    Comando usado: $cmd_sum
    Quantidade total de arqvivos: $qtd_arq1
    Caminho do .arquvios2: $arq2
    Caminho do .arquvios5: $arq5"
    MSG "DBG" "FIM DEBUG"

    fi

    if [ -e "$arq2" ]; then
       MSG "INFRM" "O arquivo .arquivos2.tmp de busca existe"
        progresso=1
    else
        ######### NOVA CRIAÇÃO DO .arquivo2.tmp
        ## Ele vai criar a lista com o md5
        #find -type f -exec md5sum {} \; > $arq2
        ######### NOVA CRIAÇÃO DO .arquivo5.tmp
        #find -type f -exec ls -lt --time-style=long-iso {} \; | awk '{print $6}' | sed 's/-/\//g' > $arq5
        MSG "INFRM" "Criação dos arquivos 2, 5, 6 e 7"
        for (( i=1; i<="$qtd_arq1"; i+=1 ));
        do
            arq=$(head -"$i" < "$arq1" | tail -1)

            md5tmp=$("$cmd_sum" "$arq" 2>/dev/null)
            
            ### Captura dos dados EXIF - Não implementei pois a maioria dos arquvios que eu tenho não possui os dados EXIF, caso for recolocar, criar um .arquivosN.tmp novo somente com o verificador (MD5 ou outro ) e o dado.

            #exitftmp=$(exif "$arq" | grep "Data e hora (ori" | awk '{print $4}' | sed 's/[a-z(|]//g')
            ### Informação do comando LS (Data de modificação)

            exitftmp=$(ls -lt --time-style=long-iso "$arq" | awk '{print $6}')

            ### Aqui deve fazer a concatenação entre o MD5 e o EXIF
            saidateste="$md5tmp"

            ###### Modificação 27JUN
            ## ALTERAÇÃO DO EXIF PARA DATA
            md5cod=$(echo "$md5tmp" | awk '{print $1}')
            ext="${arq##*.}"
            echo "$md5cod" "$exitftmp" "$ext">> "$arq5"

            ###### Fim modificação
            echo "$saidateste" >> "$arq2"
            ###### Criação do . arquivos7.tmp
            #echo "$md5cod" "${arq##*.} " >> "$arq7"
            ext="${arq##*.}"
            ###### Fim Criação
            
            progresso=$(echo "scale=2; ($i/$qtd_arq1)*100" | bc)
            echo -ne "\\rProcessando: [$progresso%]  $(echo "$md5tmp" | awk '{print $2}') \\n"
        done
        cp "$arq5" "$arq6"
        sed -i "/$(echo '\/'"$remover"'\/')/d" "$arq6"
        for i in {01..12}
        do
            sed -i "s/-$(echo $i)-/-$(FUNMES $i $fmt )-/g" "$arq6"
        done
        sed -i "s/-/\//g" "$arq6"
        MSG "INFRM" "Criação dos arquivo 3"
        #### Criação do arquivo 3
        [[ -e "$arq3" ]] && MSG "INFRM" "O Arquivo 3 existe" || cat "$arq2" | awk '{print $1}' 1> "$arq3"
        MSG "INFRM" "Criação dos arquivo 4"
        ### Criação do arquivo 4
        [[ -e "$arq4" ]] && MSG "INFRM" "O Arquivo 4 existe" || cat "$arq3" | uniq -d 1> "$arq4"
    fi
}

SET_SUM(){
############
# TIPO:      FUNÇÃO DE ATRIBUIÇÃO
# FUNÇÃO:    Atribui valor a variável $CMD_SUM para que ela execute a verificação MD5/SHA
# ALTERAÇÃO: 15SET2024
# COMENTÁRIOS:  Funcionando dentro do esperado
#               
############
    local sum
    sum=$1
    if [[ -z "$sum" ]]; then
        ver_sum=$(whereis md5sum | awk '{print $2}')
        [[ -e "$ver_sum" ]] || MSG "ENDBAD" "O MD5 não está instalado no seu sistema."
    else
        ver_sum=$(whereis "$sum" | awk '{print $2}')
        [[ -e "$ver_sum" ]] || MSG "ENDBAD" "O Verificador $cmd_sum não está instalado no seu sistema."
    fi
    cmd_sum="$ver_sum"
}


FUNMES() {
############
# TIPO:      FUNÇÃO DE TRANSFORMAÇÃO
# FUNÇÃO:    Recebe o mês numérico e transforma em texto curto ou longo
# ALTERAÇÃO: 15SET2024
# COMENTÁRIOS:  Neste caso será sempre o $1 o formato e $2 o mês correspondente
#               NÃO FAZ SENTIDO TROCAR LINHA A LINHA, MANIA DE PHP. - Pode trocar no arquivo inteiro de uma vez              
############
    fmt="$2"
    linha="$1"

    case $linha in 
        01|1)
           MES="Janeiro"
        ;;
        02|2)
            MES="Fevereiro"
        ;;
        03|3)
            MES="Março"
        ;;
        04|4)
            MES="Abril"
        ;;
        05|5)
            MES="Maio"
        ;;
        06|6)
            MES="Junho"
        ;;
        07|7)
            MES="Julho"
        ;;
        08|8)
            MES="Agosto"
        ;;
        09|9)
            MES="Setembro"
        ;;
        10)
            MES="Outubro"
        ;;
        11)
            MES="Novembro"
        ;;
        12)
            MES="Dezembro"
        ;;   
    esac
    [[ "$fmt" == "longo" ]] || MES=$(echo $MES | cut -b 1-3)
    ########
    # Aqui pode entrar modos de se modificar a formatação (uppercase, minúsculo ou primeira maiúscula)
    ########
    echo "$MES"
}

CRIA_PASTAS_GERAL() {
############
# TIPO:      FUNÇÃO DE CRIAÇÃO
# FUNÇÃO:    Cria as pastas com AAAA/MM/DD ou AAAA/MMMM/DD
# ALTERAÇÃO: 15SET2024
# COMENTÁRIOS:  Leitura dos arquivos .arquivos5.tmp e .arquivos6.tmp
#               Recebe o parâmetro $2 de formato de data, se é LONGO, CURTO ou NORMAL        
############
#
#
# SIMPLIFICAÇÃO DE SCRIPT
#   TROCAR O LOOP POR: mkdir /usr/local/src/bash/{old,new,dist,bugs}
#   mkdir $destino/{ano1,ano2,ano3,ano4,anon}
#   depois mkdir $destino/ano1/{mes1,mes2,mes,3}
#
#
############ SCRIPT SIMPLIFICADO
#LER O ARQUIVO DE DATAS
# cat .arquivosX.tmp | print '{print $2}' | sed '/'/\//'
#mkdir `cat cpastas.tmp | sort | cut -b 1-4 | uniq`
#mkdir `cat cpastas.tmp | sort | cut -b 1-8 | uniq`
#mkdir `cat cpastas.tmp | sort | uniq
#### DECLARAÇÃO DE VARIÁVEIS
    local local=""
    local arq5=""
    local arq6=""
    local arq7=""
    local qtd_linhas=""
    local arq=""
    local local_destino=""
    local fmt
    
    #### FIM DECLARAÇÃO VARIÁVEIS

    local="$1"
    arq5="$local/.arquivos5.tmp"
    arq6="$local/.arquivos6.tmp"
    arq7="$local/.arquivos7.tmp"
    qtd_linhas=$(cat "$arq5" | wc -l)
    local_destino="$2"
    arq=$arq5
    fmt="$3"

    if [[ "$debug" -eq 1 ]]; then
        MSG "DBG" "DEBUG: Entrou em CRIA_PASTAS_GERAL$RESET"
        MSG "INFO" "Local arquivo: $RESET $local"
        MSG "INFO Caminho do .arquvios5: $RESET $arq5 - $INFO" $([[ -e "$arq5" ]] && echo "Arquivo existe $RESET" || echo "$ERROS Arquivo não existe$RESET")
        MSG "INFO" "Caminho do .arquvios6: $RESET $arq6 - $INFO" $([[ -e "$arq6" ]] && echo -e "$INFO Arquivo existe $RESET" || echo "$ERROS Arquivo não existe$RESET")
        MSG "INFO" "Formato de data: $RESET" $([[ -z "$3" ]] && echo "" )
        MSG "INFO" "Arquivo selecionado: $RESET $arq"
        MSG "INFO" "Quantidade de arquivos: $RESET $qtd_linhas"
    fi
#fazer o if para ler isso
arq="$arq6"
MSG "INFRM" "Criando pastas anos"
caminho=$(echo "$local_destino/"$(cat "$arq" | awk '{print $2}' | cut -b 1-4 | sort | uniq ) | sed "s, , \n$local_destino/,g")
echo -e "$caminho"
mkdir "$caminho"

#aqui tem que mudar de acordo com o tipo de formato número
#numero: 1-7
#curto: 1-8
#longo: 1-? # AQUI tem que capturar o que está entre barras 
corte="1-8"
MSG "INFRM" "Criando pastas meses"
caminho=$(echo "$local_destino/"$(cat "$arq" | awk '{print $2}' | cut -b "$corte" | sort | uniq ) | sed "s, , \n$local_destino/,g")
echo -e "$caminho"

#Aqui segue normal sem corte
MSG "INFRM" "Criando pastas dias"
caminho=$(echo "$local_destino/"$(cat "$arq" | awk '{print $2}' | sort | uniq ) | sed "s, , \n$local_destino/,g")
echo -e "$caminho"

MSG "INFRM" "Fim Criação das pastas"



    if [ -e "$arq" ]; then
        MSG "DBG" "$RESET Início do código de Criação de pastas"       
        
        ## LOCALIZAÇÃO DOS DADOS DENTRO DO ARQUIVO .arquivos5.tmp
        #cut -b 1-4     #->ano
        #cut -b 6-8     #->mês
        #cut -b 9-10    #->dia
        
        #Aqui a quantidade de linhas únicas do ano, será usado para ser o limite do loop abaixo
        qtd_pasta_anos=$(cat "$arq" | awk '{print $2}' | sort | cut -b 1-4 | uniq | wc -l)

        #CRIAÇÂO DA PASTA DOS ANOS
        for (( i=1; i<="$qtd_pasta_anos"; i+=1 )); do
            progresso=$(echo "scale=2; ($i/$qtd_linhas)*100" | bc)
            echo "Progresso: $progresso"
    #            [[ $i=1000 ]] && exit
            #Aqui vai aparecer linha a linha do arquivo
            linha_anos=$(cat "$arq" | awk '{print $2}' | sort | cut -b 1-4 | uniq | head -"$i" | tail -1)
            destcriar=$(echo "$local_destino/$linha_anos")
            qtd_pasta_meses=$(cat "$arq" | awk '{print $2}' | sort | cut -b 1-8 | uniq | grep "$linha_anos" | cut -b 6-8 | wc -l)
            if [[ "$debug" -eq 1 ]]; then
                MSG "DBG" "DEBUG: CRIAÇÃO DE PASTA ANOS - $qtd_total_criada\\$qtd_total $RESET"
                echo -e "Quantidade de pastas a criar: $qtd_total"
                echo -e "Quantidade de pastas a criadas: $qtd_total_criada"
                echo -e "Ano atual: $linha_anos"
                echo -e "Quantidade de meses: $qtd_pasta_meses"
                echo -e "*Criando pastas ano $linha_anos: $destcriar"
                #EXEMPLO: Meses do ano de 2020
                #echo -e "$DBGFIM DEBUG$RESET"
                echo -ne "\\rProcessando: [$progresso%]  $(echo "$destcriar")\\n"
            fi
            #Criação da Pasta
            #
            [[ -d "$destcriar" ]] || mkdir "$destcriar" && echo -e "$INFO Atenção: Pasta existe$RESET"

            if [[ -d "$destcriar" ]]; then 
                qtd_total_criada+=1
            else
                echo -e "$INFO Atenção: Pasta existe$RESET"
                qtd_total_criada+=1
            fi


            #INÍCIO DO CAMPO PARA CRIAÇÃO DO MÊS
            #CRIAÇÂO DA PASTA DOS MESES
            for (( j=1; j<="$qtd_pasta_meses"; j+=1 )); do
                #linha removida - aparecia "JA" ao invés "JAN ou JANEIRO" -cut estava indo até 7, correto até 8 (10JUL26)
                #tam_mes="6-8" #Adicionado para passar o mês corretamente, para corrigir posso procurar as barras (Ideias)
                linha_mes=$(cat "$arq" | awk '{print $2}' | sort | cut -b 1-8 | uniq | grep "$linha_anos" | cut -b 6-8 | head -"$j" | tail -1)
                #cat .arquivos6.tmp | awk '{print $2}'| grep "2011" | sort | uniq | cut -b 6-8 | uniq
                
                if [[ "$fmt"=="curto" ]]; then
                    destcriar="$local_destino/$linha_anos/$linha_mes"
                else
                    linha_mes_ext=$(FUNMES $linha_mes $fmt)
                    destcriar="$local_destino/$linha_anos/$linha_mes_ext"
                fi
                
                #IMPORTANTE - Essa variável $anomes ela irá filtrar dentro da lista do arquivo .arquivos5.tmp
                anomes="$linha_anos-$linha_mes"

                if [[ "$debug"  -eq 1 ]]; then
                    MSG "DBG" "CRIAÇÃO DE PASTAS MESES$RESET"
                    echo -e "Mês atual: $linha_mes"
                    echo -e "Quantidade de meses: $qtd_pasta_meses"
                    echo -e "*Criando pastas mês $linha_mes: $destcriar"
                    #EXEMPLO: Meses do ano de 2020
                    #echo -e "$DBGFIM DEBUG$RESET"
                    echo -ne "\\rProcessando: [$progresso%]  $(echo "$destcriar")\\n"
                fi
                #Verificando se a pasta exite e cria se não existir
                #
                [[ -d "$destcriar" ]] || mkdir "$destcriar" && echo "Pasta existe"
                #qtd_pasta_dias=$(cat "$arq" | awk '{print $2}' | grep "$linha_mes" | uniq | sort | uniq | wc -l)
                qtd_pasta_dias=$(cat "$arq" | awk '{print $2}' | grep "$linha_ano" | grep "$linha_mes" | uniq | sort | uniq | wc -l)
                
                for (( k=1; k<="$qtd_pasta_dias"; k+=1 )); do
                #linha_dias=$(cat "$arq" | awk '{print $2}' | grep "$linha_ano" | grep "$linha_mes" | cut -b 10-11 | sort | uniq | head -"$k" | tail -1)
                    linha_dias=$(cat "$arq" | awk '{print $2}' | grep "$linha_ano" | grep "$linha_mes" | uniq | sort | head -1 | tail -1 | cut -b "10-11")

                    if [[ "$fmt"=="curto" ]]; then
                        destcriar="$local_destino/$linha_anos/$linha_mes/$linha_dias"
                    else
                        destcriar="$local_destino/$linha_anos/$linha_mes_ext/$linha_dias"
                    fi

                    if [[ "$debug" -eq 1 ]]; then
                        MSG "DBG" "CRIAÇÃO DE PASTAS DIA$RESET"
                        echo -e "Dia atual: $linha_dias"
                        echo -e "Quantidade de dias: $qtd_pasta_dias"
                        echo -e "Criando pastas dia $linha_dias: $destcriar"
                    fi
                        ###Criação da pasta dia
                        #
                        mkdir "$destcriar"
                #SCRIPT PARA parar execução
                #[[ $i -eq 200 ]] && exit
                done
            done
            progresso=$(echo "scale=2; ($i/$qtd_linhas)*100" | bc)
            echo -ne "\\rProcessando: [$progresso%]  $(echo "$destcriar") \\n"
        done
    fi
    if [[ "$debug" -eq 1 ]]; then #EXEMPLO: Meses do ano de 2020
        MSG "DBG""FIM DEBUG"
    fi
}

CLASSIFICAR_MOVER() {
############
# TIPO:      FUNÇÃO DE TRANSFORMAÇÃO
# FUNÇÃO:    MOVE OS ARQUIVOS PARA AS PASTAS
# ALTERAÇÃO: 15SET2024
# COMENTÁRIOS:  Modifiquei a estrutura do loop para evitar que o arquivo fique repetindo com os arquivos duplicados.
#               Atenção com essa função com relação arquivos de texto dentro da pasta, caso o número de arquivos aumente o erro está aqui
#               VARIÁVEL ERRADA NA PARTE DE CONTROLE DE LOOP - PROBLEMA RESOLVIDO
#               18AGO2024 -> PRIMEIRA TENTATIVA: IGNORAR AS LINHAS DUPLICADAS - RESOLVIDO
#               31AGO2024 -> REORGANIZAÇÃO DO CÓDIGO - RESOLVIDO
############
    #### DEFININDO AS VARIÁVEIS
    local arq1=""
    local arq2=""
    local arq4=""
    local arq5=""
    local lugar=""
    local destino=""
    local destino_duplicado=""
    local arqmod=""
    local dest=""
    local local_dup=""
    local cod=""
    local qtd_mover=""
    local md5_mover=""
    local linha_mover=""
    local caminho_mover=""
    local arq_mover=""
    local linha_qtd=""
    #### FIM DEFINIÇÃO DE VARIÁVEIS

    arq1="$1/.arquivos.tmp"
    arq2="$1/.arquivos2.tmp"
    arq4="$1/.arquivos4.tmp"
    arq5="$1/.arquivos5.tmp"
    arq6="$1/.arquivos6.tmp"
    lugar="$1"
    destino="$2"
    destino_duplicado="$3"
    dest="$2"
    #LOCAL PARA onde vão os duplicados
    local_dup="$3"
    cod="$4"

    #### TESTES
    if [[ -e "$arq1" ]]; then
        MSG "INFO" "Arquivo .arquivos.tmp existe"
    else
        MSG "ERROS" "Arquivo não exite"
        echo "Erro. Saiu"
        MSG "ENDBAD"
    fi

    if [[ -e "$arq2" ]]; then
        MSG "INFO" "Arquivo .arquivos2.tmp existe"
    else
        MSG "$ERROS" "Arquivo não exite"
        echo "Erro. Saiu"
        MSG "ENDBAD"
    fi
    if [[ -e "$arq5" ]]; then
        MSG "INFO" "Arquivo .arquivos5.tmp existe"
    else
        MSG "ERROS" "Arquivo não exite"
        echo "Erro. Saiu"
        MSG "ENDBAD"
    fi
    #### BUG DETECTADO 14AGO2024
    #$2 não pode ser vazio
    if [[ -z "$2" ]]; then
        #echo "BUG permitindo não ter uma pasta, a fim de teste usará o caminho de origem"
       dest="$1"
    fi
    
    if [[ "$debug" -eq 1 ]]; then
        echo -e \
        "$DBG""DEBUG: ENTROU EM CLASSIFICAR_MOVER""$RESET"
        #EXEMPLO: Meses do ano de 2020
        echo "Arquivo de busca: $arq1"
        echo "Arquivo duplicado: $arq5"
        echo "Arquivo duplicado: $arq2"
        echo "Arquivo modificado: $arqmod"
        echo -e "$DBG""FIM DEBUG$RESET"
    fi

    #PAREI AQUI ESTAVA ESTAVA CONFERINDO O CÓDIGO ABAIXO PARA VER SER ELE VAI FUNCIONAR.
    #echo -e "$ERROS""CRIANDO CAMINHOS NÃO ENCONTRADOS$RESET" >> caminhos_novos.tmp


    qtd_mover=$(cat "$arq5" | wc -l)
    for (( i=1; i<="$qtd_mover"; i+=1 )); do

        md5_mover=$(cat "$arq5" | awk '{print $1}' | head -$i | tail -1)
        linha_mover=$(cat "$arq5" | nl | grep "$md5_mover" | awk '{print $1}') #aqui aparecem mais de uma linha
        if [[ -z "$fmt" ]]; then 
            caminho_mover=$(cat "$arq5" | awk '{print $2}' | sed 's/-/\//g' | head -"$i" | tail -1)
        elif [[ ! -z "$fmt" ]]; then
            caminho_mover=$(cat "$arq6" | awk '{print $2}' | head -"$i" | tail -1)
        fi
        caminho_mover="$dest/$caminho_mover"
        arq_mover=$(cat "$arq1" | head -"$i" | tail -1)
        linha_qtd=$(cat "$arq5" | nl | grep "$md5_mover" | awk '{print $1}' | wc -l)
            
        if [[ "$debug" -eq 1 ]]; then
            echo -e "$DBG""DEBUG: ENTROU EM CLASSIFICAR_MOVER""$RESET" \
            "MD5 a MOVER: $md5_mover" \
            "Linha a se mover: $linha_mover" \
            "Quantidade: $linha_qtd" \
            "Destino a mover os arquvios: $caminho_mover" \
            "Destino a mover os arquivos duplicados: $local_dup" \
            "Arquivo a se mover: $arq_mover" \
            "$DBG FIM DEBUG$RESET"
        fi
        ####### ATENÇÃO
        # Essa parte do script é para prevenir caso o outro script de criação de pasta não funcione como esperado, como pode acontecer por isso ser um script beta.
        # Mesmo que se resolva, deixe isso aqui não tire!
        # 
        #
        # 11AGO2024 - Adicionei o código abaixo para detectar arquivos duplicados e fazer o renomeio caso os nomes sejam iguais
        # Não funciona ainda.
        #

        #######
        if [[ -e "$arq_mover" ]]; then 
            if [[ "$linha_qtd" -gt 1 ]]; then
                #arq_original=$($md5_mover)
                    for (( j=1; j<="$linha_qtd"; j+=1 )); do
                        linha_repetido=$(cat "$arq2" | nl | grep "$md5_mover" | head -"$j" | tail -1 | awk '{print $1}')
                        if [[ "$j" -eq 1 ]]; then
                            arq_repetido1=$(cat "$arq1" | head -"$linha_repetido" | tail -1)
                            arq_repetido1_nome=$(echo "$arq_repetido1" | sed 's:.*/::')
                            if [[ -e "$arq_repetido1" ]]; then
                                if [[ -e "$caminho_mover" ]]; then
                                    echo "Movendo para $caminho_mover"
                                    #
                                    mv "$arq_repetido1" "$caminho_mover"
                                else
                                    RECRIAR_PASTA "$caminho_mover"
                                    echo "Movendo para $caminho_mover"
                                    #
                                    mv "$arq_repetido1" "$caminho_mover"
                                fi
                            else
                                echo "ERRO: O arquivo não exite"
                                #AQUI FAZ MAIS ALGUMA COISA? POR ENQUANTO NÃO.
                            fi
                            echo "Arquivo Original: $arq_repetido1"
                            echo "Movendo: $arq_repetido1"
                        else
                            arq_repetidon=$(cat "$arq1" | head -"$linha_repetido" | tail -1)
                            arq_repetidon_nome=$(basename "$arq_repetidon")
                            arq_repetido1_nome=$(basename "$arq_repetido1")
                            echo "\"$arq_repetido1_nome\" é igual a \"$arq_repetidon_nome\""
                            if [[ "$arq_repetido1_nome" = "$arq_repetidon_nome" ]]; then
                            #Só funciona com .jpg kKKKkkkkkKKkKKKKK
                                echo "Furunfou - Movendo arquivo duplicado com nome igual"
                                extarq=${arq_repetidon_nome##*.}
                                dest_dup="$local_dup""/${arq_repetidon_nome%.$extarq}($j).$extarq"
                                echo "cp  $arq_repetidon $dest_dup"
                                mv  "$arq_repetidon" "$dest_dup/"
                                #PAUSE
                            fi
                            local resto=$(expr "$j" % 2)
                            local cor=""
                            [[ $resto -eq 0 ]] && cor=$INFO || cor=$DBG
                            echo -e "$cor Arquivo cópia - $j: $arq_repetidon $RESET
                            $cor Movendo: \"$arq_repetidon\" $local_dup $RESET"
                            mv "$arq_repetidon" "$local_dup/"
                            #PAUSE
                        fi
                    done
                #PAUSE
            else
                if [[ -d "$caminho_mover" ]]; then
                    mv "$arq_mover" "$caminho_mover/"
                else
                    RECRIAR_PASTA "$caminho_mover"
                    #echo "
                    mv "$arq_mover" "$caminho_mover/"
                    #"
                fi
            fi
        else
            echo "Arquivo não existe"
            #PAUSE
        fi
    done
}

APAGAR_ARQUIVOS() {
############
# TIPO:      FUNÇÃO DE TRANSFORMAÇÃO
# FUNÇÃO:    Apaga os arquivos temporários
# ALTERAÇÃO: 15SET2024
# COMENTÁRIOS: Desabilitado por motivo de testes
#
############
    MSG "DBG" "Valor do parâmetro: $1"
    MSG "DBG" "Início apagar arquivos."
    #./desfazer.sh
    MSG "DBG" "Impedido de fazer para intuito de teste"
}

VRF_SO() {
############
# TIPO:      FUNÇÃO DE VERIFICAÇÃO SO
# FUNÇÃO:    Verifica o SO e configura o gerenciador de pacote
# ALTERAÇÃO: 09JUL2026
# COMENTÁRIOS: 
#
############
case "$ID_LIKE" in
    "debian")
        COMMAND="apt"
        ;;
    "arch")
        COMMAND=""
        ;;
    "fedora")
        COMMAND="dnf"
        ;;
    "suse")
        COMMAND="zypper"
        ;;
esac
MSG "INFRM" "Sua distro é $NAME e seu gerenciador é $COMMAND"
}

VRF_COMMAND() {
############
# TIPO:      FUNÇÃO DE VERIFICAÇÃO DE COMANDOS INSTALADOS
# FUNÇÃO:    Verifica os pacotes necessários estão instalados
# ALTERAÇÃO: 09JUL2026
# COMENTÁRIOS:
#               verify - Imagemagick
#               md5sum
#               bc sudo apt-get install bc
#
############
# Assim se executa o comando: $COMMAND update
echo "Verificando se o pacote identify está instalado." #Ele funciona testando se o arquivo jpg está corrompido
PCT=("identify" "md5sum" "sha512sum" "sha256sum") 
PCT_SRC=("imagemagick" "coreutils" "coreutils" "coreutils")
which $1
if [ $? -eq 0 ]; then
    MSG "INFORM" "O $1 está instalado"
else
    MSG "ENDBAD" "O $1 Não está instalado"
    MSG "ENDBAD" "Instale o pacote para prosseguir"
    exit 1
fi

}
FILTRA_LISTA() {
############
# TIPO:      FUNÇÃO DE TRANSFORMAÇÃO
# FUNÇÃO:    Recebe a lista dos arquivos e exclui extensões/arquivos importantes
# CRIAÇÃO:   09JUL2026
# COMENTÁRIOS: Função que evita bug de mover arquivos, diretórios importantes
#
############

arq1=$1
qtd_arq1=$(wc -l < "$arq1")
remover=$(basename "$local_destino_duplicado")
MSG "INFRM" "QTD Antes: $qtd_arq1"
sed -i "/$(echo '\/'"$remover"'\/')/d" "$arq1"
sed -i "/.tmp/d" "$arq1"
sed -i "/.sh/d" "$arq1"
qtd_arq1=$(wc -l < "$arq1")
MSG "INFRM" "QTD Depois: $qtd_arq1"
#AQUI VAI ENTRAR O CÓDIGO PARA CHAMAR A FUNÇÃO DE TIRAR ARQUIVOS CORROMPIDOS?
if [[ "$badfile" -ne "1" ]];#AQUI ENTRA UM IF SE QUER TIRAR O ARQUIVO CORROMPIDO
        then
            BADFILE_TEST $arq1
            qtd_arq1=$(wc -l < "$arq1") #QTD DEPOIS DE TIRAR OS CORROMPIDOS
        fi #FIM DO IF PARA TIRAR ARQUIVO CORROMPIDO
}
######### FIM DAS FUNÇÕES PERSONALIZADAS
##################################
#           TESTES
##################################
#Impede que seja utilizado como usuário ROOT - Apague isso com cautela.
[[ "$UID" -eq 0 ]] && { echo "O programa não pode ser executado como root"; exit 1; }

##################################
#          PARÂMETROS
##################################

##################### Entrada de parâmetros do script
# Movi para o final do arquivo dia 04AGO2024, para que todo o script rode e depois selecione as opções 
[[ "$debug" -eq 1 ]] && MSG "INFRM" "(PARÂMETROS) - ENTRADA DE PARÂMETROS"
if [ -z "$1" ]; then
    echo "$prg $vers:"
    echo -e \
    "   $DBG Debug$RESET ativado automáticamente
        As menságens em$(echo -e "$DBG laranja$RESET") são saídas do script.
        Use o parâmetro$(echo -e "$INFO -h ou --help$RESET") para exibir as opções
        O script funciona apenas no Ubuntu e derivados
        Dados do Sistema: $(echo -e "$DBG$NAME $VERSION $(uname -r)")$RESET
    "
#TESTANDO FUNCAO QUE ESTOU TRABALHANDO
    exit 0
fi
##### ERRO NOS PARÂMETROS
#DUPLICADO -u E O -d
for a in "${!entradas[@]}";
do
    if [[ ! ${entradas[$a]} = " " ]]; then
        if [[ "$debug" -eq 1 ]]; then
            MSG "DBG" "(PARÂMETROS):Valor de entrada $a: ${entradas[$a]}"
        fi
        case ${entradas[$a]} in 
            -a|--apagar) #Aqui somente apaga os arquivos temporários - Não funciona (10JUL2026)
                echo 'Realmente deseja apagar os arquivos temporários?'
                echo -e "\e[5;31mEssa ação não poderá ser desfeita.$RESET"
                echo -en "\e[1mApagar arquivos temporários [S/N]: $RESET"
                read -nr 1 resp
                resp=${resp^^}
                if [ "$resp" = "S" ]; then
                    apagar_arquivos "$resp"
                fi
                exit 0
            ;;
            -h|--help)
                RELP #AJUDA
                exit 0
            ;;
            -v|--version)
                echo 'Versão: ' #Versão
                echo "$prg" "$vers"
                exit 0
            ;;
            --debug)
                echo "Modo debug ativado"
                debug=1;
            ;;
            -u|--mudar)
                #CRIA as pastas
                #Função CRIAPASTAS $1-LOCAL do .arquivos5.tmp $2 - Formato
                # 10JUL2026 - MELHORAR ESSA OPÇÃO, UM NOME NOVO PARA APENAS FORMATAR O NOME DA PASTA MÊS LONGO OU MÊS CURTO
                
                (( a+=1 ))
                param="${entradas[$a]}"
                echo $param
                case $param in
                    l|long|longo)
                        fmt=longo
                    ;;
                    c|cur|curto)
                        fmt=curto
                    ;;
                    *)
                        if [[ -z $param ]]; then
                            fmt=""
                        else
                            MSG ENDBAD "O formato $param não foi encontrado"
                        fi
                    ;;
                esac
            ;;
            -o|--copy)
            #Forma para não mover os arquivos duplicados copiar.
                if [ $debug -eq 1 ]; then
                    execucao='cp'
                else
                    execucao='mv'
                fi
                exit
            ;;
            -l|--local)
                #LOCAL DE VERIFICAÇÃiO DOS ARQUIVOS
                #Aqui será o local que o comando find irá criar o arquivo: .arquvios.tmp
                ((a+=1))
                local=${entradas[$a]}
                if [ "$debug" = "1" ]; then
                    MSG "DBG" "(PARÂMETROS): Valor de \$local - $local"
                fi
                if [[ -z "$local" ]]; then
                    MSG "ENDBAD" "O local de verificação não pode ser vazio"
                else
                    if [[ -d "$local" ]]; then
                        if [[ "$local"=='./' ]]; then
                            local="$PWD"
                            MSG "INFRM" "$local - passado como './' torcando para \$PWD"
                        fi
                        MSG "INFRM" "$local - Encontrado"
                    else
                        MSG ENDBAD "O diretório especificado: $local - No Existe. Especifique um diretório válido"
                    fi
                fi
            ;;
            -d|--destino)
                param="${entradas[$a]}"
                (( a+=1 ))
                local_tmp="${entradas[$a]}"
                [[ -e "$local_tmp" ]] || CRIA_DESTINO "$local_tmp" "$param"
                unset $local_tmp
            ;;
            -m| --mover)
                param="${entradas[$a]}"
                echo "Entrou Mover"
                (( a+=1 ))
                local_tmp="${entradas[$a]}"
                CRIA_DESTINO "$local_tmp" "$param"
                unset $local_tmp
            ;;
            -t|--tipo)
                (( a+=1 ))
                prm="${entradas["$a"]}"
                SET_SUM "$prm"
                MSG "INFRM" "Verificador selecionado $cmd_sum"
            ;;
            -y|--yes)
                ignore='S'
                MSG "INFRM" "Ignorando as perguntas"
            ;;
            -b|--badfile)
                (( a+=1 ))
                MSG "INFRM" "Verificando arquivos corrompidos (BADFILES)" #Padrão 0
                badfile='1'
            ;;
            *)
            if [[ ! "${entradas[$a]}" = " " ]];then
                result=$(echo "$a % 2" | bc)
                if [[ "$a" -eq 0 ]]; then
                    MSG "ENDBAD" "O parâmetro ""${entradas[$a]}"" é um comando inválido"
                fi
                if [[ "$result" -eq 0 ]]; then 
                    MSG "ENDBAD" "O parâmetro ""${entradas[$a]}"" é um comando inválido"
                fi
            fi
            #Desabilitar ele para que inicie, pois está saíndo do programa
            #A mensagem de erro acima dará o tempo todo
            #ignore isso
            #exit
            ;;
        esac
    fi
done
[[ "$debug" -eq 1 ]] && MSG "INFRM" "(PARÂMETROS) - FIM ENTRADA DE PARÂMETROS"
##################### Entrada de parâmetros do script - FIM

#Primeira verificação é se as variáveis foram setadas
#Segunda verificação é se existem os arquivos temporários

################
#   VERIFICAÇÃO DE VARIÁVEIS
################
MSG "INFRM" "(VARIAVEIS) - INÍCIO VERIFICAÇÃO DE VARIÁVEIS";
[[ -e "$cmd_sum" ]] || cmd_sum="/usr/bin/md5sum"
[[ -z "$local_destino" ]] && local_destino="$local"
[[ -z "$local_destino_duplicado" ]] && local_destino_duplicado="Vazio"

if [[ "$debug" -eq 1 ]]; then
    MSG "DBG" "(VARIAVEIS) - Variáveis setadas: 
        Origem - \$local: $local
        Verificador - \$cmd_sum: $cmd_sum
        Destino dos arquivos - \$local_destino: $local_destino
        Destino dos duplicados - \$local_destino_duplicado: $local_destino_duplicado
        Detectando arquivos corrompidos - \$badfile:  $badfile" #aparecenada
fi

#### Isso aqui é para saber a quantidade de linhas do arquvio e fazer barra de progresso. - Descontinuado
#qtd_total=$(cat $(echo "$local/.arquivos.tmp" ) | wc -l)
#qtd_total=$(cat "$local/.arquivos.tmp" | wc -l)
#qtd_total_criada=0
[[ "$debug" -eq 1 ]] && MSG "INFRM"  "(VARIAVEIS) - FIM VERIFICAÇÃO DE VARIÁVEIS"
################ FIM VERIFICAÇÃO DE VARIÁVEIS

##################################
#             MAIN
##################################
[[ "$debug" -eq 1 ]] && MSG "INFRM" "(MAIN) - EXECUÇÃO DO SCRIPT"

##################### CRIAÇÃO DOS .arquivos*.tmp
#.arquivos  - Lista Bruta
#.arquivos2 - Lista MD5
#.arquivos3 - Lista MD5 pura
#.arquivos4 - Lista MD5 duplicados
#.arquivos5 - Lista MD5 com data
#.arquivos6 - Lista MD5 com formatos
#CRIA_LISTAS $1=Origem $2=MD5/SHA $3=Formato

CRIA_LISTAS "$local" "$cmd_sum" "$fmt" "$local_destino_duplicado"


########## FUNLÇÃO CRIAR PASTAS
###### VARIÁVEIS UTILIZADAS
### $local -> LUGAR DE BUSCA DOS ARQUIVOS
### $fmt -> FORMATO DE DATA. NUMÉRICO, EXTENSO (CURTO E LONGO)
#
CRIA_PASTAS_GERAL "$local" "$local_destino" "$fmt"

#####

if [[ "$ignore" = "S" ]]; then
    CLASSIFICAR_MOVER  "$local" "$local_destino" "$local_destino_duplicado" "$execucao"
else
    echo "Deseja mover os arquivos para essas pastas? [S/N]"
    read -r resp
    resp=${resp^^}

    if [[ "$resp" = "S" ]]; then
        echo "respondeu Sim"
        ########## FUNLÇÃO CLASSIFICAR_MOVER
        ###### VARIÁVEIS UTILIZADAS
        # $local -> LUGAR DE BUSCA DOS ARQUIVOS
        ### teste
        #CRIA_PASTAS_GERAL Local Destino (Cópia o Mover)
        CLASSIFICAR_MOVER  "$local" "$local_destino" "$local_destino_duplicado" "$execucao"
    else
        echo "respondeu Não"
        exit
    fi
fi

echo "O script terminou a execução"
echo "Deseja apagar os arquivos temporários? [S/N]"
read -r resp
resp=${resp^^}
if [ "$resp" = "S" ]; then
    APAGAR_ARQUIVOS
#    exit
else
    echo "Muito obrigado por utilizar o $prg $vers"
fi
######################################## NOTA 1 - BUG ENCONTRADO
#Apresentando problema nos arquivos da linha 6089 e 7156 por conta do fato deles serem arquivos de texto e com isso estão lendo o conteúdo dele. posso tentar resolver se eu tirar a variável e colocar o comando dentro da outra variável, com isso pode resolver.
#Isso faz com que o maior espaço dê valores astronômicos que passa a dar erro quando precisar mover algum arquivo mais abaixo.
#Enquanto não dá certo, podemos ignorar esse erro? Para testes sim

#19JUN2024 - Fiz a alteração do comando "cat" para "echo" - Resolveu
######################################## FIM - NOTA 1

######################################## NOTA 2 - COISAS EXTRAS
###Preciso decidir como tratar os arquivos duplicados, pois tem dois modos
# 1 - Mesmo nome, mas com MD5 diferente
# 2 - Nome diferente, mas com MD5 igual
# 3 - Mesmo nome e com MD5 igual.
#RESOLVIDO - A função separa arquivos com nomes iguais
######################################## FIM - NOTA 2

######################################## NOTA 3 - COMENTÁRIOS SOBRE ARQUIVOS TEMPORÁRIOS
# + .arquivos.tmp
#   - Resultado do find com a retirada da pasta duplicados e também dos arquivos de busca
# + .arquivos2.tmp
#    - Resultado do MD5 com caminho
# + .arquivos3.tmp
#    - Só os códigos MD5
# + .arquivos4.tmp
#    - arquivos duplicados
# + .arquivos5.tmp
#    - Código MD5 com data
# + .arquivos6.tmp
#    - Código MD5 com data formatada curta ou longa
#       IMPORTANTE: .arquivos2.tmp ele não pode ser usado para buscar o caminho do arquivo senão vai dar problema na hora de extrair o conteúdo, por isso eu coloquei um novo arquivo com MD5 e data para facilitar a busca. adicionei numa terceira coluna a data de criação do arquivo, mas eu irei retirar e criar um novo arquivo de texto.
###########################################


#Exibir a linha 2 do .arquivo2.tmp
#sed -n 2p .arquivo2.tmp

#Imprimir n linhas
#sed '2q' .arquivos2.tmp
#Exibe só o nome do arquivo
#cat .arquivos2.tmp | awk '{print$2}' | sed 's:.*/::'

########################################  IDEIAS A IMPLEMENTAR
# 1 - Ao se obter a quantidade dos arquvios do disco, a depender da quantidade será necessário dividir a lista em duas (se par), 3 ou mais (de acordo com a divisibilidade) para acelerar a criação do .arquivos2.tmp.
# 2 - Descontinuar a utilização de arquvios de texto para fazer as listas de arquivos
# 3 - Dar unset (unset variável) nas variáveis que não usa para economiar memória
#In case identify is missing, here is how to install it in Ubuntu: sudo apt install imagemagick --no-install-recommends


#Apagar pastas vazias
##### qtd=$(cat saida.tmp)
#####for (( i=1; i<="$qtd"; i+=1 )); do  rm -d "$(cat saida.tmp | head -"$i" | tail -1)" ; done

#Cria diretamente a lista com Md5 completa
####find . -type f -exec md5sum {} \; # Cria o arquivo .arquivos2.tmp -> Lista com MD5
#Criar uma função para ler linha a linha um arquivo.
