require 'redis'
require 'lib/usersupport'
require 'lib/redissupport'

# To store the only information about a given subscription we care about.
# subscriptions: (OPML list, sync of subscribe/unsubscribe)
# subscriptionID: 0 (incremented to generate subscription ID's)
# subscription:<subscription_id (hash)
# 	htmlURL
# 	feedURL
# 	name
# 	type

# Subscriptions could be organized in folders on the client, this dataset will be
# used to store all folders a given subscription is placed inside to generate the 
# OPML file appropriately. (a subscription can live in more than one folder)
# subscription.tags:<subscription_id> (set)
# 	tags (set)	

# Clients will make conditional GET requests to see if the subscription list has
# changed since the last request was made to reduce bandwith consumption.
# This dataset will store a list of subscription changes per user. The keys will
# be updated whenever a subscription is created/deleted/tagged(put in a folder)/edited
# subscription.changed:<user_id> (zset)
# 	score = datetime
# 	value = <subscription_id>
	
class Subscription
	attr_accessor :html_url
	attr_accessor :feed_url
	attr_accessor :name
	attr_accessor :type
	attr_accessor :tags
	
	extend UserSupport
	extend RedisSupport
	
	def initialize
		self.html_url = params['html_url']
		self.feed_url = params['feed_url']
		self.name = params['name']
		self.type = params['type']
		self.tags = params['tags']
		self.subscription = params['subscription_id']
	end
	
	def self.create_or_update(params)
		html_url = params['html_url']
		feed_url = params['feed_url']
		name = params['name']
		type = params['type']
		tags = params['tags']
		if(!(html_url && feed_url && name && type))
			return nil
		end
		
		# Get the next subscription ID from the system.
		subscription_id = self.redis.incr("subscriptionID")
		params['subscription_id'] = subscription_id
		
		# Store the baic info about the subscription
		self.redis.hmset("subscription:#{subscription_id}", "html_url", html_url, "feed_url", feed_url, "name", name, "type", type)
		
		# Store the tags associated with the subscription
		self.redis.sadd("subscription.tags:#{subscription_id}", tags)
		
		# Add the subscription to the list of subscriptions changed for this user
		self.redis.zadd("subscription.chaged:#{self.user_id}", Date.now.to_s, subscription_id)
		
		subscription = Subscription.new(params)
		return subscription
	end
	
	def self.modified_since(timestamp)
		keys = self.redis.zrange("subscription.changed:#{self.user_id}", timestamp, -1)
		subscriptions = []
		keys.each do |key|
			sub = self.find_by_id(key)
			if(sub)
				subscriptions.push(sub)
			end
		end
		
		return subscriptions
	end
	
	def self.find_by_id(subscription_id)
		values = self.redis.hgetall("subscription:#{subscription_id}")
		puts "#{values}, #{values.class}"
		return self.new(values)
	end
	
	def destroy
		data_key = "subscription:#{self.subscription_Id}"
		changed_key = "subscription.changed:#{self.class.user_id}"
		tags_key = "subscription.tags:#{self.subscription_id}"
		self.redis.del(data_key, tags_key, changed_key)
	end
end
