module Labourant
  module Utils
    class << self
      def stringify_keys(hash)
        hash.inject(Hash.new) do |new_hash, (key, value)|
          new_hash.merge(key.to_s => value)
        end
      end
    end
  end
end
