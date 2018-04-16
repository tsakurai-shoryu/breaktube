FROM ruby:2.4-alpine

RUN apk --update add --virtual build-dependencies build-base curl-dev \
 && gem install bundler

COPY ./ /app
WORKDIR /app
RUN cd /app \
 && bundle install --path .bundle

CMD ["bundle", "exec", "ruby", "event.rb", "-o", "0.0.0.0"]