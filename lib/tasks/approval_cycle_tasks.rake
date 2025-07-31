namespace :approval_cycle do
  namespace :install do
    desc 'Copy migrations from approval_cycle to application'
    task :migrations do
      source = File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrate')
      destination = Rails.root.join('db', 'migrate')

      migration_template = /\A(\d+)_(.*\.rb)\z/

      Dir[File.join(source, '*.rb')].each do |file|
        basename = File.basename(file)

        next unless basename =~ migration_template

        name = Regexp.last_match(2)
        # Generate new timestamp
        new_timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
        new_name = "#{new_timestamp}_#{name}"

        # Check if migration already exists
        existing = Dir[File.join(destination, "*_#{name}")].first

        if existing
          puts "Migration already exists: #{File.basename(existing)}"
        else
          FileUtils.cp(file, File.join(destination, new_name))
          puts "Copied migration: #{new_name}"
        end
      end
    end
  end
end
