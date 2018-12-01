(** URPS: Uniform Random Peer Sampling *)

module UniHash2 : sig

  type t

  val init :
    t

  val hash :
    t -> Int64.t
    -> Int32.t

end

module Estimator : sig

  type t

  val init :
    int -> int
    -> t

  (** [init s k]

      Initialize estimator:

      - [s]: precision of estimator (s = log(1/δ))
      - [k]: error of estimator (k = e/ε)

      The error of the estimator in answering a query for
      f_j is within a factor of ε with probability δ. *)

  val add :
    t -> Int64.t
    -> unit
  (** [add t j]

      Add node [j] to estimator [t] *)

  val estimate :
    t -> Int64.t
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

  type t

  val init :
    int -> int -> int
    -> t
  (** [init c s k]
      Initialize sampler with settings c, s, k:

      - [c]: sampler memory size (size of set Γ)
      - [s]: precision of estimator (s = log(1/δ))
      - [k]: error of estimator (k = e/ε)

      The error of the estimator in answering a query for
      f_j is within a factor of ε with probability δ. *)

  val add :
    t -> Int64.t
    -> Int64.t
  (** [add t j]
      Add node [j] from input stream to sampler [t].

      Return next node in output stream. *)

end
