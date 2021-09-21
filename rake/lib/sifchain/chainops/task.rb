require 'active_support/all'

module Sifchain
  module Chainops
    # Task parent.
    class Task
      KLASS_PATH = 'Sifchain::Chainops'.freeze

      def initialize(opts = {})
        @task = opts.fetch(:task)
        @args = opts.fetch(:args)
        @cwd = opts.fetch(:cwd)
      end

      attr_accessor :task, :args, :cwd

      def build
        klass.new(args: args).generate
      end

      def run!
        klass.new(args: args, cwd: cwd).run!
      end

      private

      def klass
        "#{KLASS_PATH}::#{tklass}".constantize
      end

      def tklass
        "#{task}".split(':').map { |t| t.capitalize }.join('::')
      end
    end
  end
end
