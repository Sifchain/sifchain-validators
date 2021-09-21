describe Sifchain::Chainops::Cluster::Pods do
  before do
    ENV['KUBECONFIG'] = nil
  end

  context :kubeconfig do
    Given(:cluster_name) { Faker::Internet.domain_name }
    Given(:provider) { 'aws' }
    Given(:namespace) { Faker::Lorem.word }
    Given(:cwd) { '/tmp' }
    Given(:kubeconfig_path) do
      "../../.live/sifchain-#{provider}-#{cluster_name}/kubeconfig_sifchain-#{provider}-#{cluster_name}"
    end

    context :with do
      Given(:args) do
        { cluster: cluster_name, provider: provider, kubeconfig: kubeconfig_path }
      end
      Given(:klass) { Sifchain::Chainops::Cluster::Pods.new(args: args, cwd: cwd) }

      When(:kubeconfig) { klass.send(:kubeconfig) }

      Then { expect(kubeconfig).to include(kubeconfig_path) }
    end

    context :without do
      Given(:args) do
        { cluster: cluster_name, provider: provider, kubeconfig: nil }
      end
      Given(:klass) { Sifchain::Chainops::Cluster::Pods.new(args: args, cwd: cwd) }

      When(:kubeconfig) { klass.send(:kubeconfig) }

      Then { expect(kubeconfig).to be_nil }
    end
  end
end
