require_relative "lib/sifchain/chainops/setup/dependencies/install"

desc "Setup"
namespace :setup do
  desc "Dependencies"
  namespace :dependencies do
    desc "Install required dependencies"
    task :install do |t, args|
      run_task(args, t)
    end
  end
end
