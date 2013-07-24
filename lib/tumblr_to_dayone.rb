require "tumblr_to_dayone/version"
require 'tumblr_to_dayone/tumblr'
require 'tumblr_to_dayone/dayone'

module TumblrToDayone

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
