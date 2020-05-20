#!/usr/bin/env ruby

require 'uri'
include 'lib'

Versions = Struct.new(:a, :b, :c) do
  def x
    a + b * c
  end
end

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
ruby = Ruby.new("latest")
versions = Versions.new(1, 2, 3)
ruby.to_h.each do |key, value|
  if value == nil
    puts "Oops"
  else
    arr << {
      'name' => key,
      'value' => value
    }
  end
end
puts versions&.x&.odd? # would be nice to highlight safe nagivation operator

printer = ->(item) { puts item }
arr.each(&printer)
