class type react_component = object
end

let react_dom = [%require_or_default "react-dom" "window.ReactDOM"]

let render item target =
    Js.Unsafe.meth_call react_dom "render" [| Js.Unsafe.inject item; Js.Unsafe.inject target |]

let find_dom_node item =
    Js.Unsafe.meth_call react_dom "findDOMNode" [| Js.Unsafe.inject item |]
