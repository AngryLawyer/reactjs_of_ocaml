let () = [%jsx
    [div; className "comment" [
        [h2; className "commentAuthor"; items (getProp props "author")];
        "This is one comment";
        getProp props children
    ]]
]
