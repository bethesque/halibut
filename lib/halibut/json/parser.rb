module Halibut
  module JSON

    # Halibut::XML::Parser is the class responsible for parsing JSON strings
    # into an Halibut::HAL::Resource.
    #
    class Parser
      require 'json'
      
      # Class method, obviously.
      # Returns a new document.
      def self.parse document
        Parser.new document
      end
      
      # Inits the parser.
      # +json+ JSON-encoded string
      def initialize(json)
        json = ::JSON.parse json
        @doc = Halibut::HAL::Resource.new json['_links']['self']['href']
        
        parse_links      json.delete '_links'
        parse_resources  json.delete '_embedded'
        # parse_attributes json
      end
      
      private
      def parse_links links
        parsed = []
        
        links.each_pair do |k,v|
          href = v.delete 'href'

          parsed << Halibut::HAL::Link.new(k, href, v)
        end
        
        parsed
      end
      
      def parse_resources resources
        resources.each_pair do |rel, items|
          items.each do |item|
          end
        end
      end
      
      def parse_resource resource
      end
      
      def parse_attributes attributes
        attributes.reject {|it| it == '_links' || it == '_embedded' }.each do |attribute|
          @doc.set attribute
        end
      end
      
    end
    
  end
end