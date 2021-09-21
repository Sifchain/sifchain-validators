module Sifchain
  module Chainops
    module Sifnode
      module Bank
        # Send funds
        class Send < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            send
          end

          private

          def send
            cmd = <<~CMD
              #{::Sifchain::Chainops::Cli::SIFNODE} tx bank send #{get_arg :from} #{get_arg :to} \
              --node #{get_arg :node} \
              --chain-id #{get_arg :chain_id} \
              --gas-prices #{get_arg :gas_prices} \
              --keyring-backend #{get_arg :keyring_backend}
            CMD
            system cmd, exception: true
          end
        end
      end
    end
  end
end
