require 'cgi'
require 'reverse_markdown'

module Tumblr
  class Post
  	attr_accessor :type, :created_at, :title, :body, :photo_url, :photo_caption, :tags

  	def initialize(post_hash)
      self.type = post_hash["type"]
      self.created_at = Time.at(post_hash["unix-timestamp"] || Time.now.to_i)
      self.title = post_hash["regular-title"]
      self.body = convert_to_markdown(post_hash["regular-body"])
      self.photo_url = largest_photo_url(post_hash)
      self.photo_caption = convert_to_markdown(post_hash["photo-caption"])
      self.tags = post_hash["tags"] || []
  	end

    def full_body
      [
        self.title ? "# #{self.title}" : nil,
        self.body ? self.body : nil,
        self.photo_caption ? self.photo_caption : nil,
        self.tags ? self.tags.map {|tag| "\\##{tag}"}.join(" ") : nil
      ].compact.join("\n\n")
    end

    def to_s
      "Tumblr post created on #{self.created_at}\ntitle: #{self.title ? self.title : "<no title>"}\nphoto: #{!!self.photo_url}\nbody:\n#{self.full_body}\n"
    end

    private

      PHOTO_URL_KEY_PREFIX = "photo-url-"

      def largest_photo_url(post_hash)
        largest_width = post_hash.keys.map{ |key| key.match(PHOTO_URL_KEY_PREFIX) ? key.gsub(PHOTO_URL_KEY_PREFIX, "").to_i : nil }.compact.max

        largest_width ? post_hash["#{PHOTO_URL_KEY_PREFIX}#{largest_width}"] : nil
      end

      def convert_to_markdown(content)
        return nil unless content

        ReverseMarkdown.parse(CGI.unescapeHTML(content))
      end

  end
end
