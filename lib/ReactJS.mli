class type react_element = object end
class type react_class = object end
class type react_props = object end

type tag_type =
    | Tag_name of string
    | React_class of react_class

type content_type =
    | Dom_string of string
    | React_element of react_element Js.t
    | Element_list of content_type list
    | No_content

val create_element : tag_type -> ?props : < .. > Js.t -> content_type list -> react_element Js.t
val set_state : < render : react_element Js.t Js.meth; .. > Js.t -> < .. > Js.t -> unit

val is_valid_element : react_element Js.t -> bool

module type ReactClassSpec = sig
    type props_spec
    type state_spec
end

module type RC = sig
    type props_spec
    type state_spec
    val create_class : < render : react_element Js.t Js.meth; .. > Js.t -> react_class
    val get_props : < render : react_element Js.t Js.meth; .. > Js.t -> props_spec
    val get_state : < render : react_element Js.t Js.meth; .. > Js.t -> state_spec
end

module Make_ReactClass(ClassSpec: ReactClassSpec): RC with type props_spec = ClassSpec.props_spec and type state_spec = ClassSpec.state_spec

module Children : sig
    type t
    val get : < render : react_element Js.t Js.meth; .. > Js.t -> t Js.t option
    val map : (react_element Js.t -> 'a) -> t Js.t -> 'a array
    val as_react_element : t Js.t -> react_element Js.t
end
