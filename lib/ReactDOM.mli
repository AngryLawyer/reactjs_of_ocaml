class type react_component = object
end

val render : ReactJS.react_element Js.t -> Dom_html.element Js.t -> react_component Js.t
val find_dom_node : react_component Js.t -> Dom_html.element Js.t Js.opt
