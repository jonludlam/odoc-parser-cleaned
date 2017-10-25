(*
 * Copyright (c) 2014 Leo White <leo@lpw25.net>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open DocOck

let it's_all_the_same ~env ~output input reader =
  let fn = Fs.File.to_string input in
  match reader fn with
  | Not_an_interface  -> failwith "Not_an_interface"
  | Wrong_version  -> failwith "Wrong_version"
  | Corrupted  -> failwith "Corrupted"
  | Not_a_typedtree  -> failwith "Not_a_typedtree"
  | Not_an_implementation  -> failwith "Not_an_implementation"
  | Ok unit ->
    if not unit.Types.Unit.interface then (
      Printf.eprintf "WARNING: not processing the \"interface\" file.%s\n%!"
        (if not (Filename.check_suffix fn "cmt") then "" (* ? *)
         else Printf.sprintf " Using %S while you should use the .cmti file" fn)
    );
    let resolve_env = Env.build env (`Unit unit) in
    let resolved = resolve (Env.resolver resolve_env) unit in
    (* [expand unit] fetches [unit] from [env] to get the expansion of local, previously
       defined, elements. We'd rather it got back the resolved bit so we rebuild an
       environment with the resolved unit.
       Note that this is shitty and once rewritten expand should not fetch the unit it is
       working on. *)
    let expand_env = Env.build env (`Unit resolved) in
    Unit.save output (expand (Env.expander expand_env) resolved)

let root_of_unit ~package ~hidden unit_name digest =
  let file = Root.Odoc_file.create_unit ~force_hidden:hidden unit_name in
  Root.create ~package ~file ~digest

let cmti ~env ~package ~hidden ~output input =
  it's_all_the_same ~env ~output input
    (read_cmti @@ root_of_unit ~package ~hidden)

let cmt ~env ~package ~hidden ~output input =
  it's_all_the_same ~env ~output input
    (read_cmt @@ root_of_unit ~package ~hidden)

let cmi ~env ~package ~hidden ~output input =
  it's_all_the_same ~env ~output input
    (read_cmi @@ root_of_unit ~package ~hidden)

let mld ~env ~package ~output input =
  let root_name =
    let page_dash_root =
      Filename.chop_extension (Fs.File.(to_string @@ basename output))
    in
    String.sub page_dash_root (String.length "page-")
      (String.length page_dash_root - String.length "page-")
  in
  let digest = Digest.file (Fs.File.to_string input) in
  let root =
    let file = Root.Odoc_file.create_page root_name in
    Root.create ~package ~file ~digest
  in
  let name = DocOck.Paths.Identifier.Page (root, root_name) in
  let location =
    let pos =
      Lexing.{
        pos_fname = Fs.File.to_string input;
        pos_lnum = 0;
        pos_cnum = 0;
        pos_bol = 0
      }
    in
    Location.{ loc_start = pos; loc_end = pos; loc_ghost = true }
  in
  match Fs.File.read input with
  | Error (`Msg s) ->
    Printf.eprintf "ERROR: %s\n%!" s;
    exit 1
  | Ok str ->
    let content =
      match DocOck.Attrs.read_string name location str with
      | Stop -> DocOck.Types.Documentation.Ok { text = [] ; tags = [] } (* TODO: Error? *)
      | Documentation content -> content
    in
    (* This is a mess. *)
    let page = DocOck.Types.Page.{ name; content; digest } in
    let page = DocOckLookup.lookup_page page in
    let env = Env.build env (`Page page) in
    let resolved = DocOck.resolve_page (Env.resolver env) page in
    (* TODO? expand *)
    Page.save output resolved
