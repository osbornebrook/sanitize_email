#Copyright (c) 2008 Peter H. Boling of 9thBit LLC
#Released under the MIT license

module OBDev
  module CustomEnvironments
    
    def self.included(base)
      base.extend(ClassMethods)
  
      base.cattr_accessor :local_environments
      base.local_environments = %w( development test staging )
      
      base.cattr_accessor :deployed_environments
      base.deployed_environments = %w( production )
    end

    module ClassMethods
      def consider_local?
        local_environments.include?(ENV['RAILS_ENV'])
      end
      def consider_deployed?
        deployed_environments.include?(ENV['RAILS_ENV'])
      end
    end
    
  end
end