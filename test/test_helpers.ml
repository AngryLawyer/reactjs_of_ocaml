let document = Dom_html.document
let document_body = document##.body
let container =
    Js.Unsafe.eval_string "var e = document.createElement('div'); e.id = 'container'; document.body.appendChild(e);";
    Dom_html.getElementById "container"

let get_raw_html () =
    Js.to_string (container##.innerHTML)

let contains container searched =
    let index = (Js.string container)##indexOf (Js.string searched) in
    index != -1
