require 'json'
require 'net/http'
require 'tumblr_to_dayone/tumblr/post'

module Tumblr

  #   options:
  #
  # start  - The post offset to start from. The default is 0.
  # num 	 - The number of posts to return. The default is 20, and the maximum is 50.
  # type   - The type of posts to return. If unspecified or empty, all types of posts are returned. Must be one of text, quote, photo, link, chat, video, or audio.
  # id     - A specific post ID to return. Use instead of start, num, or type.
  # filter - Alternate filter to run on the text content. Allowed values:
  #            text: Plain text only. No HTML.
  #            none: No post-processing. Output exactly what the author entered. (Note: Some authors write in Markdown, which will not be converted to HTML when this option is used.)
  # tagged - Return posts with this tag in reverse-chronological order (newest first). Optionally specify chrono=1 to sort in chronological order (oldest first).
  # search - Search for posts with this query.
  #

  def self.posts(title, password = nil, options = {})
    uri = URI.parse("http://#{title}.tumblr.com/api/read/json")
    
    options.delete_if { |k,v| v.nil? }

    uri.query = URI.encode_www_form(options)

    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth title, password if password

    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      body = JSON.parse(response.body[22..-3])

      total_posts = body["posts-total"].to_i
      post_hashes = body["posts"]

      posts = post_hashes.map { |post_hash| Tumblr::Post.new(post_hash) }

      if block_given?
        yield posts, total_posts
      else
        posts
      end
    else
      raise TumblrPostsAPIError, "Failed to get posts, server returned #{response.code} #{response.message}"
    end
  end

end

class TumblrPostsAPIError < StandardError

end
