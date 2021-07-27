# desc "Utility for doing geth helm tasks."
# namespace :geth do
#   desc "Deploy a relayer to your cluster."
#   task :deploy_geth, %i[cluster, provider, namespace, network] do |t, args|
#     check_args(args)
#
#     if args.has_key? :network
#       network_id =  if args[:network] == "ropsten"
#                       3
#                     else
#                       1
#                     end
#     end
#
#     if args.has_key? :network
#       cmd = %Q{helm upgrade ethereum #{cwd}/../../deploy/helm/ethereum \
#             --install -n #{ns(args)} --create-namespace \
#             --set geth.args.network='--#{args[:network]}' \
#             --set geth.args.networkID=#{network_id} \
#             --set ethstats.env.websocketSecret=#{SecureRandom.base64 20}
#       }
#     else
#       cmd = %Q{helm upgrade ethereum #{cwd}/../../deploy/helm/ethereum \
#             --install -n #{ns(args)} --create-namespace \
#             --set ethstats.env.webSocketSecret=#{SecureRandom.base64 20}
#       }
#     end
#     }
#
#     system(cmd) or exit 1
#   end
# end
# end

