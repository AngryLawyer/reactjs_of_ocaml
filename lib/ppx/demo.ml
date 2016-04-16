let e = [%jsx [div; className "Stylish div"; [
    "A string";
    [span];
    [%code call lol [%jsx [div]]]
]]]

let x = [
    Dom_string "A string"
]
