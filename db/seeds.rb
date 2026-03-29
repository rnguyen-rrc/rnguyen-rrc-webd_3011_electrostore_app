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