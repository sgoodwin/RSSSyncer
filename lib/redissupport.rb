require 'redis'
require 'uri'

module RedisSupport
	def redis
		redis_URL = URI::parse(ENV['REDISTOGO_URL'] || "redis://0.0.0.0:6379")
		@@redis ||= Redis.new(:host => redis_URL.host, :port => redis_URL.port)
		@@redis.auth(redis_URL.password)
		return @@redis
	end
end