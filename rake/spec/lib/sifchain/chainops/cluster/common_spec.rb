describe Sifchain::Chainops::Cluster::Common do
  Given(:cluster_name) { Faker::Internet.domain_name }
  Given(:provider) { 'aws' }
  Given(:args) do
    { cluster: cluster_name, provider: provider }
  end
  Given(:klass) { Sifchain::Chainops::Cluster::Common }

  context :cluster do
    When(:result) { klass.cluster(args) }

    Then { expect(result).to include("sifchain-#{provider}-#{cluster_name}") }
  end

  context :path do
    Given(:cwd) { '/tmp' }

    When(:result) { klass.path(args, cwd) }

    Then { expect(result).to include("/tmp/../../.live/sifchain-#{provider}-#{cluster_name}") }
  end
end
