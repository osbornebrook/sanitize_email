#Copyright (c) 2008 Peter H. Boling of 9thBit LLC
#Released under the MIT license

module OBDev
  module SanitizeEmail

    def self.included(base)
  
      # Adds the following class attributes to the classes that include OBDev::SanitizeEmail
      base.cattr_accessor :force_sanitize
      base.force_sanitize = nil
      
      # Specify the BCC addresses for the messages that go out in 'local' environments
      base.cattr_accessor :sanitized_bcc
      base.sanitized_bcc = nil
     
      # Specify the CC addresses for the messages that go out in 'local' environments
      base.cattr_accessor :sanitized_cc
      base.sanitized_cc = nil
    
      # The recipient addresses / domains (@example.com) allowed for the messages, either as a string (for a single
      # address) or an array (for multiple addresses) that go out in 'local' environments
      base.cattr_accessor :allowed_recipients
      base.allowed_recipients = nil

      base.cattr_accessor :sanitized_recipient
      base.sanitized_recipient = nil
      
      base.class_eval do
        #We need to alias these methods so that our new methods get used instead
        alias :real_bcc :bcc
        alias :real_cc :cc
        alias :real_recipients :recipients

        def localish?
          #consider_local is a method in sanitize_email/lib/custom_environments.rb
          # it is included in ActionMailer in sanitize_email/init.rb
          !self.class.force_sanitize.nil? ? self.class.force_sanitize : self.class.consider_local?
        end

        def recipients(*addresses)
          real_recipients *addresses
          puts "sanitize_email error: allowed_recipients is not set" if self.class.allowed_recipients.nil?
          
          use_recipients = [*addresses].map do |a|
            user, domain = a.split('@')
            [*self.class.allowed_recipients].include?(a) || [*self.class.allowed_recipients].include?("@#{domain}") ? a : self.class.sanitized_recipient
          end
          
          localish? ? use_recipients.uniq : real_recipients
        end

        def bcc(*addresses)
          real_bcc *addresses
          localish? ? self.class.sanitized_bcc : real_bcc
        end

        def cc(*addresses)
          real_cc *addresses
          localish? ? self.class.sanitized_cc : real_cc
        end
      
      end

    end
  end # end Module SanitizeEmail
end # end Module OBDev
