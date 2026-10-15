require "csv"

# Clear existing data to avoid duplication or constraint errors
Product.destroy_all
Category.destroy_all

csv_file = Rails.root.join("db/products.csv")
csv_data = File.read(csv_file)
products = CSV.parse(csv_data, headers: true, header_converters: :symbol)

products.each do |row|
  category = Category.find_or_create_by!(name: row[:category_name])
  category.products.create!(
    title: row[:title],
    description: row[:description],
    price: row[:price],
    stock_quantity: row[:stock_quantity]
  )
end

puts "Loaded #{Category.count} categories and #{Product.count} products!"