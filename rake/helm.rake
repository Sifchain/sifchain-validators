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
        --set sifnode.env.chainnet0=#{args[:chainnet0]} --set sifnode.env.chainnet1=#{args[:chainnet1]} \
        --set sifnode.env.prefix0=#{args[:prefix0]} --set sifnode.env.prefix1=#{args[:prefix1]} \
        --set sifnode.env.gas_price0=#{args[:gas_price0]} --set sifnode.env.gas_price1=#{args[:gas_price1]} \
        --set sifnode.env.rpc0=#{args[:rpc0]} --set sifnode.env.rpc1=#{args[:rpc1]} \
        --set sifnode.args.mnemonic="#{args[:mnemonic]}" \
        --install -n #{args[:namespace]} \
        --create-namespace \
        --set image.tag=#{args[:image_tag]} \
        --kubeconfig=#{args[:kubeconfig_location]} \
        --set image.repository=#{args[:image]}
      }

      system(cmd) or exit 1
    end
end

