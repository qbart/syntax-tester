require 'uri'

Language = Class.new

class Ruby < Language
  attr_reader :name

  def initialize(name)
    @name = name
    @version = 3
    @arr = %w[one two three]
  end

  def each
    @version.times { |ver| yield ver } if block_given?
  end

  def to_h
    {
      name: name,
      version: @version,
      at: Time.now
    }
  end
  
  def matches?
    name =~ /World/i
  rescue => e # always use explicit class error
    false
  end

  def to_s
    "Hello #{name}"
  end
end

arr = []
Ruby.new("test").to_h.each do |key, value|
  if value == nil 
    puts "Oops"	
  else
    arr << {
      'name' => key,
      'value' => value
    }
  end
end

printer = ->(item) { puts item }
arr.each(&printer)
