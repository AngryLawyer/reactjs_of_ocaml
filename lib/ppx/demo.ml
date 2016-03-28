let a = [%jsx [div]]
let b = [%jsx [div; className "Stylish div"]]
let c = [%jsx [div; className "Stylish div"; lolName "a"]]
let d = [%jsx [div; className "Stylish div"; [
]]]
let e = [%jsx [div; className "Stylish div"; [
    [span]
]]]

let c' = ReactJS.create_element (Tag_name "div") ~props:(object%js val className = "Stylish div" end) []
