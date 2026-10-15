require "csv"

Product.destroy_all
Category.destroy_all

csv_file = Rails.root.join("db/products.csv")

# Read with file encoding set to utf-8 with BOM stripped
CSV.foreach(csv_file, headers: false, encoding: "bom|utf-8") do |row|
  # Skip header row or any blank rows
  next if row[0] == "title" || row[0].blank?

  category = Category.find_or_create_by!(name: row[4])
  category.products.create!(
    title: row[0],
    price: row[1],
    description: row[2],
    stock_quantity: row[3]
  )
end

puts "Loaded #{Category.count} categories and #{Product.count} products!"