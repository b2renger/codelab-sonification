require 'twitter'
require 'json'

load 'utils.rb'
load 'config.rb'

tweet_count = 0 # keep track of the number of tweets
jsonHash = [] # empty hash for the info we wan to write
last_hour = 0 # keep track of last tweet's hour
ntweet =1 # keep track of the number of tweets within an hour

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONFIG['twitter-consumer-key']
  config.consumer_secret     = CONFIG['twitter-consumer-secret']
end

Dir.glob("data-scrap/tweet/*").sort.each do |file|  # iterate through all the files in tweet folder
	tweet = Marshal.load(File.binread(file))
	puts "reading #{tweet_count} id = #{tweet.id} date = #{tweet.created_at}"

	hour = tweet.created_at.hour;
	
	if last_hour == hour # check the hour
		ntweet += 1
	else # if not the same write new entry
	newHash = {
		:count => "#{ntweet}",
		:id => "#{tweet.id}",
		:date => "#{tweet.created_at}"
	}
	# reset stuff
	last_hour = hour
	ntweet = 1
	# add the new entry to the main hash
	jsonHash << newHash
	end
	tweet_count += 1
end

# write everything
File.write("list-test.json",JSON.pretty_generate(jsonHash))
