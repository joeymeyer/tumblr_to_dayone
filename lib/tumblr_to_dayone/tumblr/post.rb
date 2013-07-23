require 'cgi'
require 'reverse_markdown'

module Tumblr
  class Post
  	attr_accessor :type, :created_at, :title, :body, :photo_url, :tags

  	def initialize(post_hash)
      self.type = post_hash["type"]
      self.created_at = Time.at(post_hash["unix-timestamp"] || Time.now.to_i)
      self.title = post_hash["regular-title"]
      self.body = ReverseMarkdown.parse(CGI.unescapeHTML(post_hash["regular-body"] || post_hash["photo-caption"] || ""))
      self.photo_url = largest_photo_url(post_hash)
      self.tags = post_hash["tags"] || []
  	end

    private

      PHOTO_URL_KEY_PREFIX = "photo-url-"

      def largest_photo_url(post_hash)
        largest_width = post_hash.keys.map{ |key| key.match(PHOTO_URL_KEY_PREFIX) ? key.gsub(PHOTO_URL_KEY_PREFIX, "").to_i : nil }.compact.max

        largest_width ? post_hash["#{PHOTO_URL_KEY_PREFIX}#{largest_width}"] : nil
      end

  end
end
