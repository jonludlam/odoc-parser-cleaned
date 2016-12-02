(*
 * Copyright (c) 2016 Thomas Refis <trefis@janestreet.com>
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

open Tyxml.Html

let keyword keyword = span ~a:[ a_class ["keyword"] ] [ pcdata keyword ]
let module_path ids =
  span ~a:[ a_class ["module-path"] ] [pcdata (String.concat "." ids)]

module Type = struct
  let path p = span ~a:[ a_class ["type-id"] ] p
  let var tv = span ~a:[ a_class ["type-var"] ] [ pcdata tv ]
end

let def_div lst = div ~a:[ a_class ["def" ] ] [ code lst ]

let def_summary lst = summary [ span ~a:[ a_class ["def"] ] lst ]

let make_def ~kind ~id ~code:def ~doc =
  div ~a:[ a_class ["spec"; kind] ; a_id id ] [
    a ~a:[ a_href ("#" ^ id); a_class ["anchor"] ] [];
    div ~a:[ a_class ["def"; kind] ] [ code def ];
    div ~a:[ a_class ["doc"] ] doc;
  ]

let make_spec ~kind ~id ?doc code =
  div ~a:[ a_class ["spec"; kind] ; a_id id ] (
    a ~a:[ a_href ("#" ^ id); a_class ["anchor"] ] [] ::
    div ~a:[ a_class ["def"; kind] ] code ::
    (match doc with
     | None -> []
     | Some doc -> [div ~a:[ a_class ["doc"] ] doc])
  )
