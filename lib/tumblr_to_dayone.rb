require "tumblr_to_dayone/version"
require 'tumblr_to_dayone/tumblr'
require 'tumblr_to_dayone/dayone'

module TumblrToDayone

  #   options:
  #
  # password                    - Password for blog (if there is one)
  # filter                      - Only get Tumblr posts based on type (text, quote, photo, link, chat, video, or audio)
  # automatically_add_each_post - Automatically add each Tumblr post or ask before adding each one (defaults to false)
  # journal_path                - Location of Day One Journal file
  #

  def self.add_tumblr_posts_to_dayone(blog, options={})
    begin
      post_index = 0
      no_more_posts = false

      while !no_more_posts
        Tumblr.posts(blog, password = options[:password], :start => post_index, :type => options[:filter]) do |posts, total_posts|
          post_index += posts.count
          no_more_posts = posts.empty? || post_index >= total_posts

          exited = false

          posts.each do |post|
            unless exited
              post_status = options[:automatically_add_each_post] ? :yes : yield(post)
              
              if post_status == :yes || post_status == :star
                post_created = post.add_to_dayone!(starred = post_status == :star, dayone_journal = options[:journal_path])

                puts "ERROR: There was a problem adding the post." unless post_created
              elsif post_status == :exit
                exited = true
                no_more_posts = true
              end
            end
          end
        end
      end
    rescue TumblrPostsAPIError => e
      puts e.message
    end
  end

end

module Tumblr
  class Post

    def add_to_dayone!(starred = false, dayone_journal = nil)

      post_created = false

      photo = nil

      begin

        if self.photo_url
          photo = Tempfile.new(["#{self.photo_url.hash}", File.extname(self.photo_url)])
          photo.open
          photo.write open(self.photo_url).read
          photo.close
        end

        post_created = Dayone.create_post(self.full_body,
          :date => self.created_at,
          :starred => starred,
          :photo_path => photo ? photo.path : nil,
          :journal_path => dayone_journal
        )

      ensure
        if photo
          photo.close
          photo.unlink
        end
      end

      post_created
    end

  end
end
