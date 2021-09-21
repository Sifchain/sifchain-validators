module Sifchain
  module Chainops
    module Sifnode
      module Logs
        # Show a key
        class Tail < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            tail
          end

          private

          def pod_name
            @pod_name ||= Common.pod_name args
          end

          def tail
            raise 'unable to find pod' if pod_name.nil?

            cmd = <<~CMD
              #{::Sifchain::Chainops::Cli::KUBECTL} -n #{get_arg :namespace} logs #{pod_name} --tail #{rows} -f \
               #{Common.kubeconfig(args)}
            CMD
            system cmd, exception: true
          end
        end
      end
    end
  end
end
