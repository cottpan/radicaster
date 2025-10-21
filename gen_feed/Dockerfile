FROM amazon/aws-lambda-ruby:3.3 AS bundler
WORKDIR /var/task
RUN microdnf install -y gcc gcc-c++ make
COPY ./Gemfile ./Gemfile
COPY ./Gemfile.lock ./Gemfile.lock
RUN bundle config set --local path 'vendor/bundle' && bundle install


FROM amazon/aws-lambda-ruby:3.3
WORKDIR /var/task

ENV TZ=Asia/Tokyo

COPY --from=bundler /var/task/vendor ./vendor
COPY ./ ./

CMD ["function.Handler.handle"]
