require 'i18n'

root = File.expand_path('..', __FILE__)
I18n.load_path += Dir[File.join(root, 'test', 'locales', '**', '*.yml').to_s]
