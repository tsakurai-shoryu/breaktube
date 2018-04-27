FROM ruby:2.4-alpine

RUN apk --update add --virtual build-dependencies build-base curl-dev sqlite sqlite-dev \
 && gem install bundler

COPY ./ /app
WORKDIR /app
RUN cd /app \
 && bundle install --path .bundle

VOLUME ["/app/db"]

CMD ["bundle", "exec", "ruby", "server.rb", "-o", "0.0.0.0"]
