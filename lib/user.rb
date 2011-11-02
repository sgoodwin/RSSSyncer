require './lib/redissupport'
require 'digest/md5'

class User
	extend RedisSupport
	
	@@user_id = nil
	
	def user_id
		@@user_id
	end
	
	def self.hash(username, password)
		Digest::MD5.hexdigest(username+password)
	end
	
	def self.auth(username, password)
		hash = self.hash(username, password)
		@@user_id = self.redis.get("user:#{hash}")
	end
	
	def self.auth_with_hash(hash)
		@@user_id = self.redis.get("user:#{hash}")
	end
	
	def self.sign_up(username, password)
		hash = self.hash(username, password)
		
		# Only need to create a new user ID if the user doesn't exist
		# already.
		self.auth(username, password)
		@@user_id = self.redis.incr("user.ids") if @@user_id.nil?
		if(self.redis.sadd("user.usernames", username))
			self.redis.set("user:#{hash}", @@user_id)
		else
			throw(:halt, [403, "That username is taken!\n"])
		end
	end
end