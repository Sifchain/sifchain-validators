module Sifchain
  module Chainops
    module Sifnode
      module Config
        # Backup a node's config
        class Backup < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            backup
          end

          private

          def pod_name
            @pod_name ||= Common.pod_name args
          end

          def backup
            raise 'unable to find pod' if pod_name.nil?

            cmd = <<~CMD
              #{::Sifchain::Chainops::Cli::KUBECTL} cp #{get_arg :namespace}/#{pod_name}:/root/.sifnoded/config #{get_arg :save_path} \
              #{Common.kubeconfig(args)}
            CMD
            system cmd, exception: true
          end
        end
      end
    end
  end
end
