require 'twitter'

load 'utils.rb'
load 'config.rb'



client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONFIG['twitter-consumer-key']
  config.consumer_secret     = CONFIG['twitter-consumer-secret']
end

count = 0
#lastTweet = nil
lastTweet = nil
#tweet = nil

#Dir.glob("data-scrap/tweet/*").sort.each do |file|
 # tweet = Marshal.load(File.binread(file))
  #lastTweet = tweet
#end

loop do
  begin
    # if lastTweet is not null we search from it
    results = if lastTweet then
      puts "search from #{lastTweet.id } date = #{lastTweet.created_at}"
      client.user_timeline('codelab_fr',count: 30, max_id: lastTweet.id) # get twice same id but integer are 64 bits ... not easy to to -1
    else
      # else we start at the top
      puts "search all"
      client.user_timeline('codelab_fr',count: 30)
    end
    puts "receive #{results.count} new tweets"
    # on result of previous if we print in the console and create a bin file storing the tweet object as is
    results.each do |tweet|
    	puts "saving #{count} id = #{tweet.id} date = #{tweet.created_at}"
        File.binwrite("data-scrap/tweet/#{tweet.id}", Marshal.dump(tweet))
        lastTweet = tweet
        count+=1
        sleep 2
    end
  rescue Twitter::Error::TooManyRequests => error
    p error
  rescue Twitter::Error::RequestTimeout => error
    p error
  end
  sleep 2
end

