module Sifchain
  module Chainops
    module Sifnode
      module Keys
        # Import a mnemonic.
        class Import < ::Sifchain::Chainops::Builder
          def initialize(opts = {})
            super
          end

          def run!
            import
          end

          private

          def moniker
            @moniker ||= args[:moniker]
          end

          def backend
            @backend ||= args&.key?(:backend) ? args[:keyring_backend] : DEFAULT_BACKEND
          end

          def import
            cmd = <<~CMD
              #{::Sifchain::Chainops::Cli::SIFNODE} keys add #{moniker} -i --recover \
              --keyring-backend #{Common.keyring_backend(args)}
            CMD
            system cmd, exception: true
          end
        end
      end
    end
  end
end
