#! /usr/bin/env ruby

require_relative 'spellcheck'

a = SpellCheck.new
# from http://blog.afterthedeadline.com/2010/07/20/after-the-deadline-bigram-corpus-our-gift-to-you/
a.parse_unigrams 'unigrams.txt'
print 'Enter a word: '
input = gets.chomp
puts a.correct input