require 'redis'

module RedisSupport
	def redis
		@@redis ||= Redis.new
	end
end