A JSX-like ppx for reactjs_of_ocaml

This ppx expects an input of the following sort of shape:

```
let () = [%jsx [div; className "Stylish div"; [
    "A string child";
    [span [
        "Some more content"
    ]];
    [%code a_function ()]
]]]
```
