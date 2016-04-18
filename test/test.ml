let test1 () =
    ignore (ReactJS.create_element (ReactJS.Tag_name "div") [])

let test_set = [
    "Test1", `Quick, test1
]

let () =
    Alcotest.run ~and_exit:false "My first test" [
        "test_set", test_set
    ]
