let test1 () =
    ignore (ReactJS.create_element (ReactJS.Tag_name "div") [])

let test2 () =
    Alcotest.(check int) "same ints" 5 5

let test3 () =
    Alcotest.(check int) "same ints" 5 4

let test_set = [
    "Test1", `Quick, test1;
    "Test3", `Quick, test3;
    "Test2", `Quick, test2;
]

let () =
    Js.Unsafe.global##.startTests := (fun () ->
        try Alcotest.run ~and_exit:false "My first test" [
            "test_set", test_set
        ] with Alcotest.Test_error -> ()
   )
