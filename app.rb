require 'rubygems'
require 'rdiscount'
require 'sinatra'
require './lib/subscription'
require './lib/item'
require 'json/pure'
require './lib/opmlsupport'
require './lib/helper'

set :show_exceptions, false
helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    if(@auth.provided? && @auth.basic? && @auth.credentials)
			User.auth(@auth.credentials[0], @auth.credentials[1])
		end
  end
end


get '/' do
	markdown File.read("./README.md")
end

post '/signup' do
	puts params.inspect
	User.sign_up(params[:username], params[:password])
	
	200
end

# Items
get '/items.?:format?' do	
	protected!
	
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
	protected!
	
	item = Item.find_by_id(params[:item_id])
	return item
end

post '/items.?:format?' do
	protected!
	
	if(params['items'].nil?)
		throw(:halt, [400, "You need to supply a JSON-formatted array of items!\n"])
	end
	
	items = JSON.parse(params['items'])
	items.each do |item_params|
		item = Item.create_or_update(item_params)
	end
end

put '/items.?:format?' do
	protected!
	
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
	protected!
	
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
	protected!
	
	subscription = Subscription.find_by_id(params[:subscription_id])
	return subscription.to_json
end

post '/subscriptions.?:format?' do
	protected!
	
	subscription = Subscription.create_or_update(params)
	subscription.to_json
end

put '/subscriptions/:subscription_id.?:format?' do
	protected!
	
	subscription = Subscriptions.find_by_id(params[:subscriptions])
	subscription.create_or_update(params)
	subscription.to_json
end

delete '/subscriptions/:subscription_id.?:format?' do
	protected!
	
	subscription = Subscription.find_by_id(params[:subscription_id])
	subscription.destroy
	return 200
end
