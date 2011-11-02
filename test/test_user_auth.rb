require 'rubygems'
require './lib/user'

begin
	puts User::auth('hi', 'sup?')
rescue Exception=>e
	puts e.message
end

User::sign_up('hi', 'sup?')