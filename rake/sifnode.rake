require_relative "lib/sifchain/chainops/sifnode/bank/send"
require_relative "lib/sifchain/chainops/sifnode/common"
require_relative "lib/sifchain/chainops/sifnode/config/backup"
require_relative "lib/sifchain/chainops/sifnode/keys/docker/public"
require_relative "lib/sifchain/chainops/sifnode/keys/generate/mnemonic"
require_relative "lib/sifchain/chainops/sifnode/keys/kubernetes/public"
require_relative "lib/sifchain/chainops/sifnode/keys/import"
require_relative "lib/sifchain/chainops/sifnode/keys/show"
require_relative "lib/sifchain/chainops/sifnode/logs/tail"
require_relative "lib/sifchain/chainops/sifnode/staking/stake"
require_relative "lib/sifchain/chainops/sifnode/staking/validators"
require_relative "lib/sifchain/chainops/sifnode/standalone/boot"
require_relative "lib/sifchain/chainops/sifnode/status"

desc "Manage sifnode deploy, upgrade, etc processes"
namespace :sifnode do
  desc "Bank"
  namespace :bank do
    desc "Send funds"
    task :send, %i[from to node chain_id gas_prices keyring_backend]
  end

  desc "Config"
  namespace :config do
    desc "Backup the node config"
    task :backup, %i[namespace save_path kubeconfig] do |t, args|
      ENV['KUBECONFIG'] = kubeconfig(args) unless args&.key? :kubeconfig
      run_task(args, t)
    end
  end

  desc "Keys"
  namespace :keys do
    desc "Generate"
    namespace :generate do
      desc "Generate a new mnemonic"
      task :mnemonic do |t, args|
        run_task(args, t)
      end
    end

    desc "Import a key"
    task :import, %i[moniker keyring_backend] do |t, args|
      run_task(args, t)
    end

    desc "Kubernetes"
    namespace :kubernetes do
      desc "Display a node's public key"
      task :public, %i[cluster provider namespace kubeconfig] do |t, args|
        ENV['KUBECONFIG'] = kubeconfig(args) unless args&.key? :kubeconfig

        run_task(args, t)
      end
    end

    desc "Docker"
    namespace :docker do
      desc "Display a node's public key"
      task :public, %i[image image_tag] do |t, args|
        run_task(args, t)
      end
    end

    desc "Show a key in the keyring"
    desc "Bank"
    task :show, %i[name keyring_backend] do |t, args|
      run_task(args, t)
    end
  end

  desc "Staking"
  namespace :staking do
    desc "Stake a node"
    task :stake, %i[commission_max_change_rate
                    commission_max_rate
                    commission_rate
                    chain_id
                    moniker
                    amount
                    gas
                    gas_prices
                    pub_key
                    node
                    keyring_backend] do |t, args|
      args.with_defaults(keyring_backend: 'file') unless args&.key? :keyring_backend
      run_task(args, t)
    end

    desc "Validators"
    task :validators, %i[node] do |t, args|
      run_task(args, t)
    end
  end

  desc "Logs"
  namespace :logs do
    task :tail, %i[cluster provider namespace rows kubeconfig] do |t, args|
      ENV['KUBECONFIG'] = kubeconfig(args) unless args&.key? :kubeconfig
      trap('SIGINT') { puts "Exiting..."; exit }

      run_task(args, t)
    end
  end

  desc "Status"
  task :status, %i[cluster namespace kubeconfig] do |t, args|
    args.with_defaults(provider: 'aws')
    ENV['KUBECONFIG'] = kubeconfig(args) unless args&.key? :kubeconfig

    run_task(args, t)
  end

  desc "Standalone"
  namespace :standalone do
    desc "Boot a node"
    task :boot, %i[chain_id moniker mnemonic gas_price bind_ip_address flags] do |t, args|
      run_task(args, t)
    end

    desc "Deploy a single standalone sifnode on to your cluster"
        task :deploy, [:cluster, :chainnet, :provider, :namespace, :image, :image_tag, :moniker, :mnemonic, :admin_clp_addresses, :admin_oracle_address, :minimum_gas_prices, :enable_rpc, :enable_external_rpc] do |t, args|
          check_args(args)

          cmd = %Q{helm upgrade sifnode #{cwd}/../helm/standalone/sifnode42 \
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

          cmd = %Q{helm upgrade sifnode #{cwd}/../helm/standalone/sifnode42 \
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
        task :standalone, [:namespace, :image, :image_tag, :moniker, :chainnet, :genesis_url, :mnemonic, :peer_address, :enable_api, :enable_rpc, :enable_grpc, :enable_external_api, :enable_external_grpc, :enable_external_rpc, :path] do |t, args|
            additionalArgs = []
            additionalArgs.push "--enable-api" if args[:enable_api] == "true"
            additionalArgs.push "--enable-grpc" if args[:enable_grpc] == "true"

            cmd = %Q{helm upgrade sifnode #{args[:path]} \
              --install -n #{args[:namespace]} --create-namespace \
              --set sifnode.env.moniker=#{args[:moniker]} \
              --set sifnode.env.chainnet=#{args[:chainnet]} \
              --set sifnode.args.genesisURL=#{args[:genesis_url]} \
              --set sifnode.args.mnemonic=#{args[:mnemonic]} \
              --set sifnode.args.peerAddress=#{args[:peer_address]} \
              --set sifnode.args.enableAPI=#{args[:enable_api]} \
              --set sifnode.args.enableRpc=#{args[:enable_rpc]} \
              --set sifnode.args.enableGrpc=#{args[:enable_grpc]} \
              --set sifnode.args.enableExternalAPI=#{args[:enable_external_api]} \
              --set sifnode.args.enableExternalGrpc=#{args[:enable_external_grpc]} \
              --set sifnode.args.enableExternalRpc=#{args[:enable_external_rpc]} \
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

