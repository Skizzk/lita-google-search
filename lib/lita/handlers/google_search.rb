require 'google-search'

module Lita
  module Handlers
    class GoogleSearch < Handler
      # insert handler code here
      route(/g(oogle)?\s+(?<me>me\s+)?(?<terms>.*)/, :google_search, command: true, help:{
        "google smthg" => "google search something (alias g smthg)",
        "google me smthg" => "google search something and reply privately (alias g me smthg)",
      })

      def google_search(r)
        print_search(r, Google::Search::Web)
      end
      
      route(/(image|img)\s+(?<me>me\s+)?(?<terms>.*)/, :image_search, command: true, help:{
        "image smthg" => "google image search something (alias img smthg)",
        "image me smthg" => "google image search something and reply privately (alias img me smthg)",
      })

      def image_search(r)
        print_search(r, Google::Search::Image)
      end

      route(/(yt|youtube)\s+(?<me>me\s+)?(?<terms>.*)/, :youtube_search, command: true, help: {
        "youtube smthg" => "youtube image search something (alias yt smthg)",
        "youtube me smthg" => "youtube search something and reply privately (alias yt me smthg)",
      })

      def youtube_search(r)
        print_search(r, Google::Search::Video)
      end

      private

      def print_search(r, clazz)
        result = clazz.new(:query => r.match_data[:terms]).first
        r.send(answering_method(r), "#{r.user.name}: #{result.title.gsub(/<[^>]*>/,"").gsub(/\s\s+/," ")} ( #{result.uri} )")
        r.send(answering_method(r), result.content.gsub(/<[^>]*>/,"").gsub(/\s\s+/," "))
      end

      def answering_method(r)
        if r.match_data[:me]
          "reply_privately"
        else
          "reply"
        end
      end

      Lita.register_handler(self)
    end
  end
end
