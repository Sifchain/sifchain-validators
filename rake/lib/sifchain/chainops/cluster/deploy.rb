require 'fileutils'

module Sifchain
  module Chainops
    module Cluster
      # Scaffold a new cluster.
      class Deploy < ::Sifchain::Chainops::Builder
        def initialize(opts = {})
          super
        end

        def run!
          terraform_apply
        end

        private

        def terraform_apply
          Dir.chdir(Common.path(args, cwd)) do
            system "#{::Sifchain::Chainops::Cli::TERRAFORM} apply -auto-approve", exception: true
          end
        end
      end
    end
  end
end
