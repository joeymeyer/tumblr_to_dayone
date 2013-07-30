require 'cgi'
require 'reverse_markdown'

module Tumblr
  class Post
  	attr_accessor :type, :created_at, :title, :body, :photo_url, :video_player, :caption, :tags

  	def initialize(post_hash)
      self.type = post_hash["type"]
      self.created_at = Time.at(post_hash["unix-timestamp"] || Time.now.to_i)
      self.title = post_hash["regular-title"]
      self.body = convert_to_markdown(post_hash["regular-body"]) || link_markdown(post_hash["link-text"], post_hash["link-url"])
      self.photo_url = largest_photo_url(post_hash)
      self.video_player = post_hash["video-player"]
      self.caption = convert_to_markdown(post_hash["photo-caption"] || post_hash["video-caption"])
      self.tags = post_hash["tags"] || []
  	end

    def full_body
      [
        self.title ? "# #{self.title}" : nil,
        self.video_player ? video_player : nil,
        self.body ? self.body : nil,
        self.caption ? self.caption : nil,
        self.tags && !self.tags.empty? ? self.tags.map {|tag| "\\##{tag}"}.join(" ") : nil
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

      def link_markdown(link_text, link_url)
        return nil unless link_text && link_url

        "[#{link_text}](#{link_url})"
      end

  end
end
