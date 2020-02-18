FROM ruby:2.7

RUN mkdir /specs
WORKDIR /specs
COPY Gemfile /specs/Gemfile

RUN apt-get install imagemagick=8:6.9.10.23+dfsg-2.1 -y --no-install-recommends

RUN bundle install
# specs should be mounted to the container. If not, uncomment this:
# ADD . /specs/spec

CMD ["bundle", "exec", "rspec"]
