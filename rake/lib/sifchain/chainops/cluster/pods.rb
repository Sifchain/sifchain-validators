require 'fileutils'

module Sifchain
  module Chainops
    module Cluster
      # Pods on a cluster
      class Pods < ::Sifchain::Chainops::Builder
        def initialize(opts = {})
          super
        end

        def run!
          pods
        end

        private

        def kubeconfig
          return if ENV['KUBECONFIG']

          return if args[:kubeconfig].nil?

          "--kubeconfig #{get_arg :kubeconfig}" if args&.key? :kubeconfig
        end

        def pods
          cmd = <<~CMD
            #{::Sifchain::Chainops::Cli::KUBECTL} get pods \
            -n #{get_arg :namespace} \
            #{kubeconfig}
          CMD
          system "#{cmd}".strip, exception: true
        end
      end
    end
  end
end
