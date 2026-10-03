FROM ruby:3.3
RUN curl -SL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get update -qq --fix-missing
RUN apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /ledger
WORKDIR /ledger
COPY Gemfile /ledger/Gemfile
COPY Gemfile.lock /ledger/Gemfile.lock
RUN gem install bundler -v 2.4.22
RUN bundle install

