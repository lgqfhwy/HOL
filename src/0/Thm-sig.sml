(* ===================================================================== *)
(* FILE          : Thm.sig                                               *)
(* DESCRIPTION   : Signature for the abstract data type of theorems.     *)
(*                                                                       *)
(* AUTHORS       : (c) Mike Gordon, University of Cambridge              *)
(*                     Konrad Slind, University of Calgary               *)
(* DATE          : September 10, 1991                                    *)
(* Modified      : September 23, 1997, Ken Larsen                        *)
(*               : June 16, 1998, Konrad Slind                           *)
(*               : 1999, Bruno Barras, University of Cambridge and INRIA *)
(*               : July 2000, Konrad Slind, University of Cambridge      *)
(* ===================================================================== *)


signature Thm =
sig

  type thm
  type tag      = Tag.tag
  type term     = Term.term
  type hol_type = Type.hol_type
  type 'a set   = 'a HOLset.set



  (* Simple operations on the type of theorems *)

  val tag           : thm -> tag
  val hyp           : thm -> term list
  val hypset        : thm -> term set
  val concl         : thm -> term
  val dest_thm      : thm -> term list * term
  val thm_frees     : thm -> term list
  val thm_hypfrees  : thm -> term set
  val thm_hypfreetys: thm -> hol_type set


  (* The primitive rules of inference *)

  val ASSUME        : term -> thm
  val REFL          : term -> thm
  val BETA_CONV     : term -> thm
  val ABS           : term -> thm -> thm
  val DISCH         : term -> thm -> thm
  val MP            : thm -> thm -> thm
  val SUBST         : (term,thm)Lib.subst -> term -> thm -> thm
  val INST_TYPE     : (hol_type,hol_type)Lib.subst -> thm -> thm


  (* Now some derivable-but-primitive rules of inference *)


  (* Lambda calculus rules *)

  val ALPHA         : term -> term -> thm
  val MK_COMB       : thm * thm -> thm
  val AP_TERM       : term -> thm -> thm
  val AP_THM        : thm -> term -> thm
  val ETA_CONV      : term -> thm


  (* Equality *)

  val SYM           : thm -> thm
  val TRANS         : thm -> thm -> thm
  val EQ_MP         : thm -> thm -> thm
  val EQ_IMP_RULE   : thm -> thm * thm


  (* Free variable instantiation *)

  val INST          : (term,term)Lib.subst -> thm -> thm


  (* Universal quantification *)

  val SPEC          : term -> thm -> thm
  val GEN           : term -> thm -> thm


  (* Existential quantification *)

  val EXISTS        : term * term -> thm -> thm
  val CHOOSE        : term * thm -> thm -> thm


  (* Conjunction *)

  val CONJ          : thm -> thm -> thm
  val CONJUNCT1     : thm -> thm
  val CONJUNCT2     : thm -> thm


  (* Disjunction *)

  val DISJ1         : thm -> term -> thm
  val DISJ2         : term -> thm -> thm
  val DISJ_CASES    : thm -> thm -> thm -> thm


  (* Negation *)

  val NOT_INTRO     : thm -> thm
  val NOT_ELIM      : thm -> thm
  val CCONTR        : term -> thm -> thm


  (* Computing with explicit substitutions *)

  val Beta          : thm -> thm
  val Eta           : thm -> thm
  val Mk_comb       : thm -> thm * thm * (thm -> thm -> thm)
  val Mk_abs        : thm -> term * thm * (thm -> thm)
  val Spec          : term -> thm -> thm


  (* Oracle invocation *)

  val mk_thm        : term list * term -> thm
  val mk_oracle_thm : tag -> term list * term -> thm

  (* Fetching theorems from disk *)

  val disk_thm      : term vector
                       -> string * 'a frag list list * 'a frag list -> thm
end;
