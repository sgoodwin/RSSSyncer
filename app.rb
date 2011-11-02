require 'rubygems'
require 'rdiscount'
require 'sinatra'
require './lib/subscription'
require './lib/item'
require 'json/pure'
require './lib/opmlsupport'
require './lib/helper'

set :show_exceptions, false

get '/' do
	markdown File.read("./README.md")
end

post '/auth' do
	
end

# Items
get '/items.?:format?' do	
	last_modified = request.env['HTTP_IF_MODIFIED_SINCE'] || 0
	items = Item.modified_since(last_modified)
	response.headers['Last-Modified'] = Item.maxscore.to_s
	response.headers['ETag'] = Item.maxscore.to_s
	if(items.empty?)
		304
	else
		return items.to_json
	end
end

get '/items/:item_id.?:format?' do
	item = Item.find_by_id(params[:item_id])
	return item
end

post '/items.?:format?' do
	if(params['items'].nil?)
		throw(:halt, [400, "You need to supply a JSON-formatted array of items!\n"])
	end
	
	items = JSON.parse(params['items'])
	items.each do |item_params|
		item = Item.create_or_update(item_params)
	end
end

put '/items.?:format?' do
	if(params['items'].nil?)
		throw(:halt, [400, "You need to supply a JSON-formatted array of items!\n"])
	end
	items = JSON.parse(params['items'])
	items.each do |item_params|
		item = Item.create_or_update(item_params)
	end
end

# don't think this is necessary
# put '/items/:item_id.?:format?' do
# end

# Subscriptions
get '/subscriptions.?:format?' do
	format = params[:format]
	last_modified = request.env['If-Modified-Since'] || 0
	subscriptions = Subscription.modified_since(last_modified)
	if(subscriptions.empty? && last_modified > 0)
		304
	elsif(last_modified == 0)
		# If they feed a 0, they are starting from scratch and need to know there are no subscriptions.
		return with_format([], format)
	else
		with_format(subscriptions, format)
	end
end

get '/subscriptions/:subscription_id.?:format?' do
	subscription = Subscription.find_by_id(params[:subscription_id])
	return subscription.to_json
end

post '/subscriptions.?:format?' do
	subscription = Subscription.create_or_update(params)
	subscription.to_json
end

put '/subscriptions/:subscription_id.?:format?' do
	subscription = Subscriptions.find_by_id(params[:subscriptions])
	subscription.create_or_update(params)
	subscription.to_json
end

delete '/subscriptions/:subscription_id.?:format?' do
	subscription = Subscription.find_by_id(params[:subscription_id])
	subscription.destroy
	return 200
end
