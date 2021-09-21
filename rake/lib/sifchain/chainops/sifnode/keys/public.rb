module Sifchain
  module Chainops
    module Sifnode
      module Keys
        # Public key
        class Public < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            key
          end

          private

          def pod_name
            @pod_name ||= Common.pod_name args
          end

          def key
            raise 'unable to find pod' if pod_name.nil?

            cmd = <<~CMD
              #{::Sifchain::Chainops::Cli::KUBECTL} exec --stdin --tty #{pod_name} \
              -n #{get_arg :namespace} \
              -c #{Common.container args} \
              #{Common.kubeconfig args} \
              -- cosmovisor tendermint show-validator
            CMD
            system cmd, exception: true
          end
        end
      end
    end
  end
end
