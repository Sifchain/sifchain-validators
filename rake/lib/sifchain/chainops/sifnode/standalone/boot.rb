module Sifchain
  module Chainops
    module Sifnode
      module Standalone
        # Boot a node.
        class Boot < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            boot
          end

          private

          def moniker
            args[:moniker]
          end

          def mnemonic
            args[:mnemonic]
          end

          def gas_price
            Common.gas_price(args)
          end

          def bind_ip_address
            Common.bind_ip_address(args)
          end

          def docker_vars
            "MONIKER=#{moniker} MNEMONIC=#{mnemonic} GAS_PRICE=#{gas_price} BIND_IP_ADDRESS=#{bind_ip_address}"
          end

          def chain_id
            Common.chain_id(args)
          end

          def boot
            system "#{docker_vars} #{::Sifchain::Chainops::Cli::DOCKER_COMPOSE} -f #{cwd}/../docker/sifchain/#{chain_id}/docker-compose.yml up #{args[:flags]}",
                   exception: true
          end
        end
      end
    end
  end
end
