module Rng = Nocrypto.Rng

type t = {
    s: int;
    k: int;
    h: int array;
    f: int array array;
  }

(** Generate [s] random seeds for 2-independent hash functions *)
let gen_seed s =
  let h = Array.make s 0 in
  Array.iteri (fun i _el -> h.(i) <- Rng.Int.gen max_int) h;
  h

(** Initialize estimator *)
let init s k =
  let f = Array.make_matrix s k 0 in
  let h = gen_seed s in
  {s; k; h; f }

(** MurMur3 hash *)
let hash t s j =
  Hashtbl.seeded_hash t.h.(s) j

(** Add node [j] to [f].
      Increase counters for all F[s][hs(j)] *)
let rec add_f ?(s=0) t j =
  if s < t.s then
    let hsj = (hash t s j) mod t.k in
    t.f.(s).(hsj) <- t.f.(s).(hsj) + 1;
    add_f t j ~s:(s+1)
  else
    ()

(** Add node to estimator.
      F[s][hs(j)] <- F[s][hs(j)] + 1 *)
let add t j =
  add_f t j

let rec min_fj ?(s=0) ?(min=max_int) t j =
  if s < t.s then
    let hsj = (hash t s j) mod t.k in
    let v = t.f.(s).(hsj) in
    let min = if v < min then v else min in
    min_fj t j ~min ~s:(s+1)
  else
    min

(** Get the minimum value in F[s] *)
let rec min_fs ?(k=0) t min s =
  if k < t.k then
    let v = t.f.(s).(k) in
    let min = if v < min then v else min in
    min_fs t min s ~k:(k+1)
  else
    min

(** Get the minimum value in F *)
let rec min_f ?(s=0) ?(min=max_int) t =
  if s < t.s then
    let min = min_fs t min s in
    min_f t ~min ~s:(s+1)
  else
    min

(** Get the minimum among the s values of ˆ
      F[v][hv(j)] (1 <= v <= s) *)
let estimate t j =
  min_fj t j

(** Get the minimum value in F *)
let min t =
  min_f t
