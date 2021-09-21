module Sifchain
  module Chainops
    module Sifnode
      module Keys
        # Show a key
        class Show < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            key
          end

          private

          def key
            cmd = <<~CMD
              #{::Sifchain::Chainops::Cli::SIFNODE} keys show #{get_arg :name} \
              --keyring-backend #{Common.keyring_backend(args)}
            CMD
            system cmd, exception: true
          end
        end
      end
    end
  end
end
