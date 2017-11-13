#!/usr/bin/env ruby
require 'json'

class Array
  def to_csv(csv_filename="hash.csv")
    require 'csv'
    CSV.open(csv_filename, "wb") do |csv|
      csv << first.keys # adds the attributes name on the first line
      self.each do |hash|
        csv << hash.values
      end
    end
  end
end

JSON[ARGF.read].to_csv("trello.csv")
puts File.read("./trello.csv")
