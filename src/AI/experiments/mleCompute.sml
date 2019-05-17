(* ========================================================================= *)
(* FILE          : mleCompute.sml                                            *)
(* DESCRIPTION   : Direct computation on terms using tree neural network     *)
(* AUTHOR        : (c) Thibault Gauthier, Czech Technical University         *)
(* DATE          : 2019                                                      *)
(* ========================================================================= *)

structure mleCompute :> mleCompute =
struct

open HolKernel Abbrev boolLib aiLib psTermGen mlTreeNeuralNetwork

val ERR = mk_HOL_ERR "mleCompute"

(* -------------------------------------------------------------------------
   Generation of random arithmetical term (to move to psTermGen)
   ------------------------------------------------------------------------- *)

fun random_num_uni operl (nsuc,ntoken) = 
  let val cset = map mk_sucn (List.tabulate (nsuc,I)) @ operl in
    random_term_uni cset (List.tabulate (ntoken, fn x => x + 1), ``:num``)
  end

fun random_num_upto operl (nsuc,ntoken) =
  let val cset = map mk_sucn (List.tabulate (nsuc,I)) @ operl in
    random_term_upto cset (ntoken,``:num``)
  end

(* -------------------------------------------------------------------------
   Creation of test set and training set
   ------------------------------------------------------------------------- *)

fun int_pow a b = 
  if b < 0 then raise ERR "int_pow" "" else 
  if b = 0 then 1 else a * int_pow a (b - 1) 

fun eval_ground tm = 
  (string_to_int o term_to_string o rhs o concl o bossLib.EVAL) tm

fun bin_rep_aux nbit n = 
  if nbit > 0 
  then n mod 2 :: bin_rep_aux (nbit - 1) (n div 2)
  else []

fun bin_rep nbit n = map Real.fromInt (bin_rep_aux nbit n)

fun create_trainset operl (nsuc,noper) (nclass,nbit) =
  let
    val nex = nclass * (int_pow 2 nbit)
    val d = ref (dempty Int.compare)
    val dr = ref (dempty Term.compare)
    fun random_ex () =
      let
        val tm = random_num_uni operl (nsuc,noper)
        val n = eval_ground tm mod nclass
        val nocc = dfind n (!d) handle NotFound => 0
      in
        if nocc >= nex div nclass orelse dmem tm (!dr)
        then random_ex () 
        else 
        (
         d := count_dict (!d) [n];
         dr := dadd tm (bin_rep nbit n) (!dr)
        )
      end
    val _ = d := dempty Int.compare
  in
    ignore (List.tabulate (nex, fn _ => random_ex ()));
    dlist (!dr)
  end

fun create_all_testset operl (nsuc,noper) nbit nex =
  let 
    fun f x = x + 1 
    val l = cartesian_product (List.tabulate (nsuc,f)) 
                              (List.tabulate (noper,f))
    fun mk_ex (n,k) =
      let val tm = random_num_upto operl (n,k) in
        (tm, bin_rep nbit (eval_ground tm))
      end
    fun g (n,k) = List.tabulate (nex, fn _ => mk_ex (n,k))
  in
    map_assoc g l
  end

(* -------------------------------------------------------------------------
   Experiments
   ------------------------------------------------------------------------- *)




end (* struct *)

(* has been moved to train 


fun inter_traintest (train,test) = 
  length (filter (fn x => tmem (fst x) (map fst train)) test)

fun is_accurate tnn (tm,rl) =
  let 
    val rl1 = mlTreeNeuralNetwork.infer_tnn tnn tm 
    val rl2 = combine (rl,rl1)
    fun test (x,y) = Real.abs (x - y) < 0.5  
  in
    if all test rl2 then true else false
  end

fun accuracy_dataset tnn set =
  let val correct = filter (is_accurate tnn) set in
    Real.fromInt (length correct) / Real.fromInt (length set)
  end
*)
(*
app load ["rlData", "aiLib", "rlLib", "mlTreeNeuralNetwork", "psTermGen"];
open rlData aiLib rlLib mlTreeNeuralNetwork psTermGen;

val ERR = mk_HOL_ERR "test";

val cset_glob = map mk_sucn (List.tabulate (8,I)) @ [``SUC``,``$+``,``$*``];

fun mk_tml level ntarget = 
  let 
    val range = List.tabulate (level, fn x => x + 1)
    fun gen () = random_term_uni cset_glob (range,``:num``)
    val d = ref (dempty Term.compare)
    fun loop n = 
      if n > 10 * ntarget then raise ERR "not enough different terms" "" else
      if dlength (!d) >= ntarget then () else
      let val tm = gen () in
        if dmem tm (!d) then () else d := dadd tm () (!d);
        loop (n + 1)
      end
  in
    loop 0; dkeys (!d)
  end

val tml_glob = mk_tml 10 8000;
val train = map_assoc (bin_rep 4 o eval_ground) tml_glob;
val test = first_n 1000 train;


val nn_operl = mk_fast_set oper_compare (operl_of ``0 + SUC 0 * 0``);
val nbit = 4;
val randtnn = random_tnn (24,nbit) nn_operl;
val bsize = 64;
fun f x = (200, x / (Real.fromInt bsize));
val schedule = map f [0.1];
val ncore = 2;
val tnn = prepare_train_tnn (ncore,bsize) randtnn (train,test) schedule;




val operl = [``$+``,``$*``];
val (nsuc,noper) = (4,3);
val (nex,nclass,nbit) = (2000,16,4);
val _ = uni_flag := false;
val test = computation_data operl (nsuc,noper) (nex,nclass,nbit);
val ninter = inter_traintest (train,test);
val nuniq = length (mk_fast_set Term.compare (map fst train));




val operl = [``$+``,``$*``];
val (nsuc,noper) = (8,8);
val (nex,nbit) = (1000,4);
val finaltestset = mk_finaltestset operl (nsuc,noper) nbit nex;
val finalaccuracy = map_snd (accuracy_dataset tnn) finaltestset;
val table = cut_n 8 finalaccuracy;
fun print_table table = 
  let 
    fun f ((i,j),r) = 
      if (i <= 4 andalso j <= 4) 
      then "{\\color{blue} " ^ pad 4 "0" (rts (approx 2 r)) ^ "}"
      else pad 4 "0" (rts (approx 2 r)) 
    fun g l = (its o fst o fst o hd) l ^ " & " ^ 
      String.concatWith " & " (map f l)
  in
    print (String.concatWith "\\\\\n" (map g table) ^ "\\\\\n")
  end
;
print_table table;
  

val s = mk_sucn;
infer_tnn tnn ``^(s 5) + ^(s 3)``;
*)

(*
app load ["rlData", "aiLib", "rlLib", "mlTreeNeuralNetwork", "psTermGen"];
open rlData aiLib rlLib mlTreeNeuralNetwork psTermGen;
load "rlEnv"; open rlEnv;

logfile_glob := "april10";
mlTreeNeuralNetwork.ml_gencode_dir := 
  (!mlTreeNeuralNetwork.ml_gencode_dir) ^ (!logfile_glob);
  rl_gencode_dir := (!rl_gencode_dir) ^ (!logfile_glob);

val operl = [``$+``,``$*``];
val (nsuc,noper) = (1,1);
val (nex,nbit) = (100,1);
val pretargetl =
 map_snd (map fst) (mk_finaltestset operl (nsuc,noper) nbit nex);

val l2 = map_snd (filter (fn x => term_cost x > 0 andalso term_cost x < 50)) pretargetl;
val tml = 

val l3 = map (length o snd) l2;

val finaltargetl = map_snd (map rlGameArithGround.mk_startsit) l2;

val dhtnn = read_dhtnn "dhtnn_april8";
val targetl1 = 
  mk_fast_set Term.compare 
   (List.tabulate (100, fn _ => (random_num operl (nsuc,noper))));

val targetl2 = map rlGameArithGround.mk_startsit targetl1;
val dhtnn = 
  rlEnv.random_dhtnn_gamespec rlGameArithGround.gamespec; 




fun myf targetl =
  (
  let val r = rlEnv.explore_eval 40 dhtnn targetl in
    print_endline ("win " ^ rts r);
    r
  end
  )
;
rlEnv.nsim_glob := 100000;
val result = map (my_explore dhtnn) targetl2;

val table = cut_n 4 result;
fun print_table table = 
  let 
    fun f ((i,j),r) = 
      if (i <= 3 andalso j <= 3) 
      then "{\\color{blue} " ^ pad 4 "0" (rts (approx 2 r)) ^ "}"
      else pad 4 "0" (rts (approx 2 r)) 
    fun g l = (its o fst o fst o hd) l ^ " & " ^ 
      String.concatWith " & " (map f l)
  in
    print (String.concatWith "\\\\\n" (map g table) ^ "\\\\\n")
  end
;
print_table table;


*)

(*
val _ = uniq_flag := false;
val _ = uni_flag := true;
val train = computation_data operl (nsuc,noper) (nex,nclass,nbit);
*)

(* -------------------------------------------------------------------------
   Proof
   ------------------------------------------------------------------------- *)
(*
val axl = [ax1,ax2,ax3,ax4];

fun rw tm = 
  let 
    fun f pos = 
      let fun test x = isSome (paramod_ground x (tm,pos)) in
        exists test axl
      end
  in
    List.find f (all_pos tm)
  end
 
(*
app load ["rlData", "aiLib", "rlLib", "mlTreeNeuralNetwork", "psTermGen"];
open rlData aiLib rlLib mlTreeNeuralNetwork psTermGen;
val tm = ``(SUC 0 + 0) * 0``;
val pos = valOf (rw tm);
val tm1 = hd (List.mapPartial (C paramod_ground (tm,pos)) [ax1,ax2,ax3,ax4]);
*)

fun lo_trace nmax toptm =
  let
    val l = ref []
    val acc = ref 0
    fun loop tm =
      if is_suc_only tm then rev (!l) 
      else if !acc > nmax then [] else
    let 
      val pos = valOf (rw tm)
      val tm' = hd (List.mapPartial (C paramod_ground (tm,pos)) axl)
    in
      (l := (tm,pos) :: !l; acc := length pos + 1 + !acc; loop tm')
    end
  in
    loop toptm
  end

fun expand_trace trace =
  let 
    fun f (tm,pos) = 
      if null pos then [(tm,pos)] 
      else (tm,pos) :: f (tm,butlast pos) 
  in
    List.concat (map (rev o f) trace)
  end

fun number_trace l = rev (number_snd 1 (rev l))

fun full_trace tm = number_trace (expand_trace (lo_trace 200 tm))
fun term_cost tm = length (full_trace tm)

(* dataset *)
fun proof_data_aux tml =
  mk_fast_set 
    (cpl_compare (cpl_compare Term.compare (list_compare Int.compare))
     Int.compare)
  (List.concat (map full_trace tml))

fun proof_data tml =
  let 
    val pdata = proof_data_aux tml;
    val pdata3 = filter (fn x => null (snd (fst x))) pdata;
    val pdata4 = dict_sort compare_imin pdata3;
    val pdata5 = map_fst fst pdata4;
  in
    pdata5
  end

val cset_glob = map mk_sucn (List.tabulate (4,I)) @ [``$+``,``$*``];
val tml_glob = mk_fast_set Term.compare (gen_term_size 8 (``:num``,cset_glob));
val proof_data_glob = proof_data tml_glob;

(*
app load ["rlData", "aiLib", "rlLib", "mlTreeNeuralNetwork", "psTermGen"];
open rlData aiLib rlLib mlTreeNeuralNetwork psTermGen;

val l = map (term_cost o fst) proof_data_glob;
val d = count_dict (dempty Int.compare) l;
val l1 = dlist d;
fun f (a,b) = its a ^ " " ^ its b;
writel "/home/thibault/data" (map f l1);



val pdata2 = dict_sort Int.compare (map snd pdata1);
*)

*)



(*
val (trainset,testset) = mk_ttset_ground2 7;
(* inference *)
fun binary_of_int x = Term [QUOTE (its x)];

fun bin_rep nbit n = 
  if nbit > 0 
  then n mod 2 :: bin_rep (nbit - 1) (n div 2)
  else [];

fun numeral_pos (tm,pos) = 
  let 
    val (oper,argl) = strip_comb tm 
    fun f i x = numeral_pos (x,pos @ [i])
  in
    if term_eq oper ``NUMERAL`` orelse term_eq oper ``0``
    then [(tm,pos)] 
    else List.concat (mapi f argl)
  end
;
fun eval_ground tm = 
  (string_to_int o term_to_string o rhs o concl o bossLib.EVAL) tm
;
fun random_ex k =
      let
        val cset = map binary_of_int (List.tabulate (8,I)) @ [``$+``]
        val tm1 = random_term_upto cset (k,``:num``)
        val tm2 = mk_eq (tm1, binary_of_int (eval_ground tm1 mod 8))
        val (subtm,pos) = random_elem (numeral_pos (tm2,[]))
        val tm3 = subst_pos (tm2,pos) ``x:num``
        val n = eval_ground subtm
      in
        (tm3, map Real.fromInt (bin_rep 1 n))
      end
;

fun accuracy_one (tm,rl) =
  let 
    val rl1 = infer_tnn tnn tm 
    val rl2 = combine (rl,rl1)
    fun test (x,y) = 0.5 > Real.abs (x - y)  
  in
    if all test rl2 then NONE else SOME tm
  end;

fun f k =
  let
    val testset = List.tabulate (1000, fn n => random_ex k);
    val l = List.mapPartial accuracy_one testset;
  in
    length l
  end

val l1 = map f [15,17,19,21];


tts “2 + 5 * 1 + 3”;

infer_tnn tnn ``2 + 5 * 1``;

infer_tnn tnn ``7 + 3``;



todo design good datasets for supervised learning.

make a dataset when you can evaluate a expression 
with binary output.

equations solving. 
?x. x * x = 3.
!a. a+b=b+a.
val s = mk_sucn;X
modular equations.
linear equations.
small non linear equation. 
diophantine equations.

*)





