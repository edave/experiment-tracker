# Load our ActiveRecord extensions

# Name is a hack to get this file loaded before other initializers which may need these
# extensions to properly load models

require 'lib/hashed_id'

require 'lib/custom_validations'
