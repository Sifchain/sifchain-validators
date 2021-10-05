module Sifchain
  module Chainops
    module Sifnode
      # Common
      class Common
        class << self
          DEFAULTS = { namespace: 'sifnode', container: 'sifnode', chain_id: 'sifchain-1', bind_ip_address: '127.0.0.1',
                       gas_price: '0.5rowan', keyring_backend: 'file', node: 'tcp://rpc.sifchain.finance:80' }.freeze

          def kubeconfig(args)
            return if ENV['KUBECONFIG']

            "--kubeconfig #{get_arg :kubeconfig}" if args.is_a?(Rake::TaskArguments) && args.key?(:kubeconfig)
          end

          def namespace(args)
            return args[:namespace] if args.is_a?(Rake::TaskArguments) && args.key?(:namespace)

            DEFAULTS[:namespace]
          end

          def container(args)
            return args[:container] if args.is_a?(Rake::TaskArguments) && args.key?(:container)

            DEFAULTS[:container]
          end

          def chain_id(args)
            return args[:chain_id] if args.is_a?(Rake::TaskArguments) && args.key?(:chain_id)

            DEFAULTS[:chain_id]
          end

          def bind_ip_address(args)
            return args[:bind_ip_address] if args.is_a?(Rake::TaskArguments) && args.key?(:bind_ip_address)

            DEFAULTS[:bind_ip_address]
          end

          def gas_price(args)
            return args[:gas_price] if args.is_a?(Rake::TaskArguments) &&  args.key?(:gas_price)

            DEFAULTS[:gas_price]
          end

          def keyring_backend(args)
            return args[:keyring_backend] if args.is_a?(Rake::TaskArguments) && args.key?(:keyring_backend)

            DEFAULTS[:keyring_backend]
          end

          def node(args)
            return args[:node] if args.is_a?(Rake::TaskArguments) && args.key?(:node)

            DEFAULTS[:node]
          end

          def pod_name(args)
            cmd = <<~CMD
              #{::Sifchain::Chainops::Cli::KUBECTL} get pods --selector=app.kubernetes.io/instance=sifnode \
              -n #{namespace(args)} \
              #{kubeconfig(args)} \
              -o json | jq '.items[0].metadata.name'
            CMD
            `#{cmd}`.strip
          end
        end
      end
    end
  end
end
