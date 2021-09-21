require 'curb'
require 'fileutils'
require 'os'

module Sifchain
  module Chainops
    module Setup
      module Dependencies
        # Install dependencies.
        class Install < ::Sifchain::Chainops::Builder
          LINUX_DEPENDENCIES = %i[aws_iam_authenticator helm].freeze
          MACOSX_DEPENDENCIES = %w[aws-iam-authenticator awscli helm kubernetes-cli terraform].freeze

          def initialize(opts = {})
            super
          end

          def run!
            return unless supported?

            linux_dependencies if linux?
            macosx_dependencies if macosx?
          end

          private

          def linux?
            OS.linux?
          end

          def macosx?
            OS.mac?
          end

          def supported?
            return true if macosx? || linux?

            false
          end

          def linux_dependencies
            LINUX_DEPENDENCIES.each { |d| send(d) }
          end

          def macosx_dependencies
            MACOSX_DEPENDENCIES.each { |d| system "brew install #{d}" }
          end

          def aws_iam_authenticator_url
            'https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.8/2020-09-18/bin/linux/amd64/aws-iam-authenticator'
          end

          def aws_iam_authenticator
            content = Curl.get "#{aws_iam_authenticator_url}"
            File.open('aws_iam_authenticator', 'w') { |f| f.puts content.body_str }
            FileUtils.chmod '+x', 'aws-iam-authenticator'
            FileUtils.mkdir_p "#{ENV['HOME']}/bin"
            FileUtils.cp 'aws-iam-authenticator', "#{ENV['HOME']}/bin/"
          end

          def helm_url
            'https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3'
          end

          def helm
            content = Curl.get "#{helm_url}"
            File.open('get-helm-3', 'w') { |f| f.puts content.body_str }
            FileUtils.chmod '+x', 'get-helm-3'
            system 'get-helm-3', exception: true
          end
        end
      end
    end
  end
end
