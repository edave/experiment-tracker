require 'ostruct'
require 'yaml'
require 'digest/md5'

def read_biglietto_configuration
  biglietto_config_struct = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/biglietto.yml"))
  biglietto_config = Hash.new()
  biglietto_config.merge!(biglietto_config_struct.common)

  updated_biglietto_config = biglietto_config_struct.send(Rails.env)
  biglietto_config.merge!(updated_biglietto_config) if updated_biglietto_config
  OpenStruct.new(biglietto_config)
end

::BigliettoConfig = read_biglietto_configuration
