json.array!(@trim_links) do |trim_link|
  json.extract! trim_link, :id, :filename, :binary_id, :size
  json.url trim_link_url(trim_link, format: :json)
end
