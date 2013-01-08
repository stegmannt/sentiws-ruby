# encoding: utf-8
require 'singleton'

module SentiWS
  SENTIWS_POS_FILE = "../SentiWS/SentiWS_v1.8c_Positive.txt"
  SENTIWS_NEG_FILE = "../SentiWS/SentiWS_v1.8c_Negative.txt"
  class Wort
    attr_accessor :wort,:weight,:pos,:inflections
    
    def initialize(wort,weight,pos,inflections)
      @wort,@weight,@pos,@inflections = wort,weight,pos,inflections
    end
    
    def self.parse(string)
     data = /([\wäöüßÄÖÜ]+)\|([A-Z]+)\s+(\-?\d\.\d+)\s*+([\wäöüßÄÖÜ,]+)?/.match(string)
     raise ArgumentError, "No SentiWS string: #{string}" unless data
     
     inflections = data[4] ? data[4].split(',') : nil
     Wort.new(data[1],data[3].to_f,data[2],inflections)
    end
  end
  
  class Wortschatz
    include Singleton
    attr_accessor :woerter,:negation
    
    def initialize
      @woerter = Hash.new
    end
    
    def self.parse
	sentiws = Wortschatz.instance
	
	#parse positive words
	file = File.new(SENTIWS_POS_FILE, 'r')
	while (line = file.gets)
	  wort = Wort.parse(line)
	  sentiws.woerter[wort.wort] = wort
	  wort.inflections.each { |i| sentiws.woerter[i] = wort} if wort.inflections
	end
	file.close
	
	#parse negative words
	file = File.new(SENTIWS_NEG_FILE, 'r')
	while (line = file.gets)
	  wort = Wort.parse(line)
	  sentiws.woerter[wort.wort] = wort
	  wort.inflections.each { |i| sentiws.woerter[i] = wort} if wort.inflections
	end
	file.close
	return sentiws
    end      
  end
end
