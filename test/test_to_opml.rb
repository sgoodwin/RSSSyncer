require '../lib/array+opml'

class ThingWithTags
	def tags
		return ['hi', 'sup']
	end
	
	def name
		"Dude this is an article"
	end
	
	def feed_url
		"http://shutup.com/rss"
	end
	
	def html_url
		"http://shutup.com"
	end
	
	def type
		"RSS"
	end
end

items = []
5.times do
	items.push(ThingWithTags.new)
end

opml = items.to_opml
puts opml