open Stdint

module Estimator = struct

  type t = {
      s: int;
      k: int;
      h: Sunnyhash.t array;
      f: int array array;
    }

  (** Generate [s] 2-universal hash functions *)
  let rec gen_hash ?(i=0) ?h s keylen =
    match h with
    | None ->
       let h0 = Sunnyhash.init keylen in
       gen_hash s keylen ~h:(Array.make s h0) ~i:(i+1)
    | Some h ->
       if i < s
       then
         begin
           h.(i) <- Sunnyhash.init keylen;
           gen_hash s keylen ~h ~i:(i+1)
         end
       else
         h

  (** Initialize estimator *)
  let init s k keylen =
    let f = Array.make_matrix s k 0 in
    let h = gen_hash s keylen in
    {s; k; h; f}

  (** Add node [j] to [f]:
      increase counters for all F[s][hs(j)] *)
  let rec add_f ?(s=0) t j =
    if s < t.s then
      let hsj = (Int32.to_int (Sunnyhash.hash31 t.h.(s) j)) mod t.k in
      t.f.(s).(hsj) <- t.f.(s).(hsj) + 1;
      add_f t j ~s:(s+1)
    else
      ()

  (** Add node to estimator:
      F[s][hs(j)] <- F[s][hs(j)] + 1 *)
  let add t j =
    add_f t j

  let rec min_fj ?(s=0) ?(min=max_int) t j =
    if s < t.s then
      let hsj = (Int32.to_int (Sunnyhash.hash31 t.h.(s) j)) mod t.k in
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

end

module Sampler = struct

  module G = Set.Make(String)

  type t = {
      c: int;
      mutable g: G.t;
      est: Estimator.t;
    }

  (** Initialize sampler *)
  let init c s k keylen =
    let est = Estimator.init s k keylen in
    let g = G.empty in
    { c; g; est }

  (** Get random element from set *)
  let rand_elem g =
    let r = Random.int @@ G.cardinal g in
    let rv =
      G.fold
        (fun e a ->
          match a with
          | (i, v) ->
             if i = r
             then (i + 1, e)
             else (i + 1, v))
        g (0, "") in
    match rv with
    | (_, v) -> v

  (** Add node [j] from input stream to sampler [t]
      Return next node in output stream *)
  let add t j =
    Estimator.add t.est j;
    let fj = Estimator.estimate t.est j in
    let min = Estimator.min t.est in
    t.g <-
      if G.cardinal t.g < t.c then
        G.add j t.g
      else
        begin
          let aj = (float_of_int min) /. (float_of_int fj) in
          if Random.float 1. <= aj
          then
            let k = rand_elem t.g in
            G.add j @@ G.remove k t.g
          else
            t.g
        end;
    rand_elem t.g

end
