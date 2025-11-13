# frozen_string_literal: true
# encoding: utf-8

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require "logger"
require "gen-feed"
require "aws-sdk-s3"

logger = Logger.new(STDOUT)

bucket = ENV["RADICASTER_S3_BUCKET"] or raise "ENV['RADICASTER_S3_BUCKET'] must be set"
url = ENV["RADICASTER_BUCKET_URL"] or raise "ENV['RADICASTER_BUCKET_URL'] must be set"

s3_client = Aws::S3::Client.new
storage = Radicaster::GenFeed::S3.new(s3_client, bucket, url)

generator = Radicaster::GenFeed::FeedGenerator.new

Handler = Radicaster::GenFeed::Handler.new(logger, storage, generator)
