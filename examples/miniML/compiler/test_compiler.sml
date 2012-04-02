val _ = map load ["rich_listTheory","compileProofsTheory","stringLib","ml_translatorLib"]

val REPLACE_ELEMENT_compute =
  CONV_RULE numLib.SUC_TO_NUMERAL_DEFN_CONV rich_listTheory.REPLACE_ELEMENT_DEF

val ITSET_FOLDL = prove(
``∀f s a. ITSET f s a = if FINITE s then FOLDL (combin$C f) a (SET_TO_LIST s) else ARB``, SRW_TAC[][listTheory.ITSET_eq_FOLDL_SET_TO_LIST] THEN
   SRW_TAC[][Once pred_setTheory.ITSET_def])

val compset = listSimps.list_compset()

val _ = computeLib.add_thms (map computeLib.strictify_thm
[ listTheory.LIST_TO_SET_THM
, listTheory.SUM
, REPLACE_ELEMENT_compute
, pred_setTheory.EMPTY_DIFF
, pred_setTheory.INSERT_DIFF
, pred_setTheory.FINITE_EMPTY
, pred_setTheory.FINITE_INSERT
, pred_setTheory.FINITE_UNION
, pred_setTheory.NOT_EMPTY_INSERT
, pred_setTheory.NOT_INSERT_EMPTY
, pred_setTheory.NOT_IN_EMPTY
, pred_setTheory.IN_INSERT
, pred_setTheory.IN_UNION
, pred_setTheory.UNION_EMPTY
, pred_setTheory.INSERT_UNION
, pred_setTheory.EMPTY_DELETE
, pred_setTheory.DELETE_INSERT
, pred_setTheory.IN_COMPL
, pred_setTheory.CARD_EMPTY
, pred_setTheory.IMAGE_EMPTY
, pred_setTheory.IMAGE_INSERT
, pairTheory.FST
, pairTheory.SND
, combinTheory.C_DEF
, optionTheory.IS_SOME_DEF
, optionTheory.THE_DEF
, finite_mapTheory.FAPPLY_FUPDATE_THM
, finite_mapTheory.FRANGE_FEMPTY
, finite_mapTheory.FRANGE_FUPDATE
, finite_mapTheory.FINITE_FRANGE
, finite_mapTheory.DRESTRICT_FEMPTY
, finite_mapTheory.DRESTRICT_FUPDATE
, compileProofsTheory.FINITE_free_vars
, BytecodeTheory.bool_to_int_def
, compileProofsTheory.remove_Gt_Geq_def
, compileProofsTheory.remove_mat_exp_def
, compileProofsTheory.exp_to_Cexp_def
, compileProofsTheory.pat_to_Cpat_def
, compileProofsTheory.free_vars_def
, compileProofsTheory.remove_mat_def
, CompileTheory.remove_mat_vp_def
, CompileTheory.extend_def
, CompileTheory.incsz_def
, CompileTheory.decsz_def
, CompileTheory.sdt_def
, CompileTheory.ldt_def
, CompileTheory.emit_def
, CompileTheory.emit_ec_def
, CompileTheory.prim2_to_bc_def
, CompileTheory.error_to_int_def
, CompileTheory.i0_def
, CompileTheory.i1_def
, CompileTheory.i2_def
, CompileTheory.find_index_def
, compileProofsTheory.compile_varref_def
, compileProofsTheory.replace_calls_def
, compileProofsTheory.compile_def
, integerTheory.NUM_OF_INT
, CompileTheory.lookup_conv_ty_def
, CompileTheory.compiler_state_accessors
, CompileTheory.compiler_state_updates_eq_literal
, CompileTheory.compiler_state_accfupds
, CompileTheory.compiler_state_fupdfupds
, CompileTheory.compiler_state_literal_11
, CompileTheory.compiler_state_fupdfupds_comp
, CompileTheory.compiler_state_fupdcanon
, CompileTheory.compiler_state_fupdcanon_comp
, CompileTheory.repl_state_accessors
, CompileTheory.repl_state_updates_eq_literal
, CompileTheory.repl_state_accfupds
, CompileTheory.repl_state_fupdfupds
, CompileTheory.repl_state_literal_11
, CompileTheory.repl_state_fupdfupds_comp
, CompileTheory.repl_state_fupdcanon
, CompileTheory.repl_state_fupdcanon_comp
, CompileTheory.compile_exp_def
, compileProofsTheory.repl_dec_def
, CompileTheory.repl_exp_def
, CompileTheory.init_repl_state_def
, CompileTheory.init_compiler_state_def
, compileProofsTheory.number_constructors_def
, CompileTheory.exp_to_Cexp_state_accessors
, CompileTheory.exp_to_Cexp_state_updates_eq_literal
, CompileTheory.exp_to_Cexp_state_accfupds
, CompileTheory.exp_to_Cexp_state_fupdfupds
, CompileTheory.exp_to_Cexp_state_literal_11
, CompileTheory.exp_to_Cexp_state_fupdfupds_comp
, CompileTheory.exp_to_Cexp_state_fupdcanon
, CompileTheory.exp_to_Cexp_state_fupdcanon_comp
, CompileTheory.t_to_nt_def
, compileProofsTheory.bcv_to_v_def
, compileProofsTheory.inst_arg_def
, compileProofsTheory.pat_vars_def
, compileProofsTheory.fold_num_def
, CompileTheory.pad_def
, CompileTheory.mv_def
, combinTheory.K_o_THM
, combinTheory.K_THM
, pairTheory.UNCURRY
, ITSET_FOLDL
, stringTheory.CHAR_EQ_THM
]) compset

val _ = computeLib.add_thms (map computeLib.lazyfy_thm
[ CompileTheory.call_context_case_def
, pairTheory.pair_case_thm
, optionTheory.option_case_compute
, MiniMLTheory.opn_case_def
, MiniMLTheory.opb_case_def
, CompileTheory.nt_case_def
]) compset

val _ = computeLib.set_skip compset combinSyntax.K_tm (SOME 1)
val _ = computeLib.add_conv (stringLib.ord_tm,1,stringLib.ORD_CHR_CONV) compset
val _ = computeLib.add_conv (pred_setSyntax.card_tm,1,PFset_conv.CARD_CONV) compset

val eval = computeLib.CBV_CONV compset

val _ = computeLib.add_conv (``least_not_in``,1,
  fn tm => let
  val (_,[s]) = boolSyntax.strip_comb tm
  val finite = EQT_ELIM (eval ``FINITE ^s``)
  val th = MP (SPEC s compileProofsTheory.least_not_in_thm) finite
  in th end) compset

val _ = computeLib.add_conv (``least_aux``,2,
let fun f tm = let
  val (_,[p,n]) = boolSyntax.strip_comb tm
  val pp = eval ``^p ^n``
  val th = SPECL [p,n] fsetTheory.least_aux_def
  val th = PURE_REWRITE_RULE [pp,COND_CLAUSES] th
  in if rhs(concl(pp)) = T then th else TRANS th (f(rhs(concl th))) end
in f end) compset

val _ = computeLib.add_conv (``num_set_foldl``,3,
  fn tm => let
  val (_,[f,a,s]) = boolSyntax.strip_comb tm
  val finite = EQT_ELIM (eval ``FINITE ^s``)
  val th = MP (SPEC s fsetTheory.num_set_foldl_def) finite
  val th = ISPECL [f,a] th
  val th2 = eval (rhs(concl th))
  in TRANS th th2 end) compset

val d = !Globals.emitMLDir
val _ = map (fn s => (use (d^s^"ML.sig"); use (d^s^"ML.sml")))
["combin","pair","num","option","list","set",
 "fmap","sum","fcp","string","bit","words","int",
 "rich_list","bytecode"]

open bytecodeML

fun bc_evaln 0 s = s
  | bc_evaln n s = let
    val SOME s = bc_eval1 s in
      bc_evaln (n-1) s
    end handle Bind => (print "Fail\n"; s)

fun bc_eval_limit l s = let
     val SOME s = bc_eval1 s
     val n = length (bc_state_stack s)
     val _ = print ((Int.toString n)^" ")
  in if n > l then NONE else bc_eval_limit l s
   end handle Bind => SOME s

fun term_to_num x = (numML.fromString (Parse.term_to_string x))
fun term_to_int x = (intML.fromString ((Parse.term_to_string x)^"i"))
fun term_to_stack_op tm = let
  val (f,x) = dest_comb tm
in(case fst (dest_const f) of
    "PushInt" => PushInt (term_to_int x)
  | "Load" => Load (term_to_num x)
  | "Store" => Store (term_to_num x)
  | "Pops" => Pops (term_to_num x)
  | "El" => El (term_to_num x)
  | "TagEquals" => TagEquals (term_to_num x)
  | s => raise Fail s
  )
handle HOL_ERR _ => let
  val (f,w) = dest_comb f
in case fst (dest_const f) of
    "Cons" => Cons (term_to_num w,term_to_num x)
  | s => raise Fail s
end end handle HOL_ERR _ =>
  case fst (dest_const tm) of
    "Equal" => Equal
  | "Pop" => Pop
  | "Add" => Add
  | "Sub" => Sub
  | "Mult" => Mult
  | "Less" => Less
  | "IsNum" => IsNum
  | s => raise Fail s
fun term_to_bc tm = let
  val (f,x) = dest_comb tm
in case fst (dest_const f) of
    "Jump" => Jump (term_to_num x)
  | "JumpNil" => JumpNil (term_to_num x)
  | "Stack" => Stack (term_to_stack_op x)
  | "Call" => Call (term_to_num x)
  | s => raise Fail s
end handle HOL_ERR _ =>
  case fst (dest_const tm) of
    "Return" => Return
  | "Ref" => Ref
  | "Update" => Update
  | "CallPtr" => CallPtr
  | "JumpPtr" => JumpPtr
  | "Exception" => Exception
  | s => raise Fail s
val term_to_bc_list = (map term_to_bc) o fst o listSyntax.dest_list

fun int_to_term i = intSyntax.term_of_int (Arbint.fromInt (valOf (intML.toInt i)))
fun num_to_term n = numSyntax.term_of_int (valOf (numML.toInt n))
fun bv_to_term (Number i) = ``Number ^(int_to_term i)``
  | bv_to_term (Block (n,vs)) = ``Block ^(num_to_term n) ^(listSyntax.mk_list(map bv_to_term vs,``:bc_value``))``
  | bv_to_term (CodePtr n) = ``CodePtr ^(num_to_term n)``
  | bv_to_term (RefPtr n) = ``RefPtr ^(num_to_term n)``

val s = ``init_repl_state``
fun f0 s e = ``repl_exp ^s ^e``
fun f1 s e = rhs(concl(eval ``
let rs = ^(f0 s e) in
  (REVERSE rs.cs.code, rs.cpam)``))
fun f2 s e = fst(pairSyntax.dest_pair(f1 s e))
fun f e = term_to_bc_list (f2 s e)
fun fd0 f e = let
  fun q s [] = f s e
    | q s (d::ds) = let
      val th = eval ``repl_dec ^s ^d``
      val s = rhs(concl(th))
      in q s ds end
in q s end
val fd = fd0 (fn s => fn e => term_to_bc_list (f2 s e))
fun g1 c = bc_eval (init_state c)
fun g c = bc_state_stack (g1 c)
val pd0 = fd0 (fn s => fn e =>
  pairSyntax.dest_pair (f1 s e))
fun pd1 e ds = let
  val (c,m) = pd0 e ds
  val st = g (term_to_bc_list c)
  in (m,st) end
fun pv m bv ty = rhs(concl(eval``bcv_to_v ^m (^ty,^(bv_to_term bv))``))
fun pd tys e ds =
  let val (m,st) = pd1 e ds
  in map2 (pv m) st tys end

val e1 = ``Val (Lit (IntLit 42))``
val c1 = f e1
val [Number i] = g c1
val SOME 42 = intML.toInt i;
val true = [``Lit (IntLit 42)``] = (pd [``NTnum``] e1 [])
val e2 = ``If (Val (Lit (Bool T))) (Val (Lit (IntLit 1))) (Val (Lit (IntLit 2)))``
val c2 = f e2
val [Number i] = g c2
val SOME 1 = intML.toInt i;
val e3 = ``If (Val (Lit (Bool F))) (Val (Lit (IntLit 1))) (Val (Lit (IntLit 2)))``
val c3 = f e3
val [Number i] = g c3
val SOME 2 = intML.toInt i;
val e4 = ``App Equality (Val (Lit (IntLit 1))) (Val (Lit (IntLit 2)))``
val c4 = f e4
val [Number i] = g c4
val SOME 0 = intML.toInt i;
val e5 = ``Fun "x" (Var "x")``
val c5 = f e5
val st = g c5
val true = [``Closure [] "" (Var "")``] = pd [``NTfn``] e5 []
val e6 = ``Let "x" (Val (Lit (IntLit 1))) (App (Opn Plus) (Var "x") (Var "x"))``
val c6 = f e6
val [Number i] = g c6
val SOME 2 = intML.toInt i;
val e7 = ``Let "x" (Val (Lit (IntLit 1)))
             (Let "y" (Val (Lit (IntLit 2)))
                (Let "x" (Val (Lit (IntLit 3)))
                   (App (Opn Plus) (Var "x") (Var "y"))))``
val c7 = f e7
val [Number i] = g c7
val SOME 5 = intML.toInt i;
val e8 = ``
Let "0?" (Fun "x" (App Equality (Var "x") (Val (Lit (IntLit 0)))))
  (Let "x" (Val (Lit (IntLit 1)))
    (Let "x" (App (Opn Minus) (Var "x") (Var "x"))
      (App Opapp (Var "0?") (Var "x"))))``
val c8 = f e8
val [Number i] = g c8
val SOME 1 = intML.toInt i;
val e9 = ``
Let "1?" (Fun "x" (App Equality (Var "x") (Val (Lit (IntLit 1)))))
  (Let "x" (Val (Lit (IntLit 1)))
    (Let "x" (App (Opn Minus) (Var "x") (Var "x"))
      (App Opapp (Var "1?") (Var "x"))))``
val c9 = f e9
val [Number i] = g c9
val SOME 0 = intML.toInt i;
val e10 = ``
Let "x" (Val (Lit (IntLit 3)))
(If (App (Opb Gt) (Var "x") (App (Opn Plus) (Var "x") (Var "x")))
  (Var "x") (Val (Lit (IntLit 4))))``
val c10 = f e10
val [Number i] = g c10
val SOME 4 = intML.toInt i;
val e11 = ``
Let "x" (Val (Lit (IntLit 3)))
(If (App (Opb Geq) (Var "x") (Var "x"))
  (Var "x") (Val (Lit (IntLit 4))))``
val c11 = f e11
val [Number i] = g c11
val SOME 3 = intML.toInt i;
val e12 = ``
Let "lt2" (Fun "x" (App (Opb Lt) (Var "x") (Val (Lit (IntLit 2)))))
  (App Opapp (Var "lt2") (Val (Lit (IntLit 3))))``
val c12 = f e12
val [Number i] = g c12
val SOME 0 = intML.toInt i;
val e13 = ``
Let "lq2" (Fun "x" (App (Opb Leq) (Var "x") (Val (Lit (IntLit 2)))))
  (App Opapp (Var "lq2") (Val (Lit (IntLit 0))))``
val c13 = f e13
val [Number i] = g c13
val SOME 1 = intML.toInt i;
val e14 = ``
Let "x" (Val (Lit (IntLit 0)))
  (Let "y" (App (Opn Plus) (Var "x") (Val (Lit (IntLit 2))))
    (If (App (Opb Geq) (Var "y") (Var "x"))
      (Var "x") (Val (Lit (IntLit 4)))))``
val c14 = f e14
val [Number i] = g c14
val SOME 0 = intML.toInt i;
val e15 = ``
Let "x" (Val (Lit (Bool T)))
(App Equality
  (Mat (Var "x")
    [(Plit (Bool F), (Val (Lit (IntLit 1))));
     (Pvar "y", (Var "y"))])
  (Var "x"))``
val c15 = f e15
val [Number i] = g c15
val SOME 1 = intML.toInt i;
val e16 = ``App Equality (Let "x" (Val (Lit (Bool T))) (Var "x")) (Val (Lit (Bool F)))``
val c16 = f e16
val [Number i] = g c16
val SOME 0 = intML.toInt i;
val e17 = ``App Equality
  (Let "f" (Fun "_" (Val (Lit (Bool T)))) (App Opapp (Var "f") (Val (Lit (Bool T)))))
  (Val (Lit (Bool F)))``
val c17 = f e17
val [Number i] = g c17
val SOME 0 = intML.toInt i;
val e18 = ``
Let "x" (Val (Lit (Bool T)))
  (App Equality
    (Let "f" (Fun "_" (Var "x")) (App Opapp (Var "f") (Var "x")))
    (Var "x"))``
val c18 = f e18
val [Number i] = g c18
val SOME 1 = intML.toInt i;
val e19 = ``
Let "x" (Val (Lit (Bool T)))
  (App Opapp (Fun "_" (Var "x")) (Val (Lit (Bool F))))``
val c19 = f e19
val [Number i] = g c19
val SOME 1 = intML.toInt i;
val e20 = ``
Let "f" (Fun "_" (Val (Lit (Bool T))))
(App Equality
  (App Opapp (Var "f") (Val (Lit (Bool T))))
  (Val (Lit (Bool F))))``
val c20 = f e20
val [Number i] = g c20
val SOME 0 = intML.toInt i;
val e21 = ``Let "x" (Val (Lit (Bool T)))
(App Equality
  (Let "f" (Fun "_" (Var "x"))
    (App Opapp (Var "f") (Var "x")))
  (Var "x"))``
val c21 = f e21
val [Number i] = g c21
val SOME 1 = intML.toInt i;
val listd = ``
Dtype
  [(["'a"],"list",
    [("Cons",[Tvar "'a"; Tapp [Tvar "'a"] "list"]); ("Nil",[])])]
``
val e22 = ``Con "Cons" [Val (Lit (Bool T)); Con "Nil" []]``
val c22 = fd e22 [listd]
val [Block (t1,[Number i,Number t2])] = g c22
val SOME 0 = numML.toInt t1
val SOME 1 = intML.toInt i
val SOME 1 = intML.toInt t2;
val e23 = ``Mat (Con "Cons" [Val (Lit (IntLit 2));
                 Con "Cons" [Val (Lit (IntLit 3));
                 Con "Nil" []]])
            [(Pcon "Cons" [Pvar "x"; Pvar "xs"],
              Var "x");
             (Pcon "Nil" [],
              Val (Lit (IntLit 1)))]``
val c23 = fd e23 [listd]
val [Number i] = g c23
val SOME 2 = intML.toInt i;
val e24 = ``Mat (Con "Nil" [])
            [(Pcon "Nil" [], Val (Lit (Bool F)))]``
val c24 = fd e24 [listd]
val [Number i] = g c24
val SOME 0 = intML.toInt i;
val e25 = ``Mat (Con "Cons" [Val (Lit (IntLit 2));
                 Con "Nil" []])
            [(Pcon "Cons" [Pvar "x"; Pvar "xs"],
              Var "x")]``
val c25 = fd e25 [listd]
val [Number i] = g c25
val SOME 2 = intML.toInt i;
val e26 = ``Mat (Con "Cons" [Val (Lit (IntLit 2));
                 Con "Nil" []])
            [(Pcon "Cons" [Plit (IntLit 2);
              Pcon "Nil" []],
              Val (Lit (IntLit 5)))]``
val c26 = fd e26 [listd]
val [Number i] = g c26
val SOME 5 = intML.toInt i;
(*val e27 = ``
CLetfun F [1] [([],CRaise Bind_error)]
(CLprim CIf [CPrim2 CEq (CLit (IntLit 0)) (CLit (IntLit 0)); CLit (IntLit 1); CCall (CVar 1) []])``
val c27 = term_to_bc_list(rhs(concl(computeLib.CBV_CONV compset ``REVERSE (compile ^s ^e27).code``)))
val [Number i] = g c27
val SOME 1 = intML.toInt i;*)
val e28 = ``
Letrec [("fac",("n",
  If (App Equality (Var "n") (Val (Lit (IntLit 0))))
     (Val (Lit (IntLit 1)))
     (App (Opn Times)
       (Var "n")
       (App Opapp (Var "fac") (App (Opn Minus)
                                   (Var "n")
                                   (Val (Lit (IntLit 1))))))))]
  (App Opapp (Var "fac") (Val (Lit (IntLit 5))))``
val c28 = f e28
val [Number i] = g c28
val SOME 120 = intML.toInt i;
val d = ``Dlet (Pvar "Foo") (Val (Lit (IntLit 42)))``
val e41 = ``Var "Foo"``
val c41 = fd e41 [d]
val [Number i,Number j] = g c41
val SOME 42 = intML.toInt i;
val true = i = j;
val d = ``Dletrec [("I","x",(Var "x"))]``
val e42 = ``App Opapp (Var "I") (Val (Lit (IntLit 42)))``
val c42 = fd e42 [d]
val [Number i,cl] = g c42
val SOME 42 = intML.toInt i;
val d0 = ``
Dletrec
  [("N","v1",
    If (App (Opb Gt) (Var "v1") (Val (Lit (IntLit 100))))
      (App (Opn Minus) (Var "v1") (Val (Lit (IntLit 10))))
      (App Opapp (Var "N")
         (App Opapp (Var "N")
            (App (Opn Plus) (Var "v1") (Val (Lit (IntLit 11)))))))]
``
val e29 = ``App Opapp (Var "N") (Val (Lit (IntLit 42)))``
val c29 = fd e29 [d0]
val [Number i,cl] = g c29
val SOME 91 = intML.toInt i;
val e35 = ``Let "f" (Fun "x" (Fun "y" (App (Opn Plus) (Var "x") (Var "y")))) (App Opapp (App Opapp (Var "f") (Val (Lit (IntLit 2)))) (Val (Lit (IntLit 3))))``
val c35 = f e35
val [Number i] = g c35
val SOME 5 = intML.toInt i;
val e36 = ``Letrec [("f", ("x", (Fun "y" (App (Opn Plus) (Var "x") (Var "y")))))] (App Opapp (App Opapp (Var "f") (Val (Lit (IntLit 2)))) (Val (Lit (IntLit 3))))``
val c36 = f e36
val [Number i] = g c36
val SOME 5 = intML.toInt i;
val e37 = ``Letrec [("z", ("x", (Mat (Var "x") [(Plit (IntLit 0), (Var "x"));(Pvar "y", App Opapp (Var "z") (App (Opn Minus) (Var "x") (Var "y")))])))] (App Opapp (Var "z") (Val (Lit (IntLit 5))))``
val c37 = f e37
val [Number i] = g c37
val SOME 0 = intML.toInt i;
val e38 = ``Let "z" (Fun "x" (Mat (Var "x") [(Plit (IntLit 0), (Var "x"));(Pvar "y", (App (Opn Minus) (Var "x") (Var "y")))])) (App Opapp (Var "z") (Val (Lit (IntLit 5))))``
val c38 = f e38
val [Number i] = g c38
val SOME 0 = intML.toInt i;
val e39 = ``Letrec [("z", ("x", (Mat (Var "x") [(Plit (IntLit 0), (Var "x"));(Pvar "y", (App (Opn Minus) (Var "x") (Var "y")))])))] (App Opapp (Var "z") (Val (Lit (IntLit 5))))``
val c39 = f e39
val [Number i] = g c39
val SOME 0 = intML.toInt i;
val _ = ml_translatorLib.translate listTheory.APPEND
val d0 = listd
val append_defs = ``
  [("APPEND","v3",
    Fun "v4"
      (Mat (Var "v3")
         [(Pcon "Nil" [],Var "v4");
          (Pcon "Cons" [Pvar "v2"; Pvar "v1"],
           Con "Cons"
             [Var "v2";
              App Opapp (App Opapp (Var "APPEND") (Var "v1"))
                (Var "v4")])]))] ``
val d1 = ``Dletrec ^append_defs``
val e33 = ``App Opapp (Var "APPEND") (Con "Nil" [])``
val (m,st) = pd1 e33 [d0,d1]
val tm = pv m (hd st) ``NTfn``
val true = tm = ``Closure [] "" (Var "")``;
val e34 = ``App Opapp (App Opapp (Var "APPEND") (Con "Nil" []))
                      (Con "Nil" [])``
val (m,st) = pd1 e34 [d0,d1]
val [r,cl] = st
val tm = pv m r ``NTapp [NTnum] "list"``
val true = tm = ``Conv "Nil" []``
val tm = pv m cl ``NTfn``
val true = tm = ``Closure [] "" (Var "")``;
fun h t = hd(tl(snd(strip_comb(concl t))))
val t = ml_translatorLib.hol2deep ``[1;2;3]++[4;5;6:num]``
val e30 = h t
val (m,st) = pd1 e30 [d0,d1]
val [res,cl] = st
val tm = pv m res ``NTapp [NTnum] "list"``
val true = tm = ml_translatorLib.hol2val ``[1;2;3;4;5;6:num]``;
val t = ml_translatorLib.hol2deep ``[]++[4:num]``
val e32 = h t
val (m,st) = pd1 e32 [d0,d1]
val [res,cl] = st
val tm = pv m res ``NTapp [NTnum] "list"``
val true = tm = ``Conv "Cons" [Lit (IntLit 4); Conv "Nil" []]``;
val d2 = ``
Dtype [(["'a"; "'b"],"prod",[("Pair_type",[Tvar "'a"; Tvar "'b"])])]
`` val d3 = ``
Dletrec
  [("PART","v3",
    Fun "v4"
      (Fun "v5"
         (Fun "v6"
            (Mat (Var "v4")
               [(Pcon "Nil" [],Con "Pair_type" [Var "v5"; Var "v6"]);
                (Pcon "Cons" [Pvar "v2"; Pvar "v1"],
                 If (App Opapp (Var "v3") (Var "v2"))
                   (App Opapp
                      (App Opapp
                         (App Opapp (App Opapp (Var "PART") (Var "v3"))
                            (Var "v1"))
                         (Con "Cons" [Var "v2"; Var "v5"])) (Var "v6"))
                   (App Opapp
                      (App Opapp
                         (App Opapp (App Opapp (Var "PART") (Var "v3"))
                            (Var "v1")) (Var "v5"))
                      (Con "Cons" [Var "v2"; Var "v6"])))]))))]
`` val d4 = ``
Dlet (Pvar "PARTITION")
  (Fun "v1"
     (Fun "v2"
        (App Opapp
           (App Opapp
              (App Opapp (App Opapp (Var "PART") (Var "v1")) (Var "v2"))
              (Con "Nil" [])) (Con "Nil" []))))
`` val d5 = ``
Dletrec
  [("QSORT","v7",
    Fun "v8"
      (Mat (Var "v8")
         [(Pcon "Nil" [],Con "Nil" []);
          (Pcon "Cons" [Pvar "v6"; Pvar "v5"],
           Let "v3"
             (App Opapp
                (App Opapp (Var "PARTITION")
                   (Fun "v4"
                      (App Opapp (App Opapp (Var "v7") (Var "v4"))
                         (Var "v6")))) (Var "v5"))
             (Mat (Var "v3")
                [(Pcon "Pair_type" [Pvar "v2"; Pvar "v1"],
                  App Opapp
                    (App Opapp (Var "APPEND")
                       (App Opapp
                          (App Opapp (Var "APPEND")
                             (App Opapp
                                (App Opapp (Var "QSORT") (Var "v7"))
                                (Var "v2")))
                          (Con "Cons" [Var "v6"; Con "Nil" []])))
                    (App Opapp (App Opapp (Var "QSORT") (Var "v7"))
                       (Var "v1")))]))]))]
``
val _ = ml_translatorLib.translate sortingTheory.PART_DEF
val _ = ml_translatorLib.translate sortingTheory.PARTITION_DEF
val _ = ml_translatorLib.translate sortingTheory.QSORT_DEF
val t = ml_translatorLib.hol2deep ``QSORT (λx y. x ≤ y) [9;8;7;6;2;3;4;5:num]``
val e31 = h t;
(*
val rs0 = s
val rs1 = rhs(concl(eval``repl_dec ^rs0 ^d0``))
val rs2 = rhs(concl(eval``repl_dec ^rs1 ^d1``))
val rs3 = rhs(concl(eval``repl_dec ^rs2 ^d2``))
val rs4 = rhs(concl(eval``repl_dec ^rs3 ^d3``))
val rs5 = rhs(concl(eval``repl_dec ^rs4 ^d4``))
val rs6 = rhs(concl(eval``repl_dec ^rs5 ^d5``))
val res = rhs(concl(eval``repl_exp ^rs6 ^e31``))
val (c,m) = pairSyntax.dest_pair(rhs(concl(eval``REVERSE (^res).cs.code, (^res).cpam``)))
val st = g (term_to_bc_list c)
*)
val (m,st) = pd1 e31 [d0,d1,d2,d3,d4,d5]
val [res,clQSORT,clPARTITION,clPART,clAPPEND] = st
val tm = pv m res ``NTapp [NTnum] "list"``
val true = tm = ml_translatorLib.hol2val ``[2;3;4;5;6;7;8;9:num]``;
val d = ``
Dlet (Pvar "add1")
  (Fun "x" (App (Opn Plus) (Var "x") (Val (Lit (IntLit 1)))))``
val e40 = ``App Opapp (Var "add1") (Val (Lit (IntLit 1)))``
val (m,st) = pd1 e40 [d]
val [res,add1] = st
val true = pv m res ``NTnum`` = ml_translatorLib.hol2val ``2:int``;
val e43 = ``Letrec [("o","n",
  If (App Equality (Var "n") (Val (Lit (IntLit 0))))
     (Var "n")
     (App Opapp
       (Var "o")
       (App (Opn Minus) (Var "n") (Val (Lit (IntLit 1))))))]
  (App Opapp (Var "o") (Val (Lit (IntLit 1000))))``
val c43 = f e43
val SOME s43 = bc_eval_limit 12 (init_state c43)
val [Number i] = bc_state_stack s43
val SOME 0 = intML.toInt i;
val d = ``Dletrec
[("o","n",
  If (App Equality (Var "n") (Val (Lit (IntLit 0))))
     (Var "n")
     (App Opapp
       (Var "o")
       (App (Opn Minus) (Var "n") (Val (Lit (IntLit 1))))))]``
val e44 = ``App Opapp (Var "o") (Val (Lit (IntLit 1000)))``
val (m,st) = pd1 e44 [d]
val [Number i, cl] = st
val SOME 0 = intML.toInt i;
