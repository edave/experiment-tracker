class ObfuscatedRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def self.obfuscated(hashed_id)
    obfuscated_query(hashed_id).first
  end
  
  def self.obfuscated_query(hashed_id)
    where(:id => hashed_id)
  end
  
  def self.find_by_obfuscated_query!(hashed_id)
    where(:id => hashed_id)
  end
end