(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *   INRIA, CNRS and contributors - Copyright 1999-2018       *)
(* <O___,, *       (see CREDITS file for the list of authors)           *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

open Ltac_plugin
open Names
open Misctypes
open Tacexpr
open Geninterp
open Quote
open Stdarg
open Tacarg

DECLARE PLUGIN "quote_plugin"

let cont = Id.of_string "cont"
let x = Id.of_string "x"

let make_cont (k : Val.t) (c : EConstr.t) =
  let c = Tacinterp.Value.of_constr c in
  let tac = TacCall (Loc.tag (ArgVar CAst.(make cont), [Reference (ArgVar CAst.(make x))])) in
  let ist = { lfun = Id.Map.add cont k (Id.Map.singleton x c); extra = TacStore.empty; } in
  Tacinterp.eval_tactic_ist ist (TacArg (Loc.tag tac))

TACTIC EXTEND quote
  [ "quote" ident(f) ] -> [ quote f [] ]
| [ "quote" ident(f) "[" ne_ident_list(lc) "]"] -> [ quote f lc ]
| [ "quote" ident(f) "in" constr(c) "using" tactic(k) ] ->
  [ gen_quote (make_cont k) c f [] ]
| [ "quote" ident(f) "[" ne_ident_list(lc) "]"
    "in" constr(c) "using" tactic(k) ] ->
  [ gen_quote (make_cont k) c f lc ]
END
