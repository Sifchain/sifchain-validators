module Sifchain
  module Chainops
    module Sifnode
      # Sifnode status
      class Status < ::Sifchain::Chainops::Builder
        def initialize(opts = {})
          super
        end

        def run!
          status
        end

        private

        def pod_name
          @pod_name ||= Common.pod_name args
        end

        def status
          raise 'unable to find pod' if pod_name.nil?

          cmd = <<~CMD
            #{::Sifchain::Chainops::Cli::KUBECTL} exec --stdin --tty #{pod_name} \
            -n #{get_arg :namespace} \
            #{Common.kubeconfig(args)} \
            -- curl http://localhost:26657/status
          CMD
          system cmd, exception: true
        end
      end
    end
  end
end
