# Duplicados
Shell script double files detector and remover

Um código cagado que eu fiz que pode ser útil para alguém, logo, copie, faça melhor e me avise.

Foi idealizado para solucionar o problema de fotos duplicados dentro do meu disco externo, ainda adicionei um código para organizar as fotos por data de criação com a informação vindo da criação do arquivo no disco.

Para entender essa carroça você vai precisar saber como funciona:
  BASH
  MD5SUM
  SED
  WC
  CAT
  SORT
  ECHO
  MV
  CHMOD

-> Vou disponibilizar o arquivo funcional (Não no sentido completo da palavra) como versão e a atual como em desenvolvimento.

Como usar:
  - Transforme-o em arquivo executável $ chmod +x ./main.sh
  - Depois você execute o cmonado ./main.sh
  - Use a opção -h para ajuda
  - Exemplo de uso: ./main.sh -l /home/SEUUSUARIO/IMAGENS -d PASTA_DESTINO -m PASTA_DUPLICADOS
Pronto, depois de muitas linhas na tela seus arquivos estarão organizados por data.

Atualizado em 02Julho2024
-Código funcionando criando as pastas, aceitando alguns parâmetros. para usar
-Edite o arquivo e localize a variável de caminho da pasta altere, salve.
- Problemas ainda sem solução:
  +Arquivos e pastas com espaço no nome, caso tenha arquivos assim execute o script, renomeie os arquivos e pastas e execute novamente.

Atualizado em 07JUL2024
- Melhorias no código para funcionar melhor, ainda persiste o problema do espaço, trabalhando para resolver isso.
- Funciona, mas você precisa executar da mesma maneira acima, depois que você encontrar os arquivos com espaço, renomeios e rode novamente o script.
- Problemas ainda sem solução:
    +Arquivos e pastas com espaço no nome, caso tenha arquivos assim execute o script, renomeie os arquivos e pastas e execute novamente. (RESOLVIDO PARCIALMENTE)

Atualizado em 04SET2024
- Melhoria na estrutura e nas práticas de programação.
- Funciona de modo fidedigno, ele está por padrão mover os arquivos para fazer o programa copiar organizado tem que ser alterado.


Qualquer dúvida entre em contato pelo e-mail: higluxmorales@gmail.com

Eu demoro para ver a caixa de mensagem, então espere sentado por qualquer resposta.
