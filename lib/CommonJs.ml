exception No_global_fallback of string
class type js_module = object end

let have_require = Js.Optdef.test ((Js.Unsafe.coerce Js.Unsafe.global)##.require)

let require path ?fallback =
    if have_require then
        (Js.Unsafe.coerce Js.Unsafe.global)##require path
    else
        match fallback with
        | Some fallback -> Js.Unsafe.js_expr fallback
        | None -> raise (No_global_fallback path)
