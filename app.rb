require 'rubygems'
require 'sinatra'
require 'lib/subscription'
require 'lib/item'
require 'json/pure'

set :show_exceptions, false

get '/' do
	"hello world"
end

# Items
get '/items.?:format?' do
	last_modified = request.env['If-Modified-Since'] || 0
	items = Item.modified_since(last_modified)
	if(items.empty?)
		304
	else
		return items.join(', ')
	end
end

get '/items/:item_id.?:format?' do
	item = Item.find_by_id(params[:item_id])
	return item
end

post '/items.?:format?' do
	success = true
	puts params.keys
	items = JSON.parse(params['items'])
	items.each do |item_params|
		item = Item.create_or_update(item_params)
		if(!item)
			success = false
			break
		end
	end
	
	if(success)
		200
	else
		400
	end
end

put '/items.?:format?' do
	success = true
	params['items'].each do |item_params|
		item = Item.create_or_update(item_params)
		if(!item)
			success = false
		end
	end
	
	if(success)
		200
	else
		400
	end
end

# don't think this is necessary
# put '/items/:item_id.?:format?' do
#	item = Item.find_by_id(params[:item_id])
#	if(item)
#		return item
#	else
#		400
#	end
# end

# Subscriptions

get '/subscriptions.?:format?' do
	last_modified = request.env['If-Modified-Since'] || 0
	subscriptions = Subscription.modified_since(last_modified)
	if(subscriptions.empty?)
		304
	else
		return subscriptions.join(', ')
	end
end

get '/subscriptions/:subscription_id.?:format?' do
	subscription = Subscription.find_by_id(params[:subscription_id])
	if(subscription)
		return subscription
	else
		404
	end		
end

post '/subscriptions.?:format?' do
	subscription = Subscription.create_from_params(params)
	if(subscription)
		subscription
	else
		400
	end
end

put '/subscriptions/:subscription_id.?:format?' do
	subscription = Subscriptions.find_by_id(params[:subscriptions])
	if(!subscription)
		404
	end
	
	subscription.update_with_params(params)
	subscription
end

delete '/subscriptions/:subscription_id.?:format?' do
	subscription = Subscriptions.find_by_id(params[:subscriptions])
	if(!subscription)
		404
	end
	
	subscription.destroy
	200
end
