(*
  Copyright (C) 2019 TG x Thoth

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*)

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
