#!/usr/bin/env bash
######################################################################
#   fpiokfdaspófisnhjifvshnǘsnǘ0oasni0vasdnjvíoasnvóisnmvóasnvónvsśovnśdnvśvós
# AUTOR:        Higlux Morales
# EMAIL:        higluxmorales@gmail.com
# PROGRAMA:     duplicados.sh
# LICENÇA:      GPL 3
# VERSÃO:       1.0 Beta
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
######################################################################

#ESSE CÓDIGO ELE FAZ O SCRIPT SAIR QUANDO DÁ ERRO
#set -ex #Não dá por enquanto.

##################################
#           VARIÁVEIS
##################################
readonly prg='Duplicados'
readonly vers='1.0 Beta'
#Por padrão deixar isso ligado
declare debug=1
declare local_destino=""
declare local_destino_duplicado=""

entradas=($*)
readonly RESET='\e[0m'      #Volta o texto ao nomal
readonly DBG='\e[1;33m'     #Laranja
readonly INFO='\e[1;36m'    #Ciano # Informações
readonly ERROS='\e[1;31m'   #Vermelho
readonly EXIST='\e[1;32m'   #VERDE
##################################
#           FUNÇÕES
##################################


#################
# INÍCIO FUNÇÃO PERSONALIZADA
#################

RELP() {
                    echo "Opções disponíveis:           
                -h --help      Exibe ajuda
                -l --local     Local de verificação dos arquivos (Requerido)
                -f --formatos  Formatos de verificação
                -t --tipo      Tipo de verificação (MD5 padrão)
                -o --copy      Execução alternativa (Mover arquivo duplicado padrão)
                -a --apagar    Deleta os arquivos temporários
                -v --version   Versão do aplicativo
                -c --create    Cria a pasta a partir das datas
                                para mudar o formato adicione 
                                (c - Curto Ex. JAN) (l - Longo Ex. Janeiro).
                                Sem parâmetro as datas serão numéricas
                -debug         Exibe debug do código
                -m --mover     Pasta para onde irá mover ou copiar os arquivos duplicados
                -d --destino    Destino dos arquivos (Requerido)
                
                $prg - $vers
                "
}

SET_SUM(){
#################
# FUNÇÃO PERSONALIZADA
# AÇÃO: ATRIBUI VALOR A VARIÁVEL $CMD_SUM PARA QUE ELA EXECUTE A VERIFICAÇÃO MD5/SHA OU OUTRA
#################
    local sum
    sum=$1
    if [[ -z "$sum" ]]; then
        ver_sum=$(whereis md5sum | awk '{print $2}')
        [[ -e "$ver_sum" ]] || END_BAD "O MD5 não está instalado no seu sistema."
    else
        ver_sum=$(whereis "$sum" | awk '{print $2}')
        [[ -e "$ver_sum" ]] || END_BAD "O Verificador $cmd_sum não está instalado no seu sistema."
    fi
    cmd_sum="$ver_sum"
}

################# FUNÇÕES DE SAÍDA
END_BAD(){
    local msg
    msg=$1
    echo -e "$ERROS""[ERRO] - $msg""$RESET"

    echo "Muito obrigado por usar $prg $vers"
    exit 1
}

END_GOOD() {
    echo "Muito obrigado por usar $prg $vers"
    exit 0
}

################# FUNÇÕES DE INFORMAÇÃO
INFRM(){
    local msg
    msg=$1
    [[ -z $msg ]] && echo -e "$ERROS""[ERRO] - INFRM requer uma mensagem""$RESET" \ exit;

    echo -e "$INFO" "[INFORMAÇÃO] - ""$msg$RESET"
}

DBG(){
    local msg
    msg=$1
    [[ -z $msg ]] && echo -e "$ERROS""[ERRO] - DBG requer uma mensagem""$RESET" \ exit;
    echo -e "$DBG[DEBUG]$RESET - $msg"
}

################# FUNÇÕES DE CRIAÇÃO

CRIA_DESTINO() {
#Destino dos arquivos, pode ser um caminho completo ou um nome, Obrigatório
    #Primeiro testa pra ver se é vazio ou se a próxima string é um - do próximo parâmetro

    ####### DECLARAÇÃO DE VARIÁVEIS
    local nz
    local origem
    local dest #para onde irão os arquivos
    local dest_dup #para onde irão os duplicados
    dest="$2"
    origem="$1"
    echo "$dest"
    if [[ -z "$2" ]]; then
        END_BAD "O local de destino não pode ser vazio"
    else
        nz=$(echo "$dest" | cut -b 1)
        echo "$nz"
        if [[ "$nz" = "\-" ]]; then
            END_BAD "O local de destino não pode ser vazio"
        fi
    fi

    #Segundo testa para ver se a entrada ela é um diretório ou um nome
    if [[ -d "$1" ]]; then
        local destino="$1"
    else
        #Aqui insere o caminho antes do nome criando o caminho completo
        local destino="$local/$1"
    fi
    
    if [ "$debug" = "1" ]; then
        echo -e "$DBG Debug: Entrou em CRIAR_DESTINO $RESET
        Entrada: $1
        Destino: $destino
                    "
    fi

    if [ -z "$destino" ]; then
        echo  -e "$ERROS ERRO: O local de destino não pode ser vazio$RESET"
        exit
    else
        if [ -d "$destino" ]; then
            echo -e "$INFO Usando diretório válido:$RESET $destino"
        else           
            if [ -d "$destino" ]; then
                echo -e "$INFO Diretório $destino existe $RESET"
            else   
                echo -e "$INFO""Diretório $destino, não exite $RESET"
                read -p "Deseja Criar? [S/N]" resp
                resp=${resp^^} #passando o conteúdo para uppercase
                if [ "$resp" = "S" ]; then
                    echo -e "$INFO Criando $destino:$RESET"
                    mkdir "$destino"
                else
                    echo -e "$ERROS""Insira um diretório válido$RESET"
                    END_BAD
                fi
            fi
        fi
        echo "Usando destino: $destino"
    fi
    echo "$param"
    if [[ "$param" == "-d" ]]; then
        local_destino="$destino"
    elif [[ "$param" == "-m" ]]; then
        local_destino_duplicado="$destino"
    fi
    echo "$local_destino"
    echo "$local_destino_duplicado"
}

PAUSE(){
#################
# FUNÇÃO PERSONALIZADA
# AÇÃO: Para função e exibe a msg na tela
#################
    read -srp -n 1 "Press any key to continue . . ."
    echo ""
}

RECRIAR_PASTA() {
#################
# FUNÇÃO PERSONALIZADA - TEMPORÁRIA
# AÇÃO: RECRIA PASTAS QUE NÃO FORAM CRIADAS POR ALGUM MOTIVO PELA FUNÇÃO CRIAR_PASTAS
#################
    #DECLARAÇÃO DE VARIÁVEIS
    local log=""

    log="./RECRIAR_PASTA.log"

    if [[ "$debug" -eq 1 ]]; then
        echo -e \
        "$DBGDEBUG: ENTROU EM RECRIAR_PASTA$RESET"
        #EXEMPLO: Meses do ano de 2020
        echo "$1 não existe, vou criar"        
        echo -e "$DBGFIM DEBUG$RESET"
    fi
}

CRIA_LISTAS(){
#################
# FUNÇÃO PERSONALIZADA - CRIAR LISTAS
# AÇÃO: CRIA OS ARQUIVOS ABAIXO:
#.arquivos.tmp  - Lista Bruta
#.arquivos2.tmp - Lista MD5
#.arquivos3.tmp - Lista MD5 pura
#.arquivos4.tmp - Lista MD5 duplicados
#.arquivos5.tmp - Lista MD5 com data
#################

    ############ DECLARAÇÃO DE VARIÁVEIS
    local arq1
    local arq2
    local arq3
    local arq4
    local arq5

    local arq1_exist
    local arq2_exist
    local arq3_exist
    local arq4_exist
    local arq5_exist

    local qtd_arq1
    local qtd_arq2
    local qtd_arq3
    local qtd_arq4
    local qtd_arq5

    local dest_dup
    local fmt
    local origem
    dest_dup="$4"
    ############ FIM DECLARAÇÃO DE VARIÁVEIS
    
    ######## BLOQUEIO PARA NÃO ENTRAR VALOR VAZIO
    [[ -z "$1" ]] && END_BAD "Origem não pode ser vazio"
    [[ -z "$2" ]] && INFRM "Usando o MD5 como verificador"
    ######## FIM BLOQUEIO PARA NÃO ENTRAR VALOR VAZIO
    
    ############ ATRIBUIÇÃO DE VARIÁVEIS
    origem="$1"
    arq1="$origem"/.arquivos.tmp
    arq2="$origem"/.arquivos2.tmp
    arq3="$origem"/.arquivos3.tmp
    arq4="$origem"/.arquivos4.tmp
    arq5="$origem"/.arquivos5.tmp
    
    ############ FIM DECLARAÇÃO DE VARIÁVEIS

    ############ TESTE DE VARIÁVEIS
    arq1_exist=$([[ -e $arq1 ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq2_exist=$([[ -e $arq2 ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq3_exist=$([[ -e $arq3 ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq4_exist=$([[ -e $arq4 ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    arq5_exist=$([[ -e $arq5 ]] && echo "[$EXIST EXISTE $RESET]" || echo "[$ERROS NÃO EXISTE $RESET]")
    ############ FIM TESTE DE VARIÁVEIS


  if [[ "$debug" -eq 1 ]]; then
        echo -e "$DBG""Debug: Entrou na função CRIAR_LISTAS com os dados:$RESET
        \$arq1: $arq1 - $arq1_exist - Lista Bruta
        \$arq2: $arq2 - $arq2_exist - Lista MD5
        \$arq3: $arq3 - $arq3_exist - Lista MD5 pura
        \$arq4: $arq4 - $arq4_exist - Lista MD5 duplicados
        \$arq5: $arq5 - $arq5_exist - Lista MD5 com data
        \$cmd_sum: $cmd_sum - Formatos a serem buscados"
    fi

    ######## SAÍDA PARA NÃO ENTRAR VALOR VAZIO
    if [[ -z "$origem" ]]; then 
        END_BAD "Origem não pode ser vazio"
    fi
   
    echo "$3"

    ######## VERIFICAÇÃO SE O ARQUIVO EXISTE
    if [[ ! -e "$arq1" ]]; then
        INFRM "Criação do .arquivos.tmp"

        #Aqui cria a lista de arquvios
        find "$origem" -type f > "$arq1"
        qtd_arq1=$(wc -l < $arq1)

        #CÓDIGO PARA REMOVER A PASTA INDICADA COMO DUPLICADO DO BANCO DE BUSCA
        #Remove o nome da pasta - nome_pasta_duplicados = duplicados estava definido como padrão

        remover=$(basename "$local_destino_duplicado")
        echo "A remover $remover"

        #Remove a pasta para onde os arquivos serão movidos
        INFRM "QTD Antes: $qtd_arq1"
        sed -i "/$(echo '\/'$remover'\/')/d" "$arq1"
        sed -i "/.tmp/d" "$arq1"
        qtd_arq1=$(wc -l < $arq1)
        INFRM "QTD Depois: $qtd_arq1"
    fi
    INFRM "FIM da ciração do .arquivos.tmp"

    
    if [[ "$debug" -eq 1 ]]; then
        INFRM "INÍCIO CRIAÇÃO DA LISTA MD5"
        DBG "Variáveis usadas:
    Local arquivo: $origem
    Comando usado: $cmd_sum
    Quantidade total de arqvivos: $qtd_arq1
    Caminho do .arquvios2: $arq2
    Caminho do .arquvios5: $arq5"
    DBG "FIM DEBUG"

    fi

    if [ -e "$arq2" ]; then
       INFRM "O arquivo .arquivos2.tmp de busca existe"
        progresso=1
    else
        INFRM "Criação dos arquivos 2 e 5"
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
            echo "$md5cod" "$exitftmp" >> "$arq5"

            ###### Fim modificação
            echo "$saidateste" >> "$arq2"
            progresso=$(echo "scale=2; ($i/$qtd_arq1)*100" | bc)
            echo -ne "\\rProcessando: [$progresso%]  $(echo "$md5tmp" | awk '{print $2}') \\n"
        done

        INFRM "Criação dos arquivos 3 e 4"
        #### Criação do arquivo 3
        [[ -e "$arq3" ]] && INFRM "O Arquivo 3 existe" || cat "$arq2" | awk '{print $1}' > "$arq3"

        ### Criação do arquivo 4
        [[ -e "$arq4" ]] && INFRM "O Arquivo 4 existe" || sort "$arq3" | uniq > "$arq4"
    fi
}

##MES
FUNMES() {
#################
# FUNÇÃO PERSONALIZADA
# AÇÃO: ENTRADA DE PARÂMETRO TEM QUE SER ASSIM: FUNMMES formato mes
#       Neste caso será sempre o $1 o formato e $2 o mês correspondente
#################
    #NÃO FAZ SENTIDO TROCAR LINHA A LINHA, MANIA DE PHP. - Pode trocar no arquivo inteiro de uma vez
    #echo "ENTROU NA FUNÇÃO mes! com os dados: $1              2: $2"
    if [[ "$debug" -eq 1 ]]; then
        echo -e "$DBG""Debug: Entrou na função mês com os dados:
        \$1: $1
        \$2: $2 $RESET"
    fi
    if [[ "$1" = "longo" ]]; then
        long=true
    else
        long=false
    fi
    echo "Saída de long: "$long
    exit
    case $2 in 
        01)
           [[ "$long" = false ]] || MES="Janeiro" && MES="Jan"
        ;;
        02)
            [[ "$long" = false ]] || MES="Fevereiro" && MES="Fev"
        ;;
        03)
            [[ "$long" = false ]] || MES="Março" && MES="Mar"
        ;;
        04)
            [[ "$long" = false ]] || MES="Abril" && MES="Abr"
        ;;
        05)
            [[ "$long" = false ]] || MES="Maio" && MES="Mai"
        ;;
        06)
            [[ "$long" = false ]] || MES="Junho" && MES="Jun"
        ;;
        07)
            [[ "$long" = false ]] || MES="Julho" && MES="Jul"
        ;;
        08)
            [[ "$long" = false ]] || MES="Agosto" && MES="Ago"
        ;;
        09)
            [[ "$long" = false ]] || MES="Setembro" && MES="Set"
        ;;
        10)
            [[ "$long" = false ]] || MES="Outubro" && MES="Out"
        ;;
        11)
            [[ "$long" = false ]] || MES="Novembro" && MES="Nov"
        ;;
        12)
            [[ "$long" = false ]] || MES="Dezembro"  && MES="Dez"
        ;;   
    esac
    echo "$MES"
}

CRIA_PASTAS_GERAL() {
#################
# FUNÇÃO PERSONALIZADA
# AÇÃO: Leitura do arquivo: .arquivos5.tmp
#       Cria as pastas baseado no .arquvio5.tmp
#       Recebe o parâmetro $2 de formato de data, se é LONGO, CURTO ou NORMAL
    #################
    #### DECLARAÇÃO DE VARIÁVEIS
    local local=""
    local arq5=""
    local arq7=""
    local qtd_linhas=""
    local arq=""
    local local_destino=""
    #### FIM DECLARAÇÃO VARIÁVEIS

    local="$1"
    arq5="$local/.arquivos5.tmp"
    arq7="$local/.arquivos7.tmp"
    qtd_linhas=$(cat "$arq5" | wc -l)
    local_destino="$2"

    if [[ -z "$3" ]]; then
        arq="$arq5"
    else
        #AQUI VAI CHAMAR A FUNÇÃO DE TROCAR OS NÚMEROS 1-12 PARA TEXTO
        arq="$arq7"
    fi
    
    if [[ "$debug" -eq 1 ]]; then
        echo -e "$DBG""DEBUG: Entrou em CRIA_PASTAS_GERAL$RESET"
        echo -e "$INFO""Local arquivo: $RESET $local"
        echo -e "$INFO Caminho do .arquvios5: $RESET $arq5 - $INFO" $([[ -e "$arq5" ]] && echo "Arquivo existe $RESET" || echo "$ERROS Arquivo não existe$RESET")
        echo -e "$INFO Caminho do .arquvios7: $RESET $arq7 - $INFO" $([[ -e "$arq7" ]] && echo -e "$INFO Arquivo existe $RESET" || echo "$ERROS Arquivo não existe$RESET")
        echo -e "$INFO Formato de data: $RESET" $([[ -z "$3" ]] && echo "" )
        echo -e "$INFO""Arquivo selecionado: $RESET $arq"
        echo -e "$INFO""Quantidade de arquivos: $RESET $qtd_linhas"
    fi

    if [ -e "$arq" ]; then
        echo -e "$DBG Debug:$RESET Início do código de Criação de pastas"       
        
        ## LOCALIZAÇÃO DOS DADOS DENTRO DO ARQUIVO .arquivos5.tmp
        #cut -b 1-4     #->ano
        #cut -b 6-7     #->mês
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
            qtd_pasta_meses=$(cat "$arq" | awk '{print $2}' | sort | cut -b 1-7 | uniq | grep "$linha_anos" | cut -b 6-7 | wc -l)
            if [[ "$debug" -eq 1 ]]; then
                echo -e "$DBG""DEBUG: CRIAÇÃO DE PASTA ANOS - $qtd_total_criada\\$qtd_total $RESET"
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
                
                linha_mes=$(cat "$arq" | awk '{print $2}' | sort | cut -b 1-7 | uniq | grep "$linha_anos" | cut -b 6-7 | head -$j | tail -1)
                destcriar=$(echo "$local_destino/$linha_anos/$linha_mes")
                #IMPORTANTE - Essa variável $anomes ela irá filtrar dentro da lista do arquivo .arquivos5.tmp
                anomes=$(echo "$linha_anos-$linha_mes")

                if [[ "$debug"  -eq 1 ]]; then
                    echo -e "$DBGDEBUG: CRIAÇÃO DE PASTAS MESES$RESET"
                    echo -e "Mês atual: $linha_mes"
                    echo -e "Quantidade de meses: $qtd_pasta_meses"
                    echo -e "*Criando pastas mês $linha_mes: $destcriar"
                    #EXEMPLO: Meses do ano de 2020
                    #echo -e "$DBGFIM DEBUG$RESET"
                    echo -ne "\\rProcessando: [$progresso%]  $(echo "$destcriar")\\n"
                fi
                #Verificando se a pasta exite e cria se não existir
                #
                test -d "$destcriar" || mkdir "$destcriar" && echo "Pasta existe"

                qtd_pasta_dias=$(cat "$arq" | awk '{print $2}' | grep "$anomes" | uniq | sort | uniq | wc -l)
                
                for (( k=1; k<="$qtd_pasta_dias"; k+=1 )); do
                    linha_dias=$(cat "$arq" | awk '{print $2}' | grep "$anomes" | cut -b 9-10 | sort | uniq | head -"$k" | tail -1)
                    
                    destcriar=$(echo "$local_destino/$linha_anos/$linha_mes/$linha_dias")

                    if [[ "$debug" -eq 1 ]]; then
                        echo -e "$DBGDEBUG: CRIAÇÃO DE PASTAS DIA$RESET"
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
        echo -e "$DBG""FIM DEBUG$RESET"
    fi
}

CLASSIFICAR_MOVER() {
#################
# FUNÇÃO PERSONALIZADA
# AÇÃO: MOVE OS ARQUIVOS PARA AS PASTAS
#       Modifiquei a estrutura do loop para evitar que o arquivo fique repetindo com os arquivos duplicados.
#################
  
  ##### FUNÇÃO APRESENTANDO PROBLEMA E TRAVANDO O LOOP EM 15985 E TODO ARQUIVO DUPLICADO ELE RODA UM POR UM E FAZ O SCRIPT DEMORAR
  #PROBLEMA RESOLVIDO - VARIÁVEL ERRADA NA PARTE DE CONTROLE DE LOOP
  #AGORA É TESTAR PARA VER SE O SCRIPT VAI COPIAR OS ARQUIVOS DO JEITO CERTO
  #SUSPEITO QUE VÁ TER PROBLEMA COM ARQUIVOS REPETIDOS -> SUSPEITA CONFIRMADA.
  #18AGO2024 -> PRIMEIRA TENTATIVA: IGNORAR AS LINHAS DUPLICADAS
  #31AGO2024 -> REORGANIZAÇÃO DO CÓDIGO

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

    arq1=$(echo "$1""/.arquivos.tmp")
    arq2=$(echo "$1""/.arquivos2.tmp")
    arq4=$(echo "$1""/.arquivos4.tmp")
    arq5=$(echo "$1""/.arquivos5.tmp")
    lugar="$1"
    destino="$2"
    destino_duplicado="$3"

    #cp $arq5 $1"/.arqmod.tmp"
    arqmod=$(echo "$1""/.arqmod.tmp")
    dest="$2"
    #LOCAL PARA onde vão os duplicados
    local_dup="$3"
    cod="$4"

    #### TESTES
    if [[ -e "$arq1" ]]; then
        echo -e "$INFO""Arquivo .arquivos.tmp existe$RESET"
    else
        echo -e "$ERROS""Arquivo não exite$RESET"
        echo "Erro. Saiu"
        END_BAD
    fi

    if [[ -e "$arq2" ]]; then
        echo -e "$INFO""Arquivo .arquivos2.tmp existe$RESET"
    else
        echo -e "$ERROS""Arquivo não exite$RESET"
        echo "Erro. Saiu"
        END_BAD
    fi
    if [[ -e "$arq5" ]]; then
        echo -e "$INFO""Arquivo .arquivos5.tmp existe$RESET"
    else
        echo -e "$ERROS""Arquivo não exite$RESET"
        echo "Erro. Saiu"
        END_BAD
    fi
    #### BUG DETECTADO 14AGO2024
    #$2 não pode ser vazio
    if [[ -z "$2" ]]; then
        #echo "BUG permitindo não ter uma pasta, a fim de teste usará o caminho de origem"
       dest="$1"
    fi
    
    if [[ "$debug" -eq 1 ]]; then
        echo -e \
        "$DBG""DEBUG: ENTROU EM CLASSIFICAR_MOVER$RESET"
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
        caminho_mover=$(cat "$arq5" | awk '{print $2}' | sed 's/-/\//g' |head -"$i" | tail -1)
        caminho_mover="$dest/$caminho_mover"
        arq_mover=$(cat "$arq1" | head -"$i" | tail -1)
        linha_qtd=$(cat "$arq5" | nl | grep "$md5_mover" | awk '{print $1}' | wc -l)
            
        if [[ "$debug" -eq 1 ]]; then
            echo -e "$DBG""DEBUG: ENTROU EM CLASSIFICAR_MOVER$RESET
            MD5 a MOVER: $md5_mover
            Linha a se mover: $linha_mover
            Quantidade: $linha_qtd
            Destino a mover os arquvios: $caminho_mover
            Destino a mover os arquivos duplicados: $local_dup
            Arquivo a se mover: $arq_mover
            $DBG FIM DEBUG$RESET"
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
                echo -e "$linha_mover" | sed 's/ /\n/g' >> ./duplicados.txt

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
                    #mv /home/higlux/Imagens/INTOCADO/marinha/IMG-20240410-WA0057.jpg /destino/duplicado/IMG_20240501_095852(2).jpg/2024/04/10/
                    #echo "
                    mv "$arq_mover" "$caminho_mover/"
                    #"
                else
                #mv /home/higlux/Imagens/INTOCADO/marinha/IMG-20240410-WA0057.jpg /destino/duplicado/IMG_20240501_095852(2).jpg/2024/04/10/
                    RECRIAR_PASTA "$caminho_mover"
                    #echo "
                    mv "$arq_mover" "$caminho_mover/"
                    #"
                fi
            fi
        else
            echo "Arquivo não existe"
            PAUSE
        fi

        ####  ESE CÓDIGO É PARA FAZER UM LOOP DIFERENTE.
        #resto=$(cat $arqmod | wc -l)
        #if [ $resto -eq 1 ]; then
        #    echo "Deu certo"
        #    exit
        #else
        #    echo "entrou aqui: $arqmod"
        #    sed -i '1d' $arqmod
        #fi
    done
}

APAGAR_ARQUIVOS() {
#################
# FUNÇÃO PERSONALIZADA
# AÇÃO: APAGA OS ARQUIVOS TEMPORÁRIOS
#################
    echo -e "$DBG""Debug:$RESET Valor do parâmetro: $1"
    echo -e "$DBG""Debug:$RESET Início apagar arquivos."
    echo -e "\e[1;5;33mdebug:Impedido de fazer para intuito de teste$RESET"
}

CRIA_PASTA_DUP(){
#Criar pasta para mover arquivos duplicados
#DESCONTINUADO. O CAMINHO È REFERINCIADO NO INÌCIO DO SCRIPT
    ######### DECLARAÇÃO DE VARIÁVEIS
    local pasta_duplicados=""
    local local=""

    pasta_duplicados="$1"

    if [[ -d "$pasta_duplicados" ]]; then 
        echo "Pasta de arquivos duplicados existe"
        else
            mkdir "$local/duplicados"
    fi
    #Calcula aquantidade de arquivos duplicados
    qtd_dup=$(cat "$arq4" | wc -l)
    for (( i=1; i<="$qtd_dup"; i+=1 ));
    do
        md5_dup=$(cat .arquivos4.tmp | head -"$i" | tail -1)
        cat .arquivos2.tmp | grep $(cat .arquivos4.tmp | head -"$i" | tail -1) >> saida.txt
    done
        echo "Quantidade de arquivos detectados: $qtd
        Quantidade de arquivos duplicados: $qtd_dup"      
}

function MOV_ARQ_DUP () {
#ESSA FUNÇÃO SERÁ PARA CIRAR ALGO SEPARADO DO PROCESSO PADRÃO.
#IREI MODIFICAR O PROCESSO DO PROGRAMA COMO UM TODO
#PRIMEIRO IREI GERAR AS LISTAS E FAZER ISSO AQUI PRIMEIRO PARA ACELEARAR O CÓDIGO
    ####### DECLARAÇÃO AS VARIÁVEIS
    local orig=""
    local arq1=""
    local arq4=""
    local arq2=""
    local dest_dup=""
    local linha_exibir=""
    local qtd_dup_total=""
    local md5_dup=""
    local qtd_dup=""
    local dirname_mov=""
    ####### FIM DECLARAÇÃO AS VARIÁVEIS

    ####### ATRIBUIÇÃO AS VARIÁVEIS
    local orig="$1"
    local arq1="$orig/.arquivos.tmp"
    local arq4="$orig/.arquivos4.tmp" #arquivos duplicados
    local arq2="$orig/.arquivos2.tmp"
    local dest_dup="$2"

 #head -31 -> linha do duplicado
    qtd_dup_total=$(cat "$arq4" | wc -l)
    for (( i=1; i<=qtd_dup_total; i+=1 )); do
        md5_dup=$(cat "$arq4" | head -"$i" | tail -1 | awk '{print $1}')
        qtd_dup=$(cat "$arq2" | nl | grep "$md5_dup" | wc -l)
        #echo $qtd_dup
            for (( j=1; j<="$qtd_dup"; j+=1 )); do
                linha_exibir=$(echo $(cat "$arq2" | nl | grep $(cat "$arq4" | head -"$i" | tail -1) | awk '{print $1}') | awk "{print \$""$j""}")
                #arq_dup_mover=$(cat $arq1 | head -$linha_exibir | tail -1 | sed 's/ /\\/g')
                arq_dup_mover=$(cat "$arq1" | head -"$linha_exibir" | tail -1)
                echo "Linha a exibir: $linha_exibir"
                echo "Arquivo a mover: $arq_dup_mover"

                #dirname_mov=$(dirname $arq_dup_mover | sed 's/ /\\/g')
                #echo $dirname_mov"="$dest_dup
                if [[ "$dest_dup" = "$dirname_mov" ]]; then 
                    echo "Ignorando"
                else
                    if [[ -e "$arq_dup_mover" ]]; then
                        #arq_dup_mover=\"$arq_dup_mover\"
                        mv "$arq_dup_mover" "$dest_dup/"
                    else
                        echo "$arq_dup_mover Não existe"
                    fi
                fi
            done
    done
    #cat $arq2 | nl | grep $md5_dup | awk '{print $1}' | wc -l

    #cat .arquivos2.tmp | nl | grep `cat .arquivos4.tmp | head -31 | tail -1` | awk '{print $1}' | wc -l
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
[[ "$debug" -eq 1 ]] && INFRM "(PARÂMETROS) - ENTRADA DE PARÂMETROS"
if [ -z "$1" ]; then
    echo "$prg $vers:"
    echo -e \
    "   $DBG Debug$RESET ativado automáticamente
        As menságens em $(echo -e "$DBG laranja$RESET") são saídas do script.
        Use o parâmetro $(echo -e "$INFO -h ou --help$RESET") para exibir as opções
    "
    exit 0
fi
##### ERRO NOS PARÂMETROS
#DUPLICADO -u E O -d
for a in "${!entradas[@]}";
do
    if [[ ! ${entradas[$a]} = " " ]]; then
        if [[ "$debug" -eq 1 ]]; then
            DBG "(PARÂMETROS):Valor de entrada $a: ${entradas[$a]}"
        fi
        case ${entradas[$a]} in 
            -a|--apagar)
                echo 'Realmente deseja apagar os arquivos temporários?'
                echo -e "\e[5;31mEssa ação não poderá ser desfeita.$RESET"
                echo -en "\e[1mApagar arquivos temporários [S/N]: $RESET"
                read -nr 1 resp
                resp=${resp^^}
                if [ "$resp" = "S" ]; then
                    apagar_arquivos "$resp"
                fi
                exit
            ;;
            -h|--help)
                RELP
                exit
            ;;
            -v|--version)
                echo 'Versão: '
                echo "$prg" "$vers"
                exit
            ;;
            --debug)
                echo "Modo debug ativado"
                debug=1;
            ;;
            -c|--create)
                #CRIA as pastas
                #Função CRIAPASTAS $1-LOCAL do .arquivos5.tmp $2 - Formato
                
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
                            END_BAD "O formato $param não foi encontrado"
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
                    DBG "(PARÂMETROS): Valor de \$local - $local"
                fi
                if [[ -z "$local" ]]; then
                    END_BAD "O local de verificação não pode ser vazio"
                else
                    if [[ -d "$local" ]]; then
                        INFRM "$local - Encontrado"
                    else
                        END_BAD "O diretório especificado: $local - No Existe. Especifique um diretório válido"
                    fi
                fi
            ;;
            -d|--destino)
                param="${entradas[$a]}"
                (( a+=1 ))
                local_tmp="${entradas[$a]}"
                CRIA_DESTINO "$local_tmp" "$param"

            ;;
            -m| --mover)
                param="${entradas[$a]}"
                echo "Entrou Mover"
                (( a+=1 ))
                local_tmp="${entradas[$a]}"
                CRIA_DESTINO "$local_tmp" "$param"
            ;;
            -t|--tipo)
                (( a+=1 ))
                prm="${entradas["$a"]}"
                SET_SUM "$prm"
                INFRM "Verificador selecionado $cmd_sum"
            ;;
            *)
            if [[ !"${entradas[$a]}" = " " ]];then
                result=$(echo "$a % 2" | bc)
                if [[ "$a" -eq 0 ]]; then
                    END_BAD "O parâmetro ""${entradas[$a]}"" é um comando inválido"
                fi
                if [[ "$result" -eq 0 ]]; then 
                    END_BAD "O parâmetro ""${entradas[$a]}"" é um comando inválido"
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
[[ "$debug" -eq 1 ]] && INFRM "(PARÂMETROS) - FIM ENTRADA DE PARÂMETROS"
##################### Entrada de parâmetros do script - FIM


#Primeira verificação é se as variáveis foram setadas
#Segunda verificação é se existem os arquivos temporários

################
#   VERIFICAÇÃO DE VARIÁVEIS
################
INFRM "(VARIAVEIS) - INÍCIO VERIFICAÇÃO DE VARIÁVEIS";
[[ -e "$cmd_sum" ]] || cmd_sum="/usr/bin/md5sum"
[[ -z "$local_destino" ]] && local_destino="$local"
[[ -z "$local_destino_duplicado" ]] && local_destino_duplicado="Vazio"

if [[ "$debug" -eq 1 ]]; then
    DBG "(VARIAVEIS) - Variáveis setadas: 
        Origem - \$local: $local
        Verificador - \$cmd_sum: $cmd_sum
        Destino dos arquivos - \$local_destino: $local_destino
        Destino dos duplicados - \$local_destino_duplicado: $local_destino_duplicado"
fi

#### Isso aqui é para saber a quantidade de linhas do arquvio e fazer barra de progresso. - Descontinuado
#qtd_total=$(cat $(echo "$local/.arquivos.tmp" ) | wc -l)
#qtd_total=$(cat "$local/.arquivos.tmp" | wc -l)
#qtd_total_criada=0
[[ "$debug" -eq 1 ]] && INFRM "(VARIAVEIS) - FIM VERIFICAÇÃO DE VARIÁVEIS"
################ FIM VERIFICAÇÃO DE VARIÁVEIS

##################################
#             MAIN
##################################
[[ "$debug" -eq 1 ]] && INFRM "(MAIN) - EXECUÇÃO DO SCRIPT"

##################### CRIAÇÃO DOS .arquivos*.tmp
#.arquivos  - Lista Bruta
#.arquivos2 - Lista MD5
#.arquivos3 - Lista MD5 pura
#.arquivos4 - Lista MD5 duplicados
#.arquivos5 - Lista MD5 com data
#CRIA_LISTAS $1=Origem $2=MD5/SHA $3=Formato

CRIA_LISTAS "$local" "$cmd_sum" "$fmt" "$local_destino_duplicado"


########## FUNLÇÃO CRIAR PASTAS
###### VARIÁVEIS UTILIZADAS
### $local -> LUGAR DE BUSCA DOS ARQUIVOS
### $fmt -> FORMATO DE DATA. NUMÉRICO, EXTENSO (CURTO E LONGO)
#
CRIA_PASTAS_GERAL "$local" "$local_destino" "$fmt"

#####

echo "Deseja mover os arquivos para essas pastas? [S/N]"
read -r resp
resp=${resp^^}

if [[ "$resp" = "S" ]]; then
    echo "respondeu Sim"
    ########## FUNLÇÃO CLASSIFICAR_MOVER
    ###### VARIÁVEIS UTILIZADAS
    # $local -> LUGAR DE BUSCA DOS ARQUIVOS
    ### 
    #CRIA_PASTAS_GERAL Local Destino (Cópia o Mover)
    CLASSIFICAR_MOVER  "$local" "$local_destino" "$local_destino_duplicado" "$execucao"
else
    echo "respondeu Não"
    exit
fi

MOV_ARQ_DUP "$local"

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





##################### COISAS EXTRAS
###Preciso decidir como tratar os arquivos duplicados, pois tem dois modos
# 1 - Mesmo nome, mas com MD5 diferente
# 2 - Nome diferente, mas com MD5 igual
# 3 - Mesmo nome e com MD5 igual.

######################################## NOTA 1 - BUG ENCONTRADO #Apresentando problema nesss comando acima, pois os arquivos da linha 6089 e 7156 por conta do fato deles serem arquivos de texto e com isso estão lendo o conteúdo dele. posso tentar resolver se eu tirar a variável e colocar o comando dentro da outra variável, com isso pode resolver.

#Isso faz com que o maior espaço dê valores astronômicos que passa a dar erro quando precisar mover algum arquivo mais abaixo.

#19JUN2024 - Fiz a alteração do comando "cat" para "echo" - Reolveu
#Enquanto não dá certo, podemos ignorar esse erro? Para testes sim

######################################## FIM - NOTA 1





##################### arquivos temporários
# .arquivos.tmp  - Resultado do find
# .arquivos2.tmp - Resultado do MD5 com caminho #Este arquivo ele não pode ser usado para buscar o caminho do arquivo senão vai dar problema na hora de extrair o conteúdo, por isso eu coloquei um novo arquivo com MD5 e data para facilitar a busca. adicionei numa terceira coluna a data de criação do arquivo, mas eu irei retirar e criar um novo arquivo de texto.
# .arquivos3.tmp - Só os códigos MD5
# .arquivos4.tmp - arquivos duplicados
# .arquivos5.tmp - Código MD5 com data
###########################################


#Exibir a linha 2 do .arquivo2.tmp
#sed -n 2p .arquivo2.tmp

#Imprimir n linhas
#sed '2q' .arquivos2.tmp
#Exibe só o nome do arquivo
#cat .arquivos2.tmp | awk '{print$2}' | sed 's:.*/::'

############ IDEIAS A IMPLEMENTAR
# Ao se obter a quantidade dos arquvios do disco, a depender da quantidade será necessário dividir a lista em duas (se par), 3 ou mais (de acordo com a divisibilidade) para acelerar a criação do .arquivos2.tmp.

#unset variável