(*
 * Copyright (c) 2014 Leo White <lpw25@cl.cam.ac.uk>
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



let empty_body = []

let empty : Model.Comment.t = Ok empty_body



let read_attributes parent _id attrs =
  let ocaml_deprecated = ref None in
  let rec loop first nb_deprecated acc : _ -> Model.Comment.t =
    function
    | ({Location.txt =
          ("doc" | "ocaml.doc"); loc = _loc}, payload) :: rest -> begin
        match Payload.read payload with
        | Some (str, loc) -> begin
            let _start_pos = loc.Location.loc_start in
            let parsed =
              Parser_.parse ~containing_definition:parent ~comment_text:str in
            match parsed with
            | Ok comment -> begin
                loop false 0 (acc @ comment) rest
              end
            | Error err -> Error err
          end
        | None -> failwith "TODO"
      end
    | _ :: rest -> loop first nb_deprecated acc rest
    | [] -> begin
        match nb_deprecated, !ocaml_deprecated with
        | 0, Some _tag -> Ok acc
        | _, _ -> Ok acc
      end
  in
    loop true 0 empty_body attrs

let read_string parent loc str : Model.Comment.comment =
  let _start_pos = loc.Location.loc_start in
  let doc : Model.Comment.t =
    Parser_.parse ~containing_definition:parent ~comment_text:str in
  Documentation doc

let read_comment parent
    : Parsetree.attribute -> Model.Comment.comment option =

  function
  | ({Location.txt =
        ("text" | "ocaml.text"); loc = _loc}, payload) -> begin
      match Payload.read payload with
      | Some ("/*", _loc) -> Some Stop
      | Some (str, loc) -> Some (read_string parent loc str)
      | None ->
        failwith "TODO"
          (* let doc : Model.Comment.t =
            Error (invalid_attribute_error parent loc) in
            Some (Documentation doc) *)
    end
  | _ -> None

let read_comments parent attrs =
  let coms =
    List.fold_left
      (fun acc attr ->
         match read_comment parent attr  with
         | None -> acc
         | Some com -> com :: acc)
      [] attrs
  in
    List.rev coms
