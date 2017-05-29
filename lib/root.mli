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

module Package : sig

  type t

  val create : string -> t

  val to_string : t -> string
end

module Unit : sig

  type t = private {
    name : string;
    hidden : bool;
  }

  val create : force_hidden:bool -> string -> t
end

module Digest = Digest

type t

val equal : t -> t -> bool
val hash  : t -> int

val create : package:Package.t -> unit:Unit.t -> digest:Digest.t -> t

val digest : t -> Digest.t
val package: t -> Package.t
val unit   : t -> Unit.t

val to_string : t -> string

module Xml : sig

  val parse : Xmlm.input -> t

  val fold : t DocOckXmlFold.t

end

module Table : Hashtbl.S with type key = t
