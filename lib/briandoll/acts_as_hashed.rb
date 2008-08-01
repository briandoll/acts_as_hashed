module BrianDoll
  module ActsAsHashed
    module HashedMethods
      def acts_as_hashed(options = {})
        options[:from] ||= :name
        class_inheritable_accessor :acts_as_hashed_options
        self.acts_as_hashed_options = options

        unless included_modules.include?(InstanceMethods)
          include InstanceMethods

          validates_uniqueness_of :hash, :case_insensitive => true
          before_create :create_hash
        end
      end
    end
    
    module InstanceMethods      
      private
      def create_hash
        properties_to_hash = acts_as_hashed_options[:from]
        value_to_hash = ""
        unless properties_to_hash.is_a? Array
          value_to_hash = self.send(properties_to_hash).to_s
        else
          properties_to_hash.each do |prop|
            value_to_hash += self.send(prop).to_s
          end
        end
        self.hash = Zlib.crc32(value_to_hash)
      end
    end
  end
end
ActiveRecord::Base.send(:extend, BrianDoll::ActsAsHashed::HashedMethods)