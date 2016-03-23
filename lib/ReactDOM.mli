class type react_component = object
end

val render : ReactJS.react_element Js.t -> Dom_html.element Js.t -> react_component Js.t
