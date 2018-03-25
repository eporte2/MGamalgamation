module MGamalgamation


#const LOGSPACE_THRESHOLD = 0.0001

importall Base
#using LogProbs


#Trees
export Tree, EmptyTree, TreeNode,
       isterminal, insert_child!, remove_child!, replace_child!,
       tree, lisp_tree_structure, parenthesis_to_brackets,
       start, next, done, eltype,
       leafs, leaf_data

#MGTree
export MGTree,
       get_label,
       Label,
       is_head,
       is_raisingfeat,
       is_loweringfeat

#grammar
export apply_amalgamation,
       has_unexploredchildren,
       apply_lowering,
       apply_raising,
       find_higher_head,
       find_lower_head,
       remove_M_feat

include("Trees.jl")
using MGamalgamation.Trees
include("MGTree.jl")
include("grammar.jl")

end
