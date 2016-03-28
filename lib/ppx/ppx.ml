open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

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
    | _ -> raise (Location.Error (
        Location.error ~loc "[%jsx] expected a valid attribute"))

let parse_attrs pexp_desc loc =
    (* build up a list of attr-value pairs for making a class *)
    let attr_list = parse_attr pexp_desc loc [] in
    if List.length attr_list == 0 then
        None
    else
        Some ("props", Exp.extension ({txt="js"; loc=loc}, 
            PStr [
                Str.eval (
                    Exp.object_ (
                        Cstr.mk (Pat.any ()) [
                        ]
                    )
                )
            ]
        ))

let make_component kind ident props loc =
    let class_constr = match kind with
        | Tag_name -> ("", Exp.construct {txt = Lident "Tag_name"; loc=loc} (Some (Exp.constant (Const_string (String.lowercase ident, None)))))
        | React_class -> ("", Exp.construct {txt = Lident "React_class"; loc=loc} (Some (Exp.ident {txt = Lident (String.lowercase ident); loc=loc})))
    in
    let args = match props with
    | Some prop_object -> [class_constr; prop_object; ("", Exp.construct {txt = Lident "[]"; loc=loc} None)]
    | None -> [class_constr; ("", Exp.construct {txt = Lident "[]"; loc=loc} None)] in
    Exp.apply ~loc (Exp.ident {txt = Lident "ReactJS.create_element"; loc=loc}) args


let dom_parser_inner pexp_desc loc = 
    match pexp_desc with
    | Pexp_tuple([
        { pexp_desc = Pexp_ident ({txt = Lident ident; loc = _})};
        args
      ]) -> make_component Tag_name ident (parse_attrs args loc) loc
    | Pexp_tuple([
        { pexp_desc = Pexp_construct ({txt = Lident ident; loc = _}, None)};
        args
      ]) -> make_component React_class ident (parse_attrs args loc) loc
    | _ -> raise (Location.Error (
        Location.error ~loc "[%jsx] expected a valid DOM node"))

let dom_parser pexp_desc loc =
    match pexp_desc with
    | Pexp_construct ({loc = loc},
            Some { pexp_desc = desc}
        ) ->
            dom_parser_inner desc loc
    | _ -> raise (Location.Error (
        Location.error ~loc "[%jsx] expected a valid DOM node"))


let single_item_parser pstr loc =
    match pstr with
    | PStr [{ pstr_desc = Pstr_eval({
            pexp_loc = loc; pexp_desc
        }, _)}] ->
            dom_parser pexp_desc loc
    | _ ->
        raise (Location.Error (
            Location.error ~loc "[%jsx] accepts a single DOM node"))

let jsx_mapper argv =
  { default_mapper with
    expr = fun mapper expr ->
      match expr with
      (* Is this an extension node? *)
      | { pexp_desc =
          (* Should have name "jsx". *)
          Pexp_extension ({ txt = "jsx"; loc }, pstr)} ->
              single_item_parser pstr loc
      (* Delegate to the default mapper. *)
      | x -> default_mapper.expr mapper x;
  }

let () = register "jsx" jsx_mapper

(*        begin match pstr with
        | (* Should have a single structure item, which is evaluation of a constant string. *)
          PStr [{ pstr_desc = Pstr_eval ({ pexp_loc  = loc;
                               pexp_desc = Pexp_constant (Const_string (sym, None))}, _)}] ->
          (* Replace with a constant string with the value from the environment. *)
          Exp.constant ~loc (Const_string ("LOL", None))
        | _ ->
          raise (Location.Error (
                  Location.error ~loc "[%jsx] accepts a single DOM node"))
        end*)
