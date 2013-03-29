require 'i18n'
require 'active_support/core_ext/object/blank'

root = File.expand_path('../..', __FILE__)
I18n.load_path += Dir[File.join(root, 'locales', '**', '*.yml').to_s]
