(** URPS: Uniform Random Peer Sampling *)

module Estimator : sig

  type t

  val init :
    int -> int -> int
    -> t

  (** [init s k idlen]

      Initialize estimator:

      - [s]: precision of estimator (s = log(1/δ))
      - [k]: error of estimator (k = e/ε)
      - [idlen]: maximum length of node ID string values

      The error of the estimator in answering a query for
      f_j is within a factor of ε with probability δ. *)

  val add :
    t -> string
    -> unit
  (** [add t j]

      Add node [j] to estimator [t] *)

  val estimate :
    t -> string
    -> int
  (** [estimate t j].

      Get estimate for node [j] in estimator [t] *)

  val min :
    t
    -> int
  (** [min t]

      Get the minimum counter value of estimator [t] *)

end


module Sampler : sig

  type 'a t

  val init :
    int -> int -> int -> int
    -> 'a t
  (** [init c s k idlen]
      Initialize sampler with settings c, s, k:

      - [c]: sampler memory size (size of set Γ)
      - [s]: precision of estimator (s = log(1/δ))
      - [k]: error of estimator (k = e/ε)
      - [idlen]: maximum length of node ID string values

      The error of the estimator in answering a query for
      f_j is within a factor of ε with probability δ.

      The sampler uses the [Random] module
      which needs to be initialized before calling this function.
   *)

  val add :
    'a t -> string -> 'a
    -> (string * 'a)
  (** [add t j]
      Add node [j] from input stream to sampler [t].

      Return next node in output stream. *)

end
