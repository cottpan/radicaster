FROM public.ecr.aws/lambda/ruby:3.4 AS bundler
WORKDIR /var/task
RUN microdnf install -y gcc gcc-c++ make
COPY ./Gemfile ./Gemfile
COPY ./Gemfile.lock ./Gemfile.lock
RUN bundle config set --local path 'vendor/bundle' && bundle install


FROM public.ecr.aws/lambda/ruby:3.4 AS download
WORKDIR /tmp
ADD https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz /tmp/ffmpeg.tar.xz
RUN microdnf install -y tar xz \
  && tar -Jxf /tmp/ffmpeg.tar.xz \
  && cp /tmp/ffmpeg-*/ffmpeg ffmpeg


FROM public.ecr.aws/lambda/ruby:3.4
WORKDIR /var/task

ENV TZ=Asia/Tokyo

RUN microdnf install -y python3 python3-pip \
  && pip3 install --no-cache-dir 'yt-dlp>=2025.02.19' yt-dlp-rajiko \
  && microdnf clean all

COPY --from=bundler /var/task/vendor ./vendor
COPY --from=download /tmp/ffmpeg /usr/local/bin/ffmpeg
COPY ./ ./

CMD ["function.Handler.handle"]
