use Mix.Config

# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

if File.exists?("#{Path.dirname(__ENV__.file())}/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
