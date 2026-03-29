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
# 1. Create Categories
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
# 2. Create Products
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