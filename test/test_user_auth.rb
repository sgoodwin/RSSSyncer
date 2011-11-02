require 'rubygems'
require './lib/user'

begin
	puts User::auth('hi', 'sup?')
rescue Exception=>e
	puts e.message
end

# We might wanna test signing up with dups, signing up
# authorizing, testing for the exception when a user is not
# authorized etc.