(* Test creating a new react element *)
let create_element () =
    let element = (ReactJS.create_element (ReactJS.Tag_name "div") []) in
    Alcotest.(check bool) "is a valid element" true (ReactJS.is_valid_element element)


module My_class = ReactJS.Make_ReactClass(struct
    type props_spec = < name: string Js.readonly_prop > Js.t
    type state_spec = <  > Js.t
end)

(* Test defining and creating a class, as well as accesing children *)
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
    Alcotest.(check string) "contains our Hello message" "Hello" begin
        match Js.Opt.to_option element with
        | Some x ->
            Js.to_string x##.innerHTML
        | None -> Alcotest.fail "No element found"
    end


(* Test accessing the opaque Children type *)
let test_get_children () =
    let react_class = My_class.create_class(object%js (self)
        method render =
            let children = match ReactJS.Children.get self with
            | Some children -> ReactJS.React_element (ReactJS.Children.as_react_element children)
            | None -> ReactJS.No_content in
            (ReactJS.create_element (ReactJS.Tag_name "span") [
                children
            ])
    end) in
    let element = ReactJS.create_element (ReactJS.React_class react_class) ~props:(object%js val name = "Hello" end) [ReactJS.Dom_string "Hello again"] in
    let rendered = (ReactAddonsTestUtils.render_into_document element) in
    let element = ReactDOM.find_dom_node rendered in
    Alcotest.(check string) "contains our Hello again message" "Hello again" begin
        match Js.Opt.to_option element with
        | Some x ->
            Js.to_string x##.innerHTML
        | None -> Alcotest.fail "No element found"
    end

let test_map_children () =
    let react_class = My_class.create_class(object%js (self)
        method render =
            let children = match ReactJS.Children.get self with
            | Some children ->
                let mapped = ReactJS.Children.map (fun element -> element) children in
                Firebug.console##warn mapped;
                ReactJS.Element_list (List.map (fun x -> ReactJS.React_element x) (Array.to_list mapped))
            | None -> ReactJS.No_content in
            (ReactJS.create_element (ReactJS.Tag_name "div") [
                children
            ])
    end) in
    let element = ReactJS.create_element (ReactJS.React_class react_class) ~props:(object%js val name = "Hello" end) [ReactJS.Dom_string "Hello"; ReactJS.Dom_string "Goodbye"] in
    let rendered = (ReactAddonsTestUtils.render_into_document element) in
    let element = ReactDOM.find_dom_node rendered in
    Alcotest.(check string) "contains our HelloGoodbye message" "HelloGoodbye" begin
        match Js.Opt.to_option element with
        | Some x ->
            Js.to_string x##.outerHTML
        | None -> Alcotest.fail "No element found"
    end

let reactjs_test_set = [
    "create_element", `Quick, create_element;
    "create_class", `Quick, create_class;
    "test_get_children", `Quick, test_get_children;
    "test_map_children", `Quick, test_map_children;
]

let () =
    Js.Unsafe.global##.startTests := (fun () ->
        try Alcotest.run ~and_exit:false "ReactJs Test Suite" [
            "ReactJS", reactjs_test_set;
        ] with Alcotest.Test_error -> ()
   )
