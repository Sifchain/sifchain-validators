require 'json'

module Sifchain
  module Chainops
    module Sifnode
      module Staking
        # Validators
        class Validators < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            validators
          end

          private

          def validators
            cmd = <<~CMD
              #{Sifchain::Chainops::Cli::SIFNODE} q tendermint-validator-set \
              --node #{Common.node args} | jq .
            CMD
            system cmd, exception: true
          end
        end
      end
    end
  end
end
