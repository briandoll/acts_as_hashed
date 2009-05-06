module BrianDoll
  module ActsAsHashed
    module HashedMethods

      def acts_as_hashed(options = {})   
        class_inheritable_accessor :acts_as_hashed_options
        self.acts_as_hashed_options = options

        unless included_modules.include?(InstanceMethods)
          include InstanceMethods
          after_validation_on_create :create_crypto_hash
        end
      end

      private
      def rehash!
        self.all.each do |cat|
          cat.send("create_crypto_hash")
          cat.save
        end    
      end

    end
    
    module InstanceMethods      

      def instantiated_at
        Time.now.to_i.to_s
      end
      
      private

      def create_crypto_hash
        properties_to_hash = acts_as_hashed_options[:from].to_a << :instantiated_at
        value_to_hash = properties_to_hash.map { |prop| self.send(prop).to_s }.join
        self.crypto_hash = Zlib.crc32(value_to_hash)
      end

    end
  end
end
ActiveRecord::Base.send(:extend, BrianDoll::ActsAsHashed::HashedMethods)