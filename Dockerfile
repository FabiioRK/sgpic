# Usar imagem base do Ruby
FROM ruby:3.2.2

# Instalar dependências do sistema
RUN apt-get update -qq && apt-get install -y nodejs sqlite3

# Configurar diretório de trabalho
WORKDIR /app

# Copiar o Gemfile e o Gemfile.lock
COPY Gemfile* ./

# Instalar as gems necessárias
RUN bundle install

# Copiar o restante da aplicação
COPY . .

# Expor a porta onde o Rails rodará
EXPOSE 3000

# Comando para rodar a aplicação
CMD ["rails", "server", "-b", "0.0.0.0"]
