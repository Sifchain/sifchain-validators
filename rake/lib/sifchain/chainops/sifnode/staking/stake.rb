module Sifchain
  module Chainops
    module Sifnode
      module Staking
        # Stake (bond) a node
        class Stake < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            stake
          end

          private

          def stake
            cmd = <<~CMD
              #{Sifchain::Chainops::Cli::SIFNODE} tx staking create-validator \
              --commission-max-change-rate #{get_arg :commission_max_change_rate} \
              --commission-max-rate #{get_arg :commission_max_rate} \
              --commission-rate #{get_arg :commission_rate} \
              --amount #{get_arg :amount} \
              --pubkey #{get_arg :pub_key} \
              --chain-id=#{get_arg :chain_id} \
              --min-self-delegation "1" \
              --gas #{get_arg :gas} \
              --gas-prices #{get_arg :gas_prices} \
              --moniker #{get_arg :moniker} \
              --from #{get_arg :moniker} \
              --node #{get_arg :node} \
              --keyring-backend #{Common.keyring_backend(args)}
            CMD
            system cmd, exception: true
          end
        end
      end
    end
  end
end
