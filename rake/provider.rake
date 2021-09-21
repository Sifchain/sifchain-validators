require_relative "lib/sifchain/chainops/provider/aws/kubeconfig"

desc "Manage sifnode deploy, upgrade, etc processes"
namespace :provider do
  desc "Bank"
  namespace :aws do
    desc "Send funds"
    task :kubeconfig, %i[cluster region profile kubeconfig] do |t, args|
      args.with_defaults(provider: 'aws')
      ENV['KUBECONFIG'] = kubeconfig(args) unless args&.key? :kubeconfig

      run_task(args, t)
    end
  end
end
