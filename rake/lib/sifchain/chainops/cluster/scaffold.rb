require 'fileutils'

module Sifchain
  module Chainops
    module Cluster
      # Scaffold a new cluster.
      class Scaffold < ::Sifchain::Chainops::Builder
        def initialize(opts = {})
          super
        end

        def run!
          create_dirs
          templates.each { |k, v| save_template("#{Common.path args, cwd}/#{k}", parse_template(v)) }
          terraform_init
        end

        private

        def create_dirs
          FileUtils.mkdir_p Common.path args, cwd
        end

        def templates
          { 'main.tf' => "#{cwd}/../terraform/template/aws/cluster.tf.tpl",
            '.envrc' => "#{cwd}/../terraform/template/aws/.envrc.tpl" }
        end

        def parse_template(file)
          File.read(file)&.gsub! /{{.cluster}}/, get_arg(:cluster)
        end

        def save_template(file, contents)
          File.open(file, 'w') { |f| f.puts contents }
        end

        def terraform_init
          Dir.chdir(Common.path(args, cwd)) { system "#{::Sifchain::Chainops::Cli::TERRAFORM} init", exception: true }
        end
      end
    end
  end
end
