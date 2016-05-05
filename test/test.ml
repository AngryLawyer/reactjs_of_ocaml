let create_element () =
    let element = (ReactJS.create_element (ReactJS.Tag_name "div") []) in
    Alcotest.(check bool) "is a valid element" (ReactJS.is_valid_element element) true


module My_class = ReactJS.Make_ReactClass(struct
    type props_spec = < name: string Js.readonly_prop > Js.t
    type state_spec = <  > Js.t
end)

let create_class () =
    let react_class = My_class.create_class(object%js (self)
        method render =
            let props = My_class.get_props self in
            (ReactJS.create_element (ReactJS.Tag_name "span") [
                ReactJS.Dom_string (props##.name)
            ])
    end) in
    let element = ReactJS.create_element (ReactJS.React_class react_class) ~props:(object%js val name = "Hello" end) [] in
    (* Check we get the doodad out the other end *)
    let rendered = (ReactAddonsTestUtils.render_into_document element) in
    let element = ReactDOM.find_dom_node rendered in
    Alcotest.(check bool) "contains our Hello message" begin
        match Js.Opt.to_option element with
        | Some x ->
            let content = Js.to_string x##.innerHTML in
            content = "Hello"
        | None -> false
    end true


let reactjs_test_set = [
    "create_element", `Quick, create_element;
    "create_class", `Quick, create_class;
]

let () =
    Js.Unsafe.global##.startTests := (fun () ->
        try Alcotest.run ~and_exit:false "ReactJs Test Suite" [
            "ReactJS", reactjs_test_set;
        ] with Alcotest.Test_error -> ()
   )
