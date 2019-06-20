use Mix.Config

config :pipeline, s3_adapter: Pipeline.External.S3.DevAdapter

config :pipeline, :chrome_data,
  account_info: "297766",
  secret: "008ed7bc60674017"
