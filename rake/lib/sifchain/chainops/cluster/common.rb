module Sifchain
  module Chainops
    module Cluster
      # Common
      class Common
        class << self
          CLUSTER_PREFIX = 'sifchain'.freeze

          def cluster(args)
            "#{CLUSTER_PREFIX}-#{args[:provider]}-#{args[:cluster]}"
          end

          def path(args, cwd)
            "#{cwd}/../../.live/#{cluster(args)}"
          end
        end
      end
    end
  end
end
