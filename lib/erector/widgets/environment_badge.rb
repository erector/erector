module Erector
  module Widgets #:nodoc:

    # Displays a colored badge in the upper-left corner 
    # signifying the environment the app is running in. 
    # Inspired by Assaf Arkin
    #  <http://blog.labnotes.org/2009/10/08/using-a-badge-to-distinguish-development-and-production-environments/>
    # Erectorized by Alex Chaffee
    class EnvironmentBadge < Erector::Widget
      def content
        style <<-STYLE
#environment_badge { position: fixed; left: 1em; font-weight: bold; padding: .2em 0.9em; text-transform: uppercase; display: none }
#environment_badge.staging { color: #000; background: #ffff00; border: 2px solid #cccc20; }
#environment_badge.development { color: #fff; background: #ff0000; border: 2px solid #cc2020; }
#environment_badge.staging, #environment_badge.development { border-top: none; display: block; opacity: 0.6 }    
        STYLE
        unless environment =~ /production/
          p environment, :class => environment, :id => "environment_badge"
        end
      end

      def environment
        RAILS_ENV
      rescue NameError
        ENV['RAILS_ENV'] || ENV['RACK_ENV']
      end
    end
  end
end
