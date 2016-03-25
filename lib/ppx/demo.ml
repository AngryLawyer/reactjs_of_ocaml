let a = [%jsx [div]]
let b = [%jsx [div; className "Stylish div"]]
let c = [%jsx [div; className "Stylish div"; lolName "a"]]

let c' = ReactJS.create_element (Tag_name "div") ~props:(object%js val className = "Stylish div" end) []
