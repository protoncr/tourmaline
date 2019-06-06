@[Link(ldflags: "`command -v pkg-config > /dev/null && pkg-config --libs openssl zlib gperf 2> /dev/null|| printf %s '-L./ext/ -ltdjson'`")]
lib TDLib
  alias TdLogFatalErrorCallbackPtr = (LibC::Char* -> Void)
  fun td_json_client_create : Void*
  fun td_json_client_destroy(client : Void*)
  fun td_json_client_execute(client : Void*, request : LibC::Char*) : LibC::Char*
  fun td_json_client_receive(client : Void*, timeout : LibC::Double) : LibC::Char*
  fun td_json_client_send(client : Void*, request : LibC::Char*)
  fun td_set_log_fatal_error_callback(callback : TdLogFatalErrorCallbackPtr)
  fun td_set_log_file_path(file_path : LibC::Char*) : LibC::Int
  fun td_set_log_max_file_size(max_file_size : LibC::LongLong)
  fun td_set_log_verbosity_level(new_verbosity_level : LibC::Int)
end
