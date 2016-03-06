json.array!(@categoriesmobile) do |cat|
  json.extract! cat, :id, :parent_id, :name, :updated_at, :mobile_image_url, :description, :position
end