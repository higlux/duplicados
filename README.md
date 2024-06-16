# duplicados
#PT-BR
Shell script detector de arquivos duplicados

Um código cagado que eu fiz que pode ser útil para alguém, logo, copie, faça melhor e me avise.

Foi idealizado para solucionar o problema de fotos duplicados dentro do meu disco externo, ainda irei adicionar um código para organizar as fotos por data de criação com a informação vindo dos metadados e não de criação do arquivo no disco.

Para entender essa carroça você vai precisar saber como funciona:
  BASH
  MD5SUM
  SED
  WC
  CAT
  SORT
  ECHO
  MV
  EXTRACT * vou remover

Vou disponibilizar o arquivo funcional (Não no sentido completo da palavra) como versão e a atual como em desenvolvimento.

09JUN2024 - Versão 0.0.0.1 beta
16JUN2024 - Adição da data dos arquivos no arquivo temporário
            Correção de bug de caminho de arquivo com espaços.
            Entrada de um parâmetro para o arquivo para apagar os arquvios temporários com um comando
            

Qualquer dúvida entre em contato pelo e-mail: higluxmorales@gmail.com
Eu demoro para ver a caixa de mensagem, então espere sentado por qualquer resposta.

#EN
Shell script double files detector and remover

It's a script for detect duplicated files, it's as is, should be useful for someone, you can copy and improve it, if you'll do this please tell me.

Was built to solve an problem with an external drive who i save my files. The next step is add a code to organize the photos by creation from metadata.

To use it you need use:
  BASH
  MD5SUM
  SED
  WC
  CAT
  SORT
  ECHO
  MV

The main file is funcional, but use with carefull.