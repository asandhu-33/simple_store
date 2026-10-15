# Part 1: A New Rails Application

## Step 1: Project Initialization
Generated a new Ruby on Rails application configured with SQLite as the default database adapter.
rails new simple_store
cd simple_store

## Step 2: Generating Models and Migrations
Created two primary domain models: Category and Product. A Category has many products, and a Product belongs to a category.
rails g model Category name:string
rails g model Product title:string price:decimal description:text stock_quantity:integer category:references

## Step 3: Defining Model Associations & Validations
app/models/category.rb
class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  validates :name, presence: true
end

app/models/product.rb
class Product < ApplicationRecord
  belongs_to :category

  validates :title, :price, :stock_quantity, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

## Step 4: Running Database Migrations
Applied schema changes to the local SQLite database:
rails db:migrate


# Part 2: Loading Data From a CSV
## Step 5: Adding the Dataset (products.csv)
Placed raw data file inside the db/ directory (db/products.csv). 
The CSV structure maps product details and category associations:
title,price,description,stock_quantity,category_name

## Step 6: Writing the Seeding Script (db/seeds.rb)
To populate  database reliably while avoiding encoding/BOM issues and parsing failures, I implemented a robust parsing approach inside db/seeds.rb:

require "csv"

Product.destroy_all
Category.destroy_all

csv_file = Rails.root.join("db/products.csv")

# Read CSV with BOM strip protection and iterate over rows
CSV.foreach(csv_file, headers: false, encoding: "bom|utf-8") do |row|
# Skip header row or any stray blank records
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


Then executed the seed command:
rails db:seed

## Step 7: Optimizing Controller Queries (Preventing N+1)

To prevent performance degradation caused by N+1 database queries when rendering associated categories in the view, I updated ProductsController to eagerly load categories using .includes(:category):

app/controllers/products_controller.rb

class ProductsController < ApplicationController
  def index
    @products = Product.includes(:category).all
  end

  def show
    @product = Product.find(params[:id])
  end
end


## Step 8: Updating Views & Rendering Products
Configured index view (app/views/products/index.html.erb) to display the seeded records cleanly:

<h1>All Products</h1>

<ul>
  <% @products.each do |product| %>
    <li>
      <strong><%= product.title %></strong> 
      (Category: <%= product.category.name %>) - 
      $<%= product.price %> 
      (Stock: <%= product.stock_quantity %>)
    </li>
  <% end %>
</ul>


# Running the Application
rails s

Open web browser and navigate to:
http://localhost:3000/products


# Git Version Control Workflow
To commit complete work to Git:

git add .
git commit -m "..."