def with_format(items, format)
	if(format == 'json')
		return items.to_json
	elsif(format)
		return items.to_opml
	end
end