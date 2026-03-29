# db/seeds.rb

require 'faker'

puts "Cleaning database..."

ProductCategory.destroy_all
Product.destroy_all
Category.destroy_all

AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
end

# -----------------------------
# 1.6 - Write a seed script to populate product database with products and associated categories using Faker
# -----------------------------

# -----------------------------
# Create Categories
# -----------------------------
puts "Creating categories..."

category_names = ["Electronics", "Phones", "Laptops", "Accessories"]

categories = category_names.map do |name|
  Category.create!(
    name: name,
    description: Faker::Lorem.sentence
  )
end

# -----------------------------
# Create Products
# -----------------------------
puts "Creating products..."

100.times do
  product = Product.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: Faker::Commerce.price(range: 10..500),
    stock_quantity: rand(1..100)
  )

  # Assign 1–3 random categories
  product.categories << categories.sample(rand(1..3))
end

puts "Seeding complete!"

# --------------------------------------------------------------------------------------------------------------------
# 1.7 - Scrape seed data for products and categories from a 3rd party website using a web scraping tool
# --------------------------------------------------------------------------------------------------------------------

require 'open-uri'
require 'nokogiri'

base_url = "https://books.toscrape.com/"

puts "Scraping categories..."

# ---------- SCRAPE CATEGORIES ----------
doc = Nokogiri::HTML(URI.open(base_url))

doc.css('.side_categories ul li ul li a').each do |category|
  name = category.text.strip

  Category.find_or_create_by!(name: name)
end

puts "Categories created!"

# ---------- SCRAPE PRODUCTS ----------
puts "Scraping products..."

doc.css('.product_pod').each do |book|
  title = book.css('h3 a').attr('title').value
  price = book.css('.price_color').text.gsub('£', '').to_f

  # random category (simple version)
  category = Category.order("RANDOM()").first

  Product.create!(
    name: title,
    description: "Book from BooksToScrape",
    price: price,
    stock_quantity: rand(1..100),
    categories: [category]
  )
end

puts "Products created!"

# -----------------------------
# 1.8 - API DATA (DummyJSON)
# -----------------------------
require 'net/http'
require 'json'

puts "Seeding products from API..."

url = URI("https://dummyjson.com/products/category/smartphones")
response = Net::HTTP.get(url)
data = JSON.parse(response)

# Create or find category
category = Category.find_or_create_by!(
  name: "Smartphones"
) do |c|
  c.description = "Mobile devices from API"
end

data["products"].each do |item|
  name = item["title"]
  description = item["description"]
  price = item["price"]

  # Avoid duplicates
  next if Product.exists?(name: name)

  product = Product.create!(
    name: name,
    description: description,
    price: price,
    stock_quantity: rand(5..50)
  )

  product.categories << category
end

puts "API seeding complete!"