module Sifchain
  module Chainops
    module Sifnode
      module Keys
        module Generate
          # Generate a new mnemonic.
          class Mnemonic < ::Sifchain::Chainops::Builder
            def initialize(opts = {})
              super
            end

            def run!
              generate
            end

            private

            def generate
              system "#{::Sifchain::Chainops::Cli::SIFGEN} key generate", exception: true
            end
          end
        end
      end
    end
  end
end
