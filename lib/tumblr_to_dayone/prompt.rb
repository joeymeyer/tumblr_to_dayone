require 'tumblr_to_dayone'

module TumblrToDayone
  module Prompt

    def self.start
      if Dayone.cli_installed?
        puts "What is the name of your tumblr blog? (<name>.tumblr.com)"
        blog_name = gets.chomp

        puts "What is the password of your tumblr blog? (leave blank if none)"
        password_input = gets.chomp
        blog_password = password_input unless password_input.empty?

        puts "Automatically add all blog posts? (y/n)"
        automatic = gets.chomp == 'y'

        puts "What is the location of your Dayone.journal? (leave blank if it is in the default location)"
        journal_path_input = gets.chomp
        journal_path = journal_path_input unless journal_path_input.empty?
        
        TumblrToDayone.add_tumblr_posts_to_dayone(blog_name, :password => blog_password, :automatically_add_each_post => automatic, :journal_path => journal_path) do |post|
          puts "- " * 30
          puts post
          puts "- " * 30
          puts "Would you like to add this post to Day One? (y: yes, s: yes and star it, n: no, exit: exit the prompt)"
          gets.chomp.downcase.to_sym
        end

        puts "Done."
      else
        puts "Download and install Day One CLI to continue. (http://dayoneapp.com/tools/)"
      end
    end

  end
end