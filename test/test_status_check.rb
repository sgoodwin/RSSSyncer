require './lib/item.rb'

puts "Checking 10000000 (a read item)"
puts Item.check_status("10000000")

puts "Checking 255 (also a read item)"
puts Item.check_status(255)

puts "Checking 0 (an unread item)"
puts Item.check_status(0)

puts "Also checking 0000000 (an unread item)"
puts Item.check_status("00000000")