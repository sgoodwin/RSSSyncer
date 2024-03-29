require './lib/user'
require './lib/redissupport'
require 'json/pure'

# To store the only information we care about a feed's items
# 1) the uid of the item itself
# 2) the status as an 8-bit bitfield to indicate read vs unread as 
#    well as starred and deleted vs saved (with room for new status 
#    meanings in the remaining 5 bits)
# items: (sync of read/unread/starred/deleted/saved status)
# hash_id : md5( datetime + item_id ) (where datetime is a unix timestamp)

# Multiple users could have the same feed in their list and 
# therefore have item status for the same item.
# item:<user_id>:<hash_id> (basic string?)
#		status
# 	item_id

# A client will make conditional GET requests to find what items have changed since
# their last check. This dataset will contain the keys of all items that have changed
# with a score based on the timestamp when the change occured. Each key will be updated
# when the client sends back a list of item changes to record (all at once or individually)
# items.changed:<user_id> (zset)
#		score = datetime
#		value = <hash_id>
	
class Item
	attr_accessor :datetime
	attr_accessor :status
	attr_accessor :item_id
	
	extend RedisSupport
	
	@@maxscore = 0
	def self.maxscore
		@@maxscore
	end
	
	def initialize(params)
		self.datetime = params['datetime'] if params['datetime']
		self.status =  params['status'] if params['status']
		self.item_id = params['item_id'] if params['item_id']
	end
	
	def self.check_status(status)
		return status.to_s.to_i(2) <= 255 && status.to_i >= 0
	end
	
	def self.create_or_update(params)
		datetime = params['datetime'] if params['datetime']
		status = params['status'] if params['status']
		item_id = params['item_id'] if params['item_id']
		if(!(datetime && status && item_id))
			throw(:halt, [400, "You need to supply datetime, status, and item_id for each item!\n"])
		end
		
		throw(:halt, [400, "Status must be a valid 8-bit\n"]) unless check_status(status)
		
		hashed_id = Digest::MD5.hexdigest(datetime.to_s+item_id)
		
		old_items = self.redis.keys("item:#{User.user_id}:*")
				
		# Store the info about the item
		key = "item:#{User.user_id}:#{hashed_id}"
		self.redis.hmset(key, 'status', status, 'item_id', item_id, 'datetime', datetime)
		
		# Add the item to the 'recently changed' sorted set for the user.
		self.redis.zadd("items.changed:#{User.user_id}", datetime, hashed_id)
		
		# If everything works, return an object with the info in it
		item = self.new(params)
		return item
	end
	
	def self.modified_since(timestamp)
		changed_key = "items.changed:#{User.user_id}"
		keys = self.redis.zrange(changed_key, timestamp, -1, :withscores => true)
		items = []
		keys.each do |key|
			if(key.length == 10)
				score = Time.at(key.to_i).to_i
				if(score > @@maxscore)
					@@maxscore = score
				end
			else
				items.push(self.find_by_id(key))
			end
		end
		return items
	end
	
	def self.find_by_id(hash_id)
		values = self.redis.hgetall("item:#{User.user_id}:#{hash_id}")
		if(values)
			return self.new(values)
		end
		
		throw(:halt, [404, "Could not find an item with hashed ID: #{hash_id}\n"]) unless check_status(status)
	end
		
	def to_json(*a)
		{
			"datetime"=>self.datetime,
			"status"=>self.status,
			"item_id"=>self.item_id
		}.to_json(*a)
	end
	
	def to_s
		"<#{self.class}: #{self.datetime}, #{self.item_id} >"
	end
	
	def destroy
		# This should delete any keys created by create_or_update
		hashed_id = Digest::MD5.hexdigest(self.datetime+self.item_id)
		self.redis.del("item:#{User.user_id}:#{hashed_id}", "items.changed:#{User.user_id}")
	end
end
