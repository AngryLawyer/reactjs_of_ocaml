class type react_component = object
end

let reactDom = [%require_or_default "react-dom" "window.ReactDOM"]

let render item target =
    Js.Unsafe.meth_call reactDom "render" [| Js.Unsafe.inject item; Js.Unsafe.inject target |]
