desc "Manage sifnode deploy, upgrade, etc processes"
namespace :sifnode do

    desc "Standalone sifnode"
    namespace :standalone do

        desc "Deploy a single standalone sifnode on to your cluster"
        task :deploy, [:cluster, :chainnet, :provider, :namespace, :image, :image_tag, :moniker, :mnemonic, :admin_clp_addresses, :admin_oracle_address, :minimum_gas_prices, :enable_rpc, :enable_external_rpc] do |t, args|
          check_args(args)

          cmd = %Q{helm upgrade sifnode #{cwd}/../../deploy/helm/sifnode42 \
            --set sifnode.env.chainnet=#{args[:chainnet]} \
            --set sifnode.env.moniker=#{args[:moniker]} \
            --set sifnode.args.mnemonic=#{args[:mnemonic]} \
            --set sifnode.args.adminCLPAddresses=#{args[:admin_clp_addresses]} \
            --set sifnode.args.enableRpc=#{args[:enable_rpc]} \
            --set sifnode.args.enableExternalRpc=#{args[:enable_external_rpc]} \
            --set sifnode.args.adminOracleAddress=#{args[:admin_oracle_address]} \
            --set sifnode.args.minimumGasPrices=#{args[:minimum_gas_prices]} \
            --install -n #{ns(args)} --create-namespace \
            --set image.tag=#{image_tag(args)} \
            --set image.repository=#{image_repository(args)}
          }

          system({"KUBECONFIG" => kubeconfig(args)}, cmd)
        end

        desc "Deploy a single network-aware sifnode on to your cluster"
    end

    desc "Peer sifnode"
    namespace :peer do
      desc "Deploy a new network-aware sifnode to your cluster"
        task :deploy, [:cluster, :chainnet, :provider, :namespace, :image, :image_tag, :moniker, :mnemonic, :peer_address, :genesis_url, :enable_rpc, :enable_external_rpc] do |t, args|
          check_args(args)

          cmd = %Q{helm upgrade sifnode #{cwd}/../../deploy/helm/sifnode42 \
            --install -n #{ns(args)} --create-namespace \
            --set sifnode.env.chainnet=#{args[:chainnet]} \
            --set sifnode.env.moniker=#{args[:moniker]} \
            --set sifnode.args.mnemonic=#{args[:mnemonic]} \
            --set sifnode.args.enableRpc=#{args[:enable_rpc]} \
            --set sifnode.args.enableExternalRpc=#{args[:enable_external_rpc]} \
            --set sifnode.args.peerAddress=#{args[:peer_address]} \
            --set sifnode.args.genesisURL=#{args[:genesis_url]} \
            --set image.tag=#{image_tag(args)} \
            --set image.repository=#{image_repository(args)}
          }

          system({"KUBECONFIG" => kubeconfig(args)}, cmd)
        end
    end

    desc "Sifnode with Vault"
    namespace :vault do

        desc "Deploy a single standalone sifnode on to your cluster"
        task :standalone_vault, [:namespace, :image, :image_tag, :helm_values_file, :enable_rpc,:enable_external_rpc] do |t, args|
          #variable_template_replace(args[:template_file_name], args[:final_file_name])
          cmd = %Q{helm upgrade sifnode helm/vault/sifnode \
            --install -n #{args[:namespace]} --create-namespace \
            --set image.tag=#{args[:image_tag]} \
            --set sifnode.args.enableRpc=#{args[:enable_rpc]} \
            --set sifnode.args.enableExternalRpc=#{args[:enable_external_rpc]} \
            --set image.repository=#{args[:image]} \
            -f #{args[:helm_values_file]} --kubeconfig=./kubeconfig
          }
          system(cmd) or exit 1
        end

        desc "Deploy the sifnode API to your cluster"
        task :sifnode_api, [:chainnet, :namespace, :image, :image_tag, :node_host] do |t, args|
            cmd = %Q{helm upgrade sifnode-api helm/standalone/sifnode-api \
              --install -n #{args[:namespace]} --create-namespace \
              --set sifnodeApi.args.chainnet=#{args[:chainnet]} \
              --set sifnodeApi.args.nodeHost=#{args[:node_host]} \
              --set image.tag=#{args[:image_tag]} \
              --set image.repository=#{args[:image]} --kubeconfig=./kubeconfig
            }
            system(cmd) or exit 1
          end

        desc "Deploy a single network-aware sifnode on to your cluster"
        task :peer_vault, [:namespace, :image, :image_tag, :helm_values_file, :peer_address, :enable_rpc,:enable_external_rpc] do |t, args|
            cmd = %Q{helm upgrade sifnode helm/vault/sifnode \
            --install -n #{args[:namespace]} --create-namespace \
            --set sifnode.args.peerAddress=#{args[:peer_address]} \
            --set sifnode.args.enableExternalRpc=#{args[:enable_external_rpc]} \
            --set sifnode.args.enableRpc=#{args[:enable_rpc]} \
            --set image.tag=#{args[:image_tag]} \
            --set image.repository=#{args[:image]} \
            -f #{args[:helm_values_file]} --kubeconfig=./kubeconfig
            }
            system(cmd) or exit 1
        end

        desc "Deploy a single standalone sifnode on to your cluster"
        task :standalone, [:namespace, :image, :image_tag, :enable_api, :enable_grpc, :enable_rpc, :enable_external_grpc, :enable_external_rpc, :path] do |t, args|
            additionalArgs = []
            additionalArgs.push "--enable-api" if args[:enable_api] == "true"
            additionalArgs.push "--enable-grpc" if args[:enable_grpc] == "true"

            cmd = %Q{helm upgrade sifnode #{args[:path]} \
              --install -n #{args[:namespace]} --create-namespace \
              --set sifnode.args.enableAPI=#{args[:enable_api]} \
              --set sifnode.args.enableRpc=#{args[:enable_rpc]} \
              --set sifnode.args.enableGrpc=#{args[:enable_grpc]} \
              --set sifnode.args.enableExternalGrpc=#{args[:enable_external_grpc]} \
              --set sifnode.args.enableExternalRpc=#{args[:enable_external_rpc]} \
              --set sifnode.args.additionalArgs="#{additionalArgs.join(' ')}" \
              --set image.tag=#{args[:image_tag]} \
              --set image.repository=#{args[:image]} --kubeconfig=./kubeconfig
            }
            system(cmd) or exit 1
        end

        desc "Deploy a node in peer mode."
        task :peer, [:namespace, :image, :image_tag, :peer_address, :enable_api, :enable_grpc, :enable_rpc, :enable_external_grpc, :enable_external_rpc, :path] do |t, args|
            additionalArgs = []
            additionalArgs.push "--enable-api" if args[:enable_api] == "true"
            additionalArgs.push "--enable-grpc" if args[:enable_grpc] == "true"

            cmd = %Q{helm upgrade sifnode #{args[:path]} \
              --install -n #{args[:namespace]} --create-namespace \
              --set sifnode.args.enableAPI=#{args[:enable_api]} \
              --set sifnode.args.enableRpc=#{args[:enable_rpc]} \
              --set sifnode.args.enableGrpc=#{args[:enable_grpc]} \
              --set sifnode.args.peerAddress=#{args[:peer_address]} \
              --set sifnode.args.enableExternalGrpc=#{args[:enable_external_grpc]} \
              --set sifnode.args.enableExternalRpc=#{args[:enable_external_rpc]} \
              --set sifnode.args.additionalArgs="#{additionalArgs.join(' ')}" \
              --set image.tag=#{args[:image_tag]} \
              --set image.repository=#{args[:image]} --kubeconfig=./kubeconfig
            }
            system(cmd) or exit 1
        end

    end
end

