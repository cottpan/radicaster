FROM amazon/aws-lambda-ruby:3.3 AS bundler
WORKDIR /var/task
RUN microdnf install -y gcc gcc-c++ make
COPY ./Gemfile ./Gemfile
COPY ./Gemfile.lock ./Gemfile.lock
RUN bundle config set --local path 'vendor/bundle' && bundle install


FROM amazon/aws-lambda-ruby:3.3 AS download
WORKDIR /tmp
ADD https://github.com/yyoshiki41/radigo/releases/download/v0.11.0/radigo_v0.11.0_linux_amd64.zip /tmp/radigo.zip
ADD https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz /tmp/ffmpeg.tar.xz
RUN microdnf install -y unzip tar xz \
  && unzip /tmp/radigo.zip \
  && tar -Jxf /tmp/ffmpeg.tar.xz \
  && cp /tmp/ffmpeg-*/ffmpeg ffmpeg


FROM amazon/aws-lambda-ruby:3.3
WORKDIR /var/task

ENV TZ=Asia/Tokyo

COPY --from=bundler /var/task/vendor ./vendor
COPY --from=download /tmp/radigo /usr/local/bin/radigo
COPY --from=download /tmp/ffmpeg /usr/local/bin/ffmpeg
COPY ./ ./

CMD ["function.Handler.handle"]
