(* ===================================================================== *)
(* FILE          : boolSyntax.sml                                        *)
(* DESCRIPTION   : Derived HOL syntax operations. Mostly translated from *)
(*                 the hol88 source.                                     *)
(*                                                                       *)
(* AUTHORS       : (c) Mike Gordon, University of Cambridge              *)
(*                     Konrad Slind, University of Calgary               *)
(* Modified      : September 1997, Ken Larsen (functor removal)          *)
(* Modified      : July 2000, Konrad Slind                               *)
(* ===================================================================== *)

structure boolSyntax :> boolSyntax =
struct

open Feedback Lib HolKernel boolTheory;

val ERR = mk_HOL_ERR "boolSyntax";

infixr 3 -->;
infix 5 |->;


(*---------------------------------------------------------------------------
       Basic constants
 ---------------------------------------------------------------------------*)

val equality    = prim_mk_const {Name="=",         Thy="min"};
val implication = prim_mk_const {Name="==>",       Thy="min"};
val select      = prim_mk_const {Name="@",         Thy="min"};
val T           = prim_mk_const {Name="T",         Thy="bool"};
val F           = prim_mk_const {Name="F",         Thy="bool"};
val universal   = prim_mk_const {Name="!",         Thy="bool"};
val existential = prim_mk_const {Name="?",         Thy="bool"};
val exists1     = prim_mk_const {Name="?!",        Thy="bool"};
val conjunction = prim_mk_const {Name="/\\",       Thy="bool"};
val disjunction = prim_mk_const {Name="\\/",       Thy="bool"};
val negation    = prim_mk_const {Name="~",         Thy="bool"};
val conditional = prim_mk_const {Name="COND",      Thy="bool"};
val let_tm      = prim_mk_const {Name="LET",       Thy="bool"};
val arb         = prim_mk_const {Name="ARB",       Thy="bool"};
val bool_case   = prim_mk_const {Name="bool_case", Thy="bool"};


(*---------------------------------------------------------------------------
          Derived syntax operations
 ---------------------------------------------------------------------------*)

fun mk_eq (lhs,rhs) = 
 list_mk_comb(inst[alpha |-> type_of lhs] equality, [lhs,rhs])
 handle HOL_ERR _ => raise ERR "mk_eq" "lhs and rhs have different types";

fun mk_imp(ant,conseq) =
 list_mk_comb(implication,[ant,conseq])
 handle HOL_ERR _ => raise ERR "mk_imp" "Non-boolean argument"

val mk_select  = mk_binder select       "mk_select"
val mk_forall  = mk_binder universal    "mk_forall"
val mk_exists  = mk_binder existential  "mk_exists"
val mk_exists1 = mk_binder exists1      "mk_exists1"

fun mk_conj(conj1,conj2) =
 list_mk_comb(conjunction,[conj1,conj2])
 handle HOL_ERR _ => raise ERR "mk_conj" "Non-boolean argument"

fun mk_disj(disj1,disj2) =
 list_mk_comb(disjunction,[disj1,disj2])
 handle HOL_ERR _ => raise ERR "mk_disj" "Non-boolean argument"

fun mk_neg M = 
  with_exn mk_comb(negation, M) (ERR "mk_neg" "Non-boolean argument");

fun mk_cond (cond,larm,rarm) =
 list_mk_comb(inst[alpha |-> type_of larm] conditional,[cond,larm,rarm])
 handle HOL_ERR _ => raise ERR "mk_cond" ""

fun mk_let (func,arg) =
 let val (dom,rng) = dom_rng (type_of func)
 in list_mk_comb(inst[alpha |-> dom, beta |-> rng] let_tm, [func,arg])
 end handle HOL_ERR _ => raise ERR "mk_let" "";

fun mk_bool_case(a0,a1,b) =
 list_mk_comb(inst[alpha |-> type_of a0] bool_case, [a0,a1,b])
 handle HOL_ERR _ => raise ERR "mk_bool_case" "";

fun mk_arb ty = inst [alpha |-> ty] arb;


(*--------------------------------------------------------------------------*
 *     Destructors                                                          *
 *--------------------------------------------------------------------------*)

local val dest_eq_ty_err = ERR "dest_eq(_ty)"   "not an \"=\""
      val lhs_err        = ERR "lhs"            "not an \"=\""
      val rhs_err        = ERR "rhs"            "not an \"=\""
      val dest_imp_err   = ERR "dest_imp"       "not an \"==>\""
      val dest_cond_err  = ERR "dest_cond"      "not a conditional"
      val bool_case_err  = ERR "dest_bool_case" "not a \"bool_case\""
in
val dest_eq = dest_binop ("=","min")      dest_eq_ty_err

fun dest_eq_ty M = let val (l,r) = dest_eq M in (l, r, type_of l) end

fun lhs M = fst(dest_eq M) handle HOL_ERR _ => raise lhs_err

fun rhs M = snd(dest_eq M) handle HOL_ERR _ => raise rhs_err

val dest_neg = dest_monop ("~","bool") (ERR"dest_neg" "not a negation");

val dest_imp_only = dest_binop ("==>", "min")   dest_imp_err;

fun dest_imp M = 
  dest_imp_only M handle HOL_ERR _ => (dest_neg M, F) 
                  handle HOL_ERR _ => raise dest_imp_err

val dest_select  = dest_binder("@", "min")  (ERR"dest_select"  "not a \"@\"")
val dest_forall  = dest_binder("!", "bool") (ERR"dest_forall"  "not a \"!\"")
val dest_exists  = dest_binder("?", "bool") (ERR"dest_exists"  "not a \"?\"")
val dest_exists1 = dest_binder("?!","bool") (ERR"dest_exists1" "not a \"?!\"")
val dest_conj   = dest_binop("/\\","bool") (ERR"dest_conj"    "not a \"/\\\"")
val dest_disj   = dest_binop("\\/","bool") (ERR"dest_disj"    "not a \"\\/\"")
val dest_let    = dest_binop("LET","bool") (ERR"dest_let"    "not a let term")

fun dest_cond M =
 let val (Rator,t2) = with_exn dest_comb M dest_cond_err
     val (b,t1) = dest_binop ("COND","bool") dest_cond_err Rator
 in (b, t1, t2)
 end 

fun dest_bool_case M =
 let val (Rator,b) = with_exn dest_comb M bool_case_err
     val (a0,a1) = dest_binop ("bool_case","bool") bool_case_err Rator
 in (a0, a1, b)
 end 

fun dest_arb M = 
  case dest_thy_const M 
   of {Name="ARB", Thy="bool", Ty} => Ty
    | otherwise => raise ERR "dest_arb" "";
end;

(*---------------------------------------------------------------------------
             Selectors
 ---------------------------------------------------------------------------*)

val is_eq        = can dest_eq
val is_imp       = can dest_imp
val is_imp_only  = can dest_imp_only
val is_select    = can dest_select
val is_forall    = can dest_forall
val is_exists    = can dest_exists
val is_exists1   = can dest_exists1
val is_conj      = can dest_conj
val is_disj      = can dest_disj
val is_neg       = can dest_neg
val is_cond      = can dest_cond
val is_let       = can dest_let
val is_bool_case = can dest_bool_case
val is_arb       = can dest_arb;


(*---------------------------------------------------------------------------*
 * Construction and destruction functions that deal with SML lists           *
 *---------------------------------------------------------------------------*)

val list_mk_comb = HolKernel.list_mk_comb
val list_mk_abs  = HolKernel.list_mk_abs

val list_mk_forall = list_mk_binder 
 (fn abs => mk_comb(inst[alpha |-> fst(dom_rng(type_of abs))]universal,abs))

val list_mk_exists = list_mk_binder
 (fn abs => mk_comb(inst[alpha |-> fst(dom_rng(type_of abs))]existential,abs))

val list_mk_conj     = list_mk_rbinop (curry mk_conj)
val list_mk_disj     = list_mk_rbinop (curry mk_disj)
fun list_mk_imp(A,c) = itlist(curry mk_imp) A c;


val strip_comb   = HolKernel.strip_comb
val strip_abs    = HolKernel.strip_abs
val strip_forall = strip_binder (total dest_forall)
val strip_exists = strip_binder (total dest_exists)
val strip_conj   = strip_binop  (total dest_conj)
val strip_disj   = strip_binop  (total dest_disj)

val strip_imp =
  let val desti = total dest_imp
      fun strip A M =
        case desti M
         of NONE => (List.rev A, M)
          | SOME(ant,conseq) => strip (ant::A) conseq
  in strip []
  end;

val strip_imp_only =
  let val desti = total dest_imp_only
      fun strip A M =
        case desti M
         of NONE => (List.rev A, M)
          | SOME(ant,conseq) => strip (ant::A) conseq
  in strip []
  end;

val strip_neg =
 let val destn = total dest_neg
     fun strip A M = 
       case destn M
        of NONE => (M,A)
         | SOME N => strip (A+1) N
 in strip 0
 end;

fun gen_all tm = list_mk_forall (free_vars tm, tm);


(*---------------------------------------------------------------------------*
 * Construction and destruction of function types from/to lists of types     *
 * Michael Norrish - December 1999                                           *
 *---------------------------------------------------------------------------*)

val list_mk_fun = HolKernel.list_mk_fun;
val strip_fun   = HolKernel.strip_fun



(*---------------------------------------------------------------------------
     Linking definitional principles and signature operations 
     with grammars.
 ---------------------------------------------------------------------------*)

fun dest t = 
  let val (lhs,rhs) = dest_eq (snd(strip_forall t))
      val (f,args) = strip_comb lhs
  in if all is_var args
     then (args, mk_eq(f, list_mk_abs(args,rhs)))
     else raise ERR "new_definition" "non-variable argument"
  end;

fun RIGHT_BETA th = TRANS th (BETA_CONV(rhs(concl th)));

fun post (V,th) =
  let fun add_var v th = RIGHT_BETA (AP_THM th v)
      val cname = fst(dest_const(lhs(concl th)))
  in Parse.add_const cname;
     itlist GEN V (rev_itlist add_var V th)
  end;
  
val _ = Definition.new_definition_hook := (dest, post)

fun defname t = 
  let val head = #1 (strip_comb (lhs (#2 (strip_forall t))))
  in fst (dest_var head handle HOL_ERR _ => dest_const head)
  end;
  
fun new_infixr_definition (s, t, p) = 
  Definition.new_definition(s, t)
    before 
  Parse.add_infix(defname t, p, Parse.RIGHT);

fun new_infixl_definition (s, t, p) = 
  Definition.new_definition(s, t)
    before
   Parse.add_infix(defname t, p, Parse.LEFT);

fun new_binder_definition (s, t) = 
  Definition.new_definition(s, t)
    before
  Parse.add_binder (defname t, Parse.std_binder_precedence);

fun new_type_definition (name, inhab_thm) = 
  Definition.new_type_definition (name,inhab_thm)
     before
  Parse.add_type name;

local fun foldfn ({const_name,fixity}, (ncs,cfs)) =
                    (const_name::ncs, (const_name, fixity) :: cfs)
in 
fun new_specification {name,sat_thm,consts} = 
 let val (newconsts, consts_with_fixities) = List.foldl foldfn ([],[]) consts
     val res = Definition.new_specification(name, List.rev newconsts, sat_thm)
     fun add_rule' r = 
          if #fixity r = Parse.Prefix then () else Parse.add_rule r
     fun modify_grammar (name, fixity) = let in 
           add_rule'(Parse.standard_spacing name fixity);
           Parse.add_const name 
         end
 in app modify_grammar consts_with_fixities;
    res
 end
end;

fun new_constant (p as (Name,_)) = 
  Theory.new_constant p
     before 
  Parse.add_const Name;

fun new_infix(Name, Ty, Prec) = 
  Theory.new_constant(Name, Ty)
     before
  (Parse.add_const Name; Parse.add_infix(Name, Prec, Parse.RIGHT)); 

fun new_binder (p as (Name,_)) = 
  Theory.new_constant p
     before
  (Parse.add_const Name; 
   Parse.add_binder (Name, Parse.std_binder_precedence)); 

fun new_type (p as (Name,_)) = 
  Theory.new_type p
     before 
  Parse.add_type Name;

fun new_infix_type (x as {Name,Arity,ParseName,Prec,Assoc}) = 
 let val _ = Arity = 2 orelse 
             raise ERR "new_infix_type" "Infix types must have arity 2"
 in
   Theory.new_type(Name,Arity)
      before
   Parse.add_infix_type
       {Name=Name, ParseName=ParseName, Prec=Prec, Assoc=Assoc}
 end

(*---------------------------------------------------------------------------
      Delete the named constant from the current theory, and from the
      current grammar.
 ---------------------------------------------------------------------------*)

fun delete_const s = 
   Theory.delete_const s
     before 
   Parse.hide s;

end
