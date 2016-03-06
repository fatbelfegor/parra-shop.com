json.array!(@products) do |prod|
  json.extract! prod, :id, :category_id, :name, :shortdesk, :description, :images, :price, :position, :updated_at
end