require 'twitter'

load 'utils.rb'
load 'config.rb'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONFIG['twitter-consumer-key']
  config.consumer_secret     = CONFIG['twitter-consumer-secret']
end

class Model
	attr_accessor :tweets, :users, :hashtags
end

class User
	attr_accessor :tweets, :mentioned, :hashtags, :favorites
end


tweet_count = 0

tweets = []

hashtag_tweets = {}

mentions = {}

authors = []

retweeted_authors = []

Dir.glob("data-scrap/tweet/*").sort.each do |file|
	tweet = Marshal.load(File.binread(file))
	tweet_count += 1
	
	tweets << tweet

	tweet.hashtags.each{|hashtag|
		hashtag_tweets[hashtag.text] = [] if not hashtag_tweets.has_key?(hashtag.text)
		hashtag_tweets[hashtag.text] << tweet +=
	}
	tweet.user_mentions.each{|um|
		mentions[um.id] = [] if not mentions.has_key?(um.id)
		mentions[um.id] << tweet 
	}

	authors << tweet.user.id if not tweet.retweet?
	retweeted_authors << tweet.retweeted_tweet.user.id if tweet.retweet?

end

authors.uniq!
retweeted_authors.uniq!

hashtags = tweets.map{|tweet| tweet.hashtags.map{|ht| ht.text}}.flatten(1).uniq

profiles = (authors + mentions.keys + retweeted_authors).uniq

text_sizes = tweets.map{|tweet| tweet.full_text.length}

puts
puts "Entities :"
puts
puts "- tweets : #{tweets.size}"
puts "    - retweet : #{tweets.select{|tweet| tweet.retweet?}.size}"
puts "    - retweeted : #{tweets.select{|tweet| tweet.retweeted?}.size}"
puts "    - favorited : #{tweets.select{|tweet| tweet.favorited?}.size}"
puts "- hashtags : #{hashtags.size}"
puts "- profiles : #{profiles.size}"
puts "    - authors : #{authors.size}"
puts "    - mentioned : #{mentions.keys.size}"
puts "    - retweeted : #{retweeted_authors.size}"

puts
puts "- retweet"
tweets.group_by{|tweet| tweet.retweet_count}.sort.each{|n, list|
	puts "    - tweets retweeted #{n} times : #{list.size} #{list.first.id}"
}

puts
puts "- tweet => mention : "
tweets.group_by{|tweet| tweet.user_mentions.size}.sort.each{|n, list|
	puts "    - tweets with #{n} mentions : #{list.size}"
}

puts
puts "- profile => mentioned => tweet : "
mentions.group_by{|key, list| list.size}.sort.each{|n, list|
	puts "    - users mentioned in only #{n} tweets : #{list.size}"
}

puts
puts "- tweet => hashtag : "
tweets.group_by{|tweet| tweet.hashtags.size}.sort.each{|n, list|
	puts "    - tweets with #{n} hashtags : #{list.size}"
}

puts
puts "- hashtag => tweet : "
hashtag_tweets.group_by{|key, list| list.size}.sort.each{|n, list|
	puts "    - hashtags in only #{n} tweets : #{list.size}"
}

puts
puts "- author => tweet : "
tweets.group_by{|tweet| tweet.user.id}.group_by{|author, list| list.size}.sort.each{|n, list|
	puts "    - authors with #{n} tweets : #{list.size}"
}

puts
puts "- author => retweetd : "
tweets.select{|tweet| tweet.retweet?}.group_by{|tweet| tweet.retweeted_tweet.user.id}.group_by{|author, list| list.size}.sort.each{|n, list|
	puts "    - authors with #{n} tweet retweeted : #{list.size}"
}

puts
puts "- tweet contents :"
puts "    - min #{text_sizes.sort.first}"
puts "    - max #{text_sizes.sort.last}"
puts "    - average #{text_sizes.inject{|sum,x| sum + x } / text_sizes.size}"

puts
puts "biggest tweet : "
puts tweets.group_by{|tweet| tweet.full_text.length}.sort.last.last.first.full_text

puts
puts "- Reply : #{tweets.select{|tweet| tweet.in_reply_to_user_id?}.size}"

tweets.select{|tweet| tweet.in_reply_to_user_id?}.group_by{|tweet| tweet.in_reply_to_user_id}.group_by{|author, list| list.size}.sort.each{|n, list|
	puts "    - authors with #{n} reply : #{list.size}"
}

puts 
puts "Most retweeted  : "
tweets.sort_by{|tweet| tweet.retweet_count}.reverse.first(30).each{|tweet|
	puts "    - retweeted #{tweet.retweet_count} times id(#{tweet.id}) : #{tweet.full_text}"
	puts 
	puts
}
