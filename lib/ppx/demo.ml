let () = [%jsx
    [div className="comment" [
        [h2 className="commentAuthor" items=[%code getProp props "author"]]
        "This is one comment"
        [%code getProp props children]
    ]]
]
