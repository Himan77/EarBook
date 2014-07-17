
require 'rubygems'
gem 'google-api-client', '>0.7'
require 'google/api_client'
require 'trollop'
require 'json'
require 'net/http'
require 'open-uri'
require 'debugger'

# Set DEVELOPER_KEY to the API key value from the APIs & auth > Credentials
# tab of
# Google Developers Console <https://console.developers.google.com/>
# Please ensure that you have enabled the YouTube Data API for your project.
DEVELOPER_KEY = 'AIzaSyDWpEV4xe5lYSgne7FbVlGyaAzSQ1l584w'
YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'

def get_service
	client = Google::APIClient.new(
		:key => DEVELOPER_KEY,
		:authorization => nil,
		:application_name => 'youtube views',
		:application_version => '1.0.0'
		)
	youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

	return client, youtube
end

def main
	

	client, youtube = get_service

	begin
    # Call the search.list method to retrieve results matching the specified
    # query term.
	    File.open("public/data/playlist", "rb") do |f|
	    	out_file = File.new("public/data/out.txt", "w")
	    	f.each_line do |line|
	    		line.delete!("\n")
	    		puts line
	    		if line == "" 
	    		    break
	    		end
	    			

	    		search_response = client.execute!(
	    			:api_method => youtube.search.list,
	    			:parameters => {
	    				:part => 'snippet',
	    				:q => line,
	    				:maxResults => 10
	    			}
	    			)

	    		#videos = []


		    # Add each result to the appropriate list, and then display the lists of
		    # matching videos, channels, and playlists.
		        max_views = 0 
		        views = 0
		        correct_video_id= ""
		        video_id= ""
		        
			    search_response.data.items.each do |search_result|
			    	

			    	if max_views<views 
			    		max_views = views
			    		correct_video_id = video_id
			    	end
			      #puts "#{search_result.id.videoId}"
				    
				    
				    case search_result.id.kind
				        when 'youtube#video'
				          video_id = "#{search_result.id.videoId}"
			    		  puts video_id
			    	      content = open("http://gdata.youtube.com/feeds/api/videos/"+video_id+"?v=2&alt=json").read
			    		  parsed = JSON.parse(content)
			    		  views = parsed['entry']['yt$statistics']['viewCount'].to_i
			    	      puts views
				          #videos << "#{search_result.snippet.title} (#{search_result.id.videoId})"
				    end


				  
			    end
			    #puts "Videos:\n", videos, "\n"
			    
			    out_file.puts(line + "," + max_views.to_s + "," + correct_video_id)
			    
			    puts max_views.to_s + "," + correct_video_id

			end
			out_file.close
		end

			   # puts "Channels:\n", channels, "\n"
			   # puts "Playlists:\n", playlists, "\n"
	rescue Google::APIClient::TransmissionError => e
				  puts e.result.body
	end

	    	
end

main
