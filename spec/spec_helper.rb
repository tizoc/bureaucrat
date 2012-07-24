require 'bureaucrat'

root = File.expand_path('..', __FILE__)
I18n.load_path += Dir[File.join(root, 'locales', '**', '*.yml').to_s]
