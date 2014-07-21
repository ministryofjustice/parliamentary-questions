json.array!(@ogds) do |ogd|
  json.extract! ogd, :id, :name, :acronym
  json.url ogd_url(ogd, format: :json)
end
