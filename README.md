# LucasGamaV-2024-2-Gestao-Labs-DCOMP
Repositório para desenvolvimento de projeto de estágio obrigatório do DCOMP da UFS (Universidade Federal de Sergipe)


## Para rodar o LabComunica
- Baixar as dependências do flutter especificadas no arquivo 'pubspec.yaml'
  - para fazer isso acesse o 'frontend' do diretório do projeto onde se encontra o 'pubspec.yaml'
  - colocar o comando 'flutter pub get' no terminal
  - se não funcionar, certifique-se de que seu usuário é propretário do diretório com 'ls -l pubspec.lock'
  - se não for use o comando 'sudo chown $(whoami):$(whoami) pubspec.lock' ou 'sudo chown -R $(whoami):$(whoami) .'
  - rode o comando 'flutter pub get' no terminal novamente
- Comando para rodar o flutter no Chrome;
  - flutter run -d chrome --web-port=7000
- Para rodar o projeto você deve ter instalado o PostgreSQL;
  - em seguida criar o database 'labcomunica' (o nome pode ser diferente desde que mude no .env)
  - verificar qual o usuário do postgresql e sua senha para mudar no .env do projeto
  - 2024-2-Gestao-Labs-DCOMP/backend/.env
- O projeto utilizar Flutter, dart, python e FastAPI, tenha certeza de ter todos eles instalados;

## Para rodar o python
- Instalar as dependências especificadas no poetry
  - poetry install
- Comando para rodar o backend do projeto utilizando o poetry e uvicorn
  - poetry run uvicorn app.main:app --reload
