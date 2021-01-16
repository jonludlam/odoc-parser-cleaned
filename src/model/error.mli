type t

val make :
  ?suggestion:string ->
  ('a, Format.formatter, unit, Location_.span -> t) format4 ->
  'a

val filename_only :
  ?suggestion:string -> ('a, Format.formatter, unit, string -> t) format4 -> 'a

val to_string : t -> string

val raise_exception : t -> _

val to_exception : ('a, t) Result.result -> 'a

val catch : (unit -> 'a) -> ('a, t) Result.result

type 'a with_warnings = { value : 'a; warnings : t list }

type warning_accumulator

val accumulate_warnings : (warning_accumulator -> 'a) -> 'a with_warnings

val warning : warning_accumulator -> t -> unit

val raise_warnings : 'a with_warnings -> 'a
(** Accumulate warnings into a global variable. See [catch_warnings]. *)

val catch_warnings : (unit -> 'a) -> 'a with_warnings
(** Catch warnings accumulated by [raise_warning]. Safe to nest. *)

val catch_errors_and_warnings :
  (unit -> 'a) -> ('a, t) Result.result with_warnings
(** Combination of [catch] and [catch_warnings]. *)

val handle_warnings :
  warn_error:bool -> 'a with_warnings -> ('a, [> `Msg of string ]) Result.result
(** Print warnings to stderr. If [warn_error] is [true] and there was warnings,
    returns an [Error]. *)

val handle_errors_and_warnings :
  warn_error:bool ->
  ('a, t) Result.result with_warnings ->
  ('a, [> `Msg of string ]) Result.result
(** Like [handle_warnings] but works on the output of
    [catch_errors_and_warnings]. Error case is converted into a [`Msg]. *)
