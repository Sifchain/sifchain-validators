module Sifchain
  module Chainops
    module Provider
      module Aws
        # Generate kubeconfig
        class Kubeconfig < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            kubeconfig
          end

          private

          def profile
            return unless args&.key? :profile

            "--profile #{get_arg :profile}"
          end

          def cluster_common
            ::Sifchain::Chainops::Cluster::Common
          end

          def kubeconfig
            cmd = <<~CMD
              #{::Sifchain::Chainops::Cli::AWS} eks update-kubeconfig \
              --name #{cluster_common.cluster(args)} \
              --region #{get_arg :region} \
              #{profile}
            CMD
            system cmd, exception: true
          end
        end
      end
    end
  end
end
