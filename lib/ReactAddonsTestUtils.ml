let render_into_document item =
    let test_utils = [%require "react-addons-test-utils"] in
    Js.Unsafe.meth_call test_utils "renderIntoDocument" [| Js.Unsafe.inject item |]
