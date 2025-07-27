require_relative 'lib/approval_cycle/version'

Gem::Specification.new do |spec|
  spec.name        = 'approval_cycle'
  spec.version     = ApprovalCycle::VERSION
  spec.authors     = ['Farah Assaf']
  spec.email       = ['farahassaf96@gmail.com']
  spec.homepage    = 'https://github.com/farah-zenhr/approval-cycle/'
  spec.summary     = 'Approval Cycle Gem for managing approval workflows'
  spec.description = 'Approval Cycle is a Ruby gem designed to help manage and automate approval workflows within your Rails application. It provides a simple and flexible way to define, track, and enforce approval processes for various resources.'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/farah-zenhr/approval-cycle/'
  spec.metadata['changelog_uri']   = 'https://github.com/farah-zenhr/approval-cycle/'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'pg'
  spec.add_dependency 'rails', '>= 7.0.8'

  spec.add_development_dependency 'dotenv-rails'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'shoulda-matchers'

  spec.test_files = Dir['spec/**/*']
end
