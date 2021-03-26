#!/usr/bin/env ruby

require 'uri'
include 'lib'

puts __FILE__

$globals_are_evil = STDIN

Versions = Struct.new(:a, :b, :c) do
  def x
    a + b * c
  end
end

Language = Class.new

class Langs::Ruby < Language
  include Comparable

  attr_reader :name

  def initialize(name)
    @name = name
    @version = 3
    @litarr = [1, 2, 3]
    @arr = %w[one two three]
    @s = <<~HEREDOC
    HEREDOC
  end

  def each
    @version.times { |ver| yield ver } if block_given?
  end

  def to_h
    {
      name: name,
      version: @version,
      at: Time.now,
      num: 3,
      other: 2.15,
      bool: true,
      empty: nil,
      short: "hello",
      long: "world"
    }
  end

  def keyowrds(hello: "world", *splat, **splat2)
    if block_given?
      yield User.where("name = :name", name: "John")
    end
  end

  def matches?
    name =~ /World/i
  rescue => e # always use explicit class error
    false
  end
  
  def <=>(other)
    self.name <=> other.name
  end

  def to_s
    "Hello #{name}"
  end

  private 

  def base!; super; end
end

arr = []
ruby = Ruby.new("latest")
versions = Versions.new(1, 2, 3)
ruby.to_h.each do |key, value|
  if value == nil && true
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
puts arr.map(&:to_s)
