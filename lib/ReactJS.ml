let reactJs = (Js.Unsafe.variable "React")
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

let create_class spec =
    Js.Unsafe.meth_call reactJs "createClass" [| Js.Unsafe.inject spec |]

let get_props self =
    Js.Unsafe.get self "props"

let get_prop react_props key =
    Js.Optdef.to_option (Js.Unsafe.get react_props key)
