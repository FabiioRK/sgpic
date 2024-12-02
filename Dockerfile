FROM ruby:3.2.3

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client build-essential

WORKDIR /sgpic

COPY Gemfile Gemfile.lock ./

RUN gem install bundler:2.4.21

RUN bundle install --jobs=4 --retry=3

COPY . .

EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]
