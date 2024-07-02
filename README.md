# duplicados
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

Vou disponibilizar o arquivo funcional (Não no sentido completo da palavra) como versão e a atual como em desenvolvimento.

Qualquer dúvida entre em contato pelo e-mail: higluxmorales@gmail.com

Eu demoro para ver a caixa de mensagem, então espere sentado por qualquer resposta.

Atualizado em 02Julho2024

Código funcionando criando as pastas, aceitando alguns parâmetros. para usar

Edite o arquivo e localize a variável de caminho da pasta altere, salve.

transforme-o em arquivo executável $ chmod +x ./main.sh

Depois você execute o cmonado ./main.sh
Depois execute $ ./main -c

Pronto, depois de muitas linhas na tela seus arquivos estarão organizados por data.

Problemas ainda sem solução: Arquivos e pastas com espaço no nome, caso tenha arquivos assim execute o script, renomeie os arquivos e pastas e execute novamente.
