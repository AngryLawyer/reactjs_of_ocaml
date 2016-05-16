open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

#if OCAML_VERSION < (4, 03, 0)
  let nolabel = ""
  let const_string x y =
    Const_string (x, y)
#else
  let nolabel = Nolabel
  let const_string x y =
    Pconst_string (x, y)
#endif

type tag_type =
    | Tag_name
    | React_class

let rec parse_attr pexp_desc loc collector =
    match pexp_desc with
    | {pexp_desc = Pexp_construct ({txt = Lident "::"; loc = loc}, (Some (
        { pexp_desc = Pexp_tuple ([
            { pexp_desc = Pexp_apply (
                {pexp_desc = Pexp_ident ({ txt = Lident attr_name; loc = _})},
                [(_, argument)]
            )};
            next
        ])}
    )))} ->
        parse_attr next loc ((attr_name, argument) :: collector)
    | {pexp_desc = Pexp_construct ({txt = Lident "[]"; loc = _}, None)} ->
        (* Done parsing! *)
        collector
    | {pexp_desc = Pexp_construct ({txt = Lident "::"; loc = _}, Some (
        { pexp_desc = Pexp_tuple ([
            _;
            {pexp_desc = Pexp_construct ({txt = Lident "[]"; loc = _}, None)}
        ])}
    ))} ->
        (* Children element *)
        collector
    | _ -> raise (Location.Error (
        Location.error ~loc "[%jsx] expected a valid attribute"))

let parse_attrs pexp_desc loc =
    (* build up a list of attr-value pairs for making a class *)
    let attr_list = parse_attr pexp_desc loc [] in
    if List.length attr_list == 0 then
        None
    else
        let fields = List.map (fun (attr_name, argument) ->
            let top_argument = Exp.apply ~loc (Exp.ident {txt = Longident.parse "Js.Unsafe.inject"; loc=loc}) [(nolabel, argument)] in
            Exp.tuple [Exp.constant (const_string attr_name None); top_argument]
        ) attr_list in
        let args = [(nolabel, Exp.array fields)] in
        let fragment = Exp.apply ~loc (Exp.ident {txt = Longident.parse "Js.Unsafe.obj"; loc=loc}) args in
#if OCAML_VERSION < (4, 03, 0)
        Some ("props", fragment)
#else
        Some ((Optional "props"), fragment)
#endif

let rec find_children pexp loc =
    match pexp with
    | {pexp_desc = Pexp_construct ({txt = Lident "::"; loc = loc}, (Some (
        { pexp_desc = Pexp_tuple ([
            { pexp_desc = Pexp_apply (
                _, _
            )};
            next
        ])}
    )))} ->
        find_children next loc
    | {pexp_desc = Pexp_construct ({txt = Lident "[]"; loc = _}, None)} ->
        (* Done parsing, no children *)
        None
    | {pexp_desc = Pexp_construct ({txt = Lident "::"; loc = _}, Some (
        { pexp_desc = Pexp_tuple ([
            children;
            {pexp_desc = Pexp_construct ({txt = Lident "[]"; loc = _}, None)}
        ])}
    ))} ->
        (* Children element founnnndd *)
        Some children
    | _ -> raise (Location.Error (
        Location.error ~loc "[%jsx] expected a valid children attribute or none"))

let rec parse_child pexp loc mappers =
    match pexp with
    | {pexp_desc = Pexp_construct ({txt = Lident "[]"; loc = loc}, None)} ->
        Exp.construct {txt = Lident "[]"; loc=loc} None
    | {pexp_desc = Pexp_construct ({txt = Lident "::"; loc = loc}, Some (
        { pexp_desc = Pexp_tuple ([
            child;
            next
        ])}
    ))} ->
        begin
            let constructed_child = match child with
            (* Strings become Dom_strings *)
#if OCAML_VERSION < (4, 03, 0)
            | { pexp_desc = Pexp_constant (Const_string (str, None))} ->
#else
            | { pexp_desc = Pexp_constant (Pconst_string (str, None))} ->
#endif
                Exp.construct {txt = Longident.parse "ReactJS.Dom_string"; loc=loc} (Some (
                    Exp.constant (const_string str None)
                ))
            (* Sub-items are stuffed on the end *)
            | { pexp_desc = Pexp_construct ({txt = Lident "::"; loc = loc}, Some (
                    { pexp_desc=pexp_desc }
                ))
            } ->
                Exp.construct {txt = Longident.parse "ReactJS.React_element"; loc=loc} (Some (dom_parser_inner pexp_desc loc mappers))
            (* Code blocks are returned as-is *)
            | { pexp_desc = Pexp_extension ({txt = "code"; loc = _},
                PStr [{ pstr_desc = Pstr_eval(inner, _)}]
            )} ->
                root_parser mappers inner
            | _ -> raise (Location.Error (
                Location.error ~loc "Invalid child"
            )) in
            Exp.construct {txt = Lident "::"; loc=loc} (Some (
                Exp.tuple [constructed_child; parse_child next loc mappers]
            ))
        end
    | _ -> raise (Location.Error (
        Location.error ~loc "Children must be defined as a list"
    ))
and parse_children pexp_desc loc mappers =
    match find_children pexp_desc loc with
    | Some children_exp ->
        parse_child children_exp loc mappers
    | None -> Exp.construct {txt = Lident "[]"; loc=loc} None

and make_component kind ident props children loc =
    let class_constr = match kind with
        | Tag_name -> (nolabel, Exp.construct {txt = Longident.parse "ReactJS.Tag_name"; loc=loc} (Some (Exp.constant (const_string (String.lowercase ident) None))))
        | React_class -> (nolabel, Exp.construct {txt = Longident.parse "ReactJS.React_class"; loc=loc} (Some (Exp.ident {txt = Lident (String.lowercase ident); loc=loc})))
    in
    let args = match props with
    | Some prop_object -> [class_constr; prop_object; (nolabel, children)]
    | None -> [class_constr; (nolabel, children)] in
    Exp.apply ~loc (Exp.ident {txt = Longident.parse "ReactJS.create_element"; loc=loc}) args

and dom_parser_inner pexp_desc loc mappers =
    match pexp_desc with
    | Pexp_tuple([
        { pexp_desc = Pexp_ident ({txt = Lident ident; loc = _})};
        args
        ]) -> make_component Tag_name ident (parse_attrs args loc) (parse_children args loc mappers) loc
    | Pexp_tuple([
        { pexp_desc = Pexp_construct ({txt = Lident ident; loc = _}, None)};
        args
      ]) -> make_component React_class ident (parse_attrs args loc) (parse_children args loc mappers) loc
    | _ -> raise (Location.Error (
        Location.error ~loc "[%jsx] expected a valid DOM node"))

and dom_parser pexp_desc loc mappers =
    match pexp_desc with
    | Pexp_construct ({loc = loc},
            Some { pexp_desc = desc}
        ) ->
            dom_parser_inner desc loc mappers
    | _ -> raise (Location.Error (
        Location.error ~loc "[%jsx] expected a valid DOM node"))


and single_item_parser pstr loc mappers =
    match pstr with
    | PStr [{ pstr_desc = Pstr_eval({
            pexp_loc = loc; pexp_desc
        }, _)}] ->
            dom_parser pexp_desc loc mappers
    | _ ->
        raise (Location.Error (
            Location.error ~loc "[%jsx] accepts a single DOM node"))

and root_parser mappers expr =
    let mapper, default_mapper = mappers in
    match expr with
    (* Is this an extension node? *)
    | { pexp_desc =
      (* Should have name "jsx". *)
      Pexp_extension ({ txt = "jsx"; loc }, pstr)} ->
          single_item_parser pstr loc mappers
    (* Delegate to the default mapper. *)
    | x ->
        default_mapper.expr mapper x

let jsx_mapper argv =
  { default_mapper with
    expr = fun mapper expr ->
        root_parser (mapper, default_mapper) expr
  }

let () = register "jsx" jsx_mapper
