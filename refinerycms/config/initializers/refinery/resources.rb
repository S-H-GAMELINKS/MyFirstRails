# encoding: utf-8
Refinery::Resources.configure do |config|
  # Configures the maximum allowed upload size (in bytes) for a file upload
  # config.max_file_size = 52428800

  # Configure how many resources per page should be displayed when a dialog is presented that contains resources
  # config.pages_per_dialog = 12

  # Configure how many resources per page should be displayed in the list of resources in the admin area
  # config.pages_per_admin_index = 20

  # Configure Dragonfly.
  # Refer to config/initializers/refinery/dragonfly.rb for the full list of dragonfly configurations which can be used.
  # This includes all dragonfly config for Dragonfly v 1.1.1

  # config.dragonfly_verify_urls     = true
  # config.dragonfly_secret          = "55945c7a1b2062d0e561fdac2701821ba35c01ce3ce3748f"
  # config.dragonfly_url_host        = ""
  # config.dragonfly_datastore_root_path = "C:/Users/shunh/Desktop/MyFirstRails/refinerycms/public/system/refinery/resources"
  # config.dragonfly_url_format       = "/system/refinery/resources/:job/:basename.:ext"

  # Configure S3 (you can also use ENV for this)
  # The s3_datastore setting by default defers to the Refinery::Dragonfly setting for this but can be set just for images.
  # config.s3_datastore         = Refinery::Dragonfly.s3_datastore
  # config.s3_bucket_name       = ENV['S3_BUCKET']
  # config.s3_access_key_id     = ENV['S3_KEY']
  # config.s3_secret_access_key = ENV['S3_SECRET']
  # config.s3_region            = ENV['S3_REGION']
  #
  #  further S3 configuration options
  # config.s3_fog_storage_options      = nil
  # config.s3_root_path                = nil
  # config.s3_storage_path             = nil
  # config.s3_storage_headers          = nil
  # config.s3_url_host                 = nil
  # config.s3_url_scheme               = nil
  # config.s3_use_iam_profile          = nil

  # Configure Dragonfly custom datastore
  # The custom_datastore setting by default defers to the Refinery::Resources setting for this but can be set just for images.
  # config.custom_datastore_class     = nil
  # config.custom_datastore_opts      = {}
end
