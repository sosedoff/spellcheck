require 'redis'

class SpellCheck
  ALPHABET = ('a'..'z').to_a.join.freeze
  
  private
  
  def forms(word)
    n = word.length
    deletion = (0...n).collect { |i| word[0...i] + word[i+1..-1] }
    transposition = (0...n-1).collect { |i| word[0...i] + word[i+1,1] + word[i,1] + word[i+2..-1] }
    alteration = []
    n.times {|i| ALPHABET.each_byte { |l| alteration << word[0...i] + l.chr + word[i+1..-1] } }
    insertion = []
    (n+1).times { |i| ALPHABET.each_byte { |l| insertion << word[0...i] + l.chr + word[i..-1] } }
    result = deletion + transposition + alteration + insertion
    result.empty? ? nil : result
  end
  
  def known(words)
    result = words.find_all { |w| @redis.exists(w) }
    result.empty? ? nil : result
  end
  
  def known_forms(word)
    result = []
    forms(word).each { |f1| result << f1 if @redis.exists(f1) }    
    result.empty? ? nil : result
  end
end

class SpellCheck
  CACHE_KEY = '_phrase_cache'
  
  attr_reader :redis
    
  def initialize(client, opts={})
    raise ArgumentError, 'Redis object instance required!' unless client.kind_of?(Redis)
    @db = Hash.new(1)
    @redis = client
    @redis.select(opts[:db]) if opts.key?(:db)
  end
  
  def flush
    @redis.flushdb
  end
  
  def load_source(path)
    raise ArgumentError, "Input file required!" if path.nil?
    raise ArgumentError, "File #{path} does not exist!" unless File.exists?(path)
    raise ArgumentError, "File #{path} is not readable!" unless File.readable?(path)
    
    content = File.new(path).read.downcase
    words = content.scan(/[a-z]+/)
    words.each { |w| @redis.incr(w) }
  end
    
  def correct(word)
    (known([word]) or known(forms(word)) or known_forms(word) or [word]).max {|a,b| @redis[a] <=> @redis[b] } 
  end
  
  def correct_phrase(phrase)
    unless @redis.hexists(CACHE_KEY, phrase)
      str = phrase.strip.split(' ').collect { |w| correct(w) }.join(' ')
      @redis.hset(CACHE_KEY, phrase, str)
      return str
    else
      @redis.hget(CACHE_KEY, phrase)
    end
  end
end