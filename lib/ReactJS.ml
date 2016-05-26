let reactJs = [%require_or_default "react" "window.React"]
class type react_element = object end
class type react_class = object end
class type react_props = object end

let log i =
    Firebug.console##log i

type tag_type =
    | Tag_name of string
    | React_class of react_class

type content_type =
    | Dom_string of string
    | React_element of react_element Js.t
    | Element_list of content_type list
    | No_content

let rec content_list_to_js content_list =
    List.map (function
        | Dom_string s -> Js.Unsafe.inject (Js.string s)
        | React_element e -> Js.Unsafe.inject e
        | Element_list l -> Js.Unsafe.inject (
            Js.array (
                Array.of_list (content_list_to_js l)
            )
        )
        | No_content -> Js.Unsafe.inject Js.null
    ) content_list

let create_element dom_class ?props content_list =
    let item_class = match dom_class with
    | Tag_name s -> Js.Unsafe.inject (Js.string s)
    | React_class r -> Js.Unsafe.inject r in

    let props = match props with
    | Some props -> Js.Unsafe.inject props
    | None -> Js.Unsafe.inject Js.null in

    (* build up our children *)
    let content = content_list_to_js content_list in

    let create_element = Js.Unsafe.get reactJs "createElement" in
    let args = Js.array (Array.of_list ([
        item_class;
        props;
    ] @ content)) in
    Js.Unsafe.meth_call create_element "apply" [| Js.Unsafe.inject Js.null; Js.Unsafe.inject args |]

let set_state self values =
    Js.Unsafe.meth_call self "setState" [| Js.Unsafe.inject values |]

let is_valid_element element =
    Js.Unsafe.meth_call reactJs "isValidElement" [| Js.Unsafe.inject element |]

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

module Make_ReactClass(ClassSpec: ReactClassSpec) = struct
    type props_spec = ClassSpec.props_spec
    type state_spec = ClassSpec.state_spec

    let create_class spec =
        Js.Unsafe.meth_call reactJs "createClass" [| Js.Unsafe.inject spec |]

    let get_props self =
        Js.Unsafe.get self "props"

    let get_state self =
        Js.Unsafe.get self "state"
end

module Children = struct
    type t = react_element

    let children_module = Js.Unsafe.get reactJs "Children"

    let get self =
        Js.Opt.to_option (Js.Unsafe.coerce (Js.Unsafe.get self "props"))##.children

    let map f children =
        let js_array = Js.Unsafe.meth_call children_module "map" [| Js.Unsafe.inject children; Js.Unsafe.inject f |] in
        Js.to_array js_array

    let as_react_element children =
        (Js.Unsafe.coerce children)
end
