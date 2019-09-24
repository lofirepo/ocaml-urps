module type SAMPLER = sig

  type 'a t
  type id

  val init :
    int -> int -> int
    -> 'data t
  (** [init c s k]
      Initialize sampler with settings c, s, k:

      - [c]: sampler memory size (size of set Γ)
      - [s]: precision of estimator (s = log(1/δ))
      - [k]: error of estimator (k = e/ε)

      The error of the estimator in answering a query for
      f_j is within a factor of ε with probability δ.

      The sampler uses the [Nocrypto.Rng] module
      which needs to be initialized before calling this function.
   *)

  val add :
    'data t -> id -> 'data
    -> (id * 'data)
  (** [add t j data]
      Add node [j] from input stream to sampler [t] with metadata [data].

      Return next node in output stream. *)

end
