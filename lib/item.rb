require 'lib/usersupport'
require 'lib/redissupport'

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
	
	extend UserSupport
	extend RedisSupport
	
	def initialize(params)
		self.datetime = params['datetime']
		self.status = params['status']
		self.item_id = params['item_id']
	end
	
	def self.create_or_update(params)
		datetime = params['datetime']
		status = params['status']
		item_id = params['item_id']
		if(!(datetime && status && item_id))
			return nil
		end
		
		hashed_id = Digest::MD5.hexdigest(datetime.to_s+item_id)
		
		# Store the info about the item
		self.redis.hmset("item:#{self.user_id}:#{hashed_id}", 'status', status, 'item_id', item_id)
		
		# Add the item to the 'recently changed' sorted set for the user.
		self.redis.zadd("items.changed:#{self.user_id}", datetime, hashed_id)
		
		# If everything works, return an object with the info in it
		item = self.new(params)
		return item
	end
	
	def self.modified_since(timestamp)
		keys = self.redis.zrange("item.changed:#{self.user_id}", timestamp, -1)
		items = []
		keys.each do |key|
			items.push(self.find_by_id(key))
		end
		return items
	end
	
	def self.find_by_id(hash_id)
		values = self.redis.hgetall("item:1:#{hash_id}")
		puts "#{values}, #{values.class}"
		return self.new(values)
	end
		
	def destroy
		# This should delete any keys created by create_or_update
		hashed_id = Digest::MD5.hexdigest(self.datetime+self.item_id)
		self.redis.del("item:#{self.user_id}:#{hashed_id}", "items.changed:#{self.user_id}")
	end
end
