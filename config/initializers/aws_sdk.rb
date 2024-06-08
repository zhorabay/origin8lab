require 'aws-sdk-s3'

Aws.config.update({
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
})

s3_client = Aws::S3::Client.new

multipart_threshold = 15 * 1024 * 1024
max_concurrent_uploads = 5

Rails.logger.info("AWS S3 Multipart threshold: #{multipart_threshold}")
Rails.logger.info("AWS S3 Max concurrent uploads: #{max_concurrent_uploads}")

uploader = Aws::S3::MultipartFileUploader.new({
  client: s3_client,
  bucket: ENV['AWS_BUCKET'],
  multipart_threshold: multipart_threshold,
  max_concurrent_uploads: max_concurrent_uploads
})

Rails.logger.info("Custom uploader created successfully")
