# module Tourmaline::User
#   class Client

#     TIMEOUT = 20.seconds

#     DEFAULTS = {
#       "key": "value"
#     }

#     @td_client : Pointer(Void)

#     @update_manager : UpdateManager

#     def self.ready(**args)
#       new(**args).connect
#     end

#     def initialize(
#       td_client = API.client_create,
#       update_manager = UpdateManager.new(td_client),
#       timeout = TIMEOUT,
#       **extra_config
#     )
#       @td_client = td_client
#       @update_manager = update_manager
#       @ready = false
#       @alive = true
#       @timeout = timeout
#       @config = DEFAULTS.merge(extra_config.to_h)
#       @ready_condition_mutex = Mutex.new
#     end

#   end
# end
