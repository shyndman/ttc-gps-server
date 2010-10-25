namespace :gems do
  desc 'Install required gems'
  task :install do
    File.open(".gems").each { |required_gem|
      system "sudo gem install #{required_gem}"
    }
  end
end

task :environment do
  require 'environment'
end
