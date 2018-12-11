open Urps
open OUnit2
open Printf

let get_counter h j =
  match Hashtbl.find_opt h j with
  | Some c -> c
  | None -> 0

let get_counter_int h j =
  match Hashtbl.find_opt h (Printf.sprintf "%d" j) with
  | Some c -> c
  | None -> 0

let rec stats ?(i=0) ?(max_e=0.) n m sin sout =
  if i = 0
  then printf "\n\nn\tIN%%\tOUT%%\te%%\n\n";
  if i < n
  then
    let pin  = (float_of_int (get_counter_int sin i))  /. (float_of_int m) *. 100. in
    let pout = (float_of_int (get_counter_int sout i)) /. (float_of_int m) *. 100. in
    let e = pout /. (100. /. (float_of_int n)) -. 1. in
    let max_e = if max_e < e then e else max_e in
    printf "%d\t%.2f\t%.2f\t%+.2f\n" i pin pout e;
    stats n m sin sout ~i:(i+1) ~max_e
  else
    begin
      printf "\nmax(e): %+.2f%%\n" max_e;
      max_e
    end

let test_sampler _ctx =
  let c = 700 in
  let s = 10 in
  let k = 50 in
  let idlen = 16 in
  let smpl = Sampler.init c s k idlen in
  let m = 10000 in (* size of input stream *)
  let mp = 0.2 in (* malicious probability *)
  let n = 100 in (* population size *)
  let nm = 10 in (* maliccious population size *)
  let sin = Hashtbl.create n in
  let sout = Hashtbl.create n in

  (* add nodes *)
  for _ = 1 to m
  do
    let r = Random.float 1. in
    let bound =
      if r <= mp
      then nm  (* malicious *)
      else n
    in
    let r = Random.int64 @@ Int64.of_int bound in
    let j = Int64.to_string r in
    let (k, _d) = Sampler.add smpl j r in
    Hashtbl.replace sin  j @@ (get_counter sin  j) + 1;
    Hashtbl.replace sout k @@ (get_counter sout k) + 1;
  done;

  let max_e = stats n m sin sout in
  assert_equal (max_e <= 0.5) true

let suite =
  "suite">:::
    [
      "sampler">:: test_sampler;
    ]

let () =
  Random.self_init ();
  run_test_tt_main suite
