class type react_component = object
end

let reactDom = (Js.Unsafe.variable "ReactDOM")

let render item target =
    Js.Unsafe.meth_call reactDom "render" [| Js.Unsafe.inject item; Js.Unsafe.inject target |]
