class ObfuscatedRecord < ActiveRecord::Base
  self.abstract_class = true
  has_hashed_id
  
  def self.obfuscated(hashed_id)
    obfuscated_query.first
  end
  
  def self.obfuscated_query(hashed_id)
    where(:hashed_id => hashed_id)
  end
end