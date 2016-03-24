open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

let single_item_parser pstr loc =
    match pstr with
    | PStr [{ pstr_desc = Pstr_eval({
            pexp_loc = loc; pexp_desc = Pexp_construct (_, _)
        }, _)}] ->
        raise (Location.Error (
            Location.error ~loc "FINE"))
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
