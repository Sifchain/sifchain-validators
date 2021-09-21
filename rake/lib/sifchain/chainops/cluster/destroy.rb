require 'fileutils'

module Sifchain
  module Chainops
    module Cluster
      # Destroy a cluster.
      class Destroy < ::Sifchain::Chainops::Builder
        def initialize(opts = {})
          super
        end

        def run!
          terraform_destroy
        end

        private

        def terraform_destroy
          Dir.chdir(Common.path(args, cwd)) do
            system "#{::Sifchain::Chainops::Cli::TERRAFORM} destroy -auto-approve", exception: true
          end
        end
      end
    end
  end
end
