
type t

val init : int -> int -> t
(** [init s k] initializes the estimator.

    @param s  precision of estimator (s = log(1/δ))
    @param k  error of estimator (k = e/ε)

    The error of the estimator in answering a query for
    f_j is within a factor of ε with probability δ. *)

val add : t -> 'data -> unit
(** [add t j] adds node [j] to estimator [t] *)

val estimate : t -> 'data -> int
(** [estimate t j] returns estimate for node [j] in estimator [t] *)

val min : t -> int
(** [min t] returns the minimum counter value of estimator [t] *)
