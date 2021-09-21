module Sifchain
  module Chainops
    # CLI arg builder.
    class Builder
      def initialize(opts = {})
        @args = opts.fetch(:args)
        @cwd = opts.fetch(:cwd)
      end

      attr_accessor :args, :cwd

      def build!(arg_map)
        arg_map.map { |k, v| "#{v} #{args[k]}" }.join(' ')
      end

      def get_arg(arg)
        raise "#{arg} must be provided" unless args&.key? arg

        args[arg]
      end
    end
  end
end
