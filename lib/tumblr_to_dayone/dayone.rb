require 'shellwords'

module Dayone
	
  def self.cli_installed?
    `which dayone`.length > 0
  end

  #   options:
  #
  # date          - Creation date of the entry
  # starred       - Whether or not to star the entry
  # photo_path    - File path to a photo to attach to entry
  # journal_path  - Location of Day One Journal file
  #

  def self.create_post(post, options = {})
    return false unless Dayone.cli_installed? && post

    arguments = {
      :d => options[:date],
      :s => options[:starred],
      :p => options[:photo_path],
      :j => options[:journal_path]
    }.map { |k,v| "-#{k}=\"#{v}\"" unless !v }.compact.join(" ")
    
    output = `echo #{Shellwords.escape(post)} | dayone #{arguments} new`
    
    output.start_with?("New entry")
  end

end