class Hash
	def to_opml
		result = []
		result.push("<?xml version=\"1.0\" encoding=\"UTF-8\"")
		result.push('<!-- OPML generated by RSSSyncer -->')
		result.push('<opml version="1.1">')
		result.push('<head>')
		result.push('<title>MySubscriptions</title>')
		result.push('</head>')
		result.push('<body>')

		self.keys.each do |key|
			result.push("<outline text=\"#{key}\" title=\"#{key}\">")

			self[key].each do |item|
				if(item.respond_to?(:feed_url) && item.respond_to?(:name) && item.respond_to?(:type) && item.respond_to?(:html_url))
					result.push("<outline text=\"#{item.name}\" description=\"\" title=\"#{item.name}\" type=\"#{item.type}\" version=\"#{item.type}\" htmlUrl=\"#{item.html_url}\" xmlUrl=\"#{item.feed_url}\"/>")
				end
			end

			result.push('</outline>')
		end

		result.push('</body>')
		result.push('</opml>')
		return result.join("\n")
	end
end

class Array
	def to_opml
		# It is probably easier to do this with an xml templating engine, but this way results in 0 dependencies, so I'm
		# ok with it for now.

		items_by_tag = {}
		self.each do |item|
			if(item.respond_to?(:tags))
				item.tags.each do |tag|
					items_by_tag[tag] = items_by_tag[tag] || []
					items_by_tag[tag].push(item)
				end
			end
		end

		items_by_tag.to_opml
	end
end

# example OPML with folders:
# 
# <?xml version="1.0" encoding="UTF-8"?>
# <!-- OPML generated by NetNewsWire -->
# <opml version="1.1">
# 	<head>
# 		<title>mySubscriptions</title>
# 		</head>
# 	<body>
# 		<outline text="Web" title="Web">
# 			<outline text="blog.nodejitsu.com" description="" title="blog.nodejitsu.com" type="rss" version="RSS" htmlUrl="http://blog.nodejitsu.com" xmlUrl="http://blog.nodejitsu.com/feed.xml"/>
# 		</outline>
# 		<outline text="Skate" title="Skate">
# 			<outline text="118" description="" title="118" type="rss" version="RSS" htmlUrl="http://sorcery118.blogspot.com/" xmlUrl="http://sorcery118.blogspot.com/feeds/posts/default"/>
# 		</outline>
# 		<outline text="Apple Dev" title="Apple Dev">
# 			<outline text="Alan Quatermain" description="" title="Alan Quatermain" type="rss" version="RSS" htmlUrl="http://quatermain.tumblr.com/" xmlUrl="http://feeds.feedburner.com/AlanQuatermain"/>
# 		</outline>
# 		<outline text="Main" title="Main">
# 			<outline text="43 Folders - Time, Attention, and Creative Work" description="" title="43 Folders - Time, Attention, and Creative Work" type="rss" version="RSS" htmlUrl="http://www.43folders.com" xmlUrl="http://www.43folders.com/rss.xml"/>
# 		</outline>
# 		<outline text="Comics" title="Comics">
# 			<outline text="FoxTrot.com" description="" title="FoxTrot.com" type="rss" version="RSS" htmlUrl="http://www.foxtrot.com" xmlUrl="http://www.foxtrot.com/feed/"/>
# 			<outline text="The Oatmeal - Comics, Quizzes, &amp; Stories" description="" title="The Oatmeal - Comics, Quizzes, &amp; Stories" type="rss" version="RSS" htmlUrl="http://theoatmeal.com/" xmlUrl="http://theoatmeal.com/feed/rss"/>
# 			<outline text="xkcd.com" description="" title="xkcd.com" type="rss" version="RSS" htmlUrl="http://xkcd.com/" xmlUrl="http://syndicated.livejournal.com/xkcd_rss/data/rss"/>
# 			</outline>
# 	</body>
# </opml>
