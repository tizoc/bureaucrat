GEM_NAME = bureaucrat
GEM_SPEC = $(GEM_NAME).gemspec
GEM_VERSION = $(shell ruby -e 'puts Gem::Specification.load("$(GEM_SPEC)").version')
GEM = $(GEM_NAME)-$(GEM_VERSION).gem

dist: $(GEM)

$(GEM): $(GEM_SPEC)
	gem build $(GEM_SPEC)

setup:
	bundle install

.PHONY: setup

test:
	bundle exec rspec

integration-test:

clean:
	rm -f *.gem
