exception No_global_fallback of string
class type js_module = object end
val require : string -> ?fallback:string -> js_module Js.t
