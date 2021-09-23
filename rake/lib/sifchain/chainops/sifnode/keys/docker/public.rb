module Sifchain
  module Chainops
    module Sifnode
      module Keys
        module Docker
          # Public key
          class Public < ::Sifchain::Chainops::Builder
            def initialize(opts = {})
              super
            end

            def run!
              key
            end

            private

            def container
              @container ||= `#{::Sifchain::Chainops::Cli::DOCKER} container ps | grep #{get_arg :image}:#{get_arg :image_tag} | awk '{ print $1 }'`.strip
            end

            def key
              raise 'container not found' if container.nil? || container.empty?

              cmd = <<~CMD
                #{::Sifchain::Chainops::Cli::DOCKER} exec -it #{container} \
                cosmovisor tendermint show-validator
              CMD
              system cmd, exception: true
            end
          end
        end
      end
    end
  end
end
