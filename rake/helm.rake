desc "Utility for doing helm tasks."
namespace :helm do
    desc "Deploy a relayer to your cluster."
    task :deploy_relayer, [:relayer_name,
                           :mnemonic,
                           :chainnet0,
                           :chainnet1,
                           :namespace,
                           :image,
                           :image_tag,
                           :prefix0,
                           :prefix1,
                           :gas_price0,
                           :gas_price1,
                           :rpc0,
                           :rpc1,
                           :path,
                           :kubeconfig_location] do |t, args|

      cmd = %Q{helm upgrade #{args[:relayer_name]} #{args[:path]} \
        --set tsRelayer.env.chainnet0=#{args[:chainnet0]} \
        --set tsRelayer.env.chainnet1=#{args[:chainnet1]} \
        --set tsRelayer.env.prefix0=#{args[:prefix0]} \
        --set tsRelayer.env.prefix1=#{args[:prefix1]} \
        --set tsRelayer.env.gas_price0=#{args[:gas_price0]} \
        --set tsRelayer.env.gas_price1=#{args[:gas_price1]} \
        --set tsRelayer.env.rpc0=#{args[:rpc0]} \
        --set tsRelayer.env.rpc1=#{args[:rpc1]} \
        --set tsRelayer.args.mnemonic="#{args[:mnemonic]}" \
        --install -n #{args[:namespace]} \
        --create-namespace \
        --set image.tag=#{args[:image_tag]} \
        --kubeconfig=#{args[:kubeconfig_location]} \
        --set image.repository=#{args[:image]}
      }

      system(cmd) or exit 1
    end

    desc "Deploy a relayer to your cluster. With HDPATH"
    task :deploy_relayer_with_path, [:relayer_name,
                           :mnemonic,
                           :chainnet0,
                           :chainnet1,
                           :namespace,
                           :image,
                           :image_tag,
                           :prefix0,
                           :prefix1,
                           :gas_price0,
                           :gas_price1,
                           :rpc0,
                           :rpc1,
                           :path,
                           :kubeconfig_location,
                           :hdpath] do |t, args|


      puts "The HDPATH that will be used: #{args[:hdpath]}"
      cmd = %Q{helm upgrade #{args[:relayer_name]} #{args[:path]} \
        --set tsRelayer.env.chainnet0=#{args[:chainnet0]} \
        --set tsRelayer.env.chainnet1=#{args[:chainnet1]} \
        --set tsRelayer.env.prefix0=#{args[:prefix0]} \
        --set tsRelayer.env.prefix1=#{args[:prefix1]} \
        --set tsRelayer.env.gas_price0=#{args[:gas_price0]} \
        --set tsRelayer.env.gas_price1=#{args[:gas_price1]} \
        --set tsRelayer.env.rpc0=#{args[:rpc0]} \
        --set tsRelayer.env.rpc1=#{args[:rpc1]} \
        --set tsRelayer.env.hdpath=#{args[:hdpath]} \
        --set tsRelayer.args.mnemonic="#{args[:mnemonic]}" \
        --install -n #{args[:namespace]} \
        --create-namespace \
        --set image.tag=#{args[:image_tag]} \
        --kubeconfig=#{args[:kubeconfig_location]} \
        --set image.repository=#{args[:image]}
      }

      system(cmd) or exit 1
    end

    desc "Deploy a hermes relayer to your cluster."
    task :deploy_hermes, [:relayer_name,
                          :namespace,
                          :image,
                          :image_tag,
                          :gaia_mnemonic,
                          :akash_mnemonic,
                          :iris_mnemonic,
                          :sifnode_mnemonic,
                          :sentinel_mnemonic,
                          :persistence_mnemonic,
                          :osmosis_mnemonic,
                          :regen_mnemonic,
                          :crypto_mnemonic,
                          :relayer_mapping,
                          :hermes_config_location,
                          :path,
                          :kubeconfig_location,
                          :connection_mapping] do |t, args|

      cmd = %Q{helm upgrade #{args[:relayer_name]} #{args[:path]} \
        --set hermesRelayer.env.gaia_mnemonic="#{args[:gaia_mnemonic]}" \
        --set hermesRelayer.env.akash_mnemonic="#{args[:akash_mnemonic]}" \
        --set hermesRelayer.env.iris_mnemonic="#{args[:iris_mnemonic]}" \
        --set hermesRelayer.env.sifnode_mnemonic="#{args[:sifnode_mnemonic]}" \
        --set hermesRelayer.env.sentinel_mnemonic="#{args[:sentinel_mnemonic]}" \
        --set hermesRelayer.env.persistence_mnemonic="#{args[:persistence_mnemonic]}" \
        --set hermesRelayer.env.osmosis_mnemonic="#{args[:osmosis_mnemonic]}" \
        --set hermesRelayer.env.regen_mnemonic="#{args[:regen_mnemonic]}" \
        --set hermesRelayer.env.crypto_mnemonic="#{args[:crypto_mnemonic]}" \
        --set hermesRelayer.env.relayer_mapping="#{args[:relayer_mapping]}" \
        --set hermesRelayer.env.hermes_config_location="#{args[:hermes_config_location]}" \
        --set hermesRelayer.env.connection_mapping="#{args[:connection_mapping]}" \
        --install -n #{args[:namespace]} \
        --create-namespace \
        --set image.tag=#{args[:image_tag]} \
        --kubeconfig=#{args[:kubeconfig_location]} \
        --set image.repository=#{args[:image]}
      }

      system(cmd) or exit 1
    end

end

