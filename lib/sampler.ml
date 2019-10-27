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

module Rng = Nocrypto.Rng

module Make
         (Id: Set.OrderedType)
       : S.SAMPLER with type id := Id.t = struct

  module G = Set.Make(Id)

  type id = Id.t

  type 'a t = {
      c: int; (** sampler size *)
      mutable g: G.t; (** ordered set *)
      est: Estimator.t; (** estimator *)
      data: (id, 'a) Hashtbl.t; (** metadata associated with elements of set [g] *)
    }

  (** Initialize sampler *)
  let init c s k =
    let est = Estimator.init s k in
    let g = G.empty in
    let data = Hashtbl.create c in
    { c; g; est; data }

  (** Get random element from set *)
  let rand_elem g =
    let r = Rng.Int.gen (G.cardinal g) in
    let rv =
      G.fold
        (fun e a ->
          match a with
          | (i, v) ->
             if i = r
             then (i + 1, e)
             else (i + 1, v))
        g (0, G.choose g) in
    match rv with
    | (_, v) -> v

  (** Add node [j] from input stream to sampler [t] with metadata [data]

      Return next node in output stream *)
  let add t j data =
    Estimator.add t.est j;
    let fj = Estimator.estimate t.est j in
    let min = Estimator.min t.est in
    t.g <-
      if G.cardinal t.g < t.c then
        begin
          Hashtbl.replace t.data j data;
          G.add j t.g
        end
      else
        begin
          let aj = (float_of_int min) /. (float_of_int fj) in
          if (float_of_int (Rng.Int.gen max_int)) /. (float_of_int max_int) <= aj
          then
            let k = rand_elem t.g in
            Hashtbl.remove t.data k;
            Hashtbl.replace t.data j data;
            G.add j (G.remove k t.g)
          else
            t.g
        end;
    let k = rand_elem t.g in
    let d = Hashtbl.find t.data k in
    (k, d)

end
