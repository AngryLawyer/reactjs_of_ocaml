let reactDomServer = (Js.Unsafe.variable "ReactDOMServer")

let render_to_string element =
    Js.to_string (Js.Unsafe.meth_call reactDomServer "renderToString" [| Js.Unsafe.inject element |])

let render_to_static_markup element =
    Js.to_string (Js.Unsafe.meth_call reactDomServer "renderToStaticMarkup" [| Js.Unsafe.inject element |])
