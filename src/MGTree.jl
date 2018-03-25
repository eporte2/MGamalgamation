#import Base.==
#include("Trees.jl")
#using Trees

#############
## Feature ##
#############

# features are strings of the following forms: "R=f", "L=f", "f"
# where f is any string of lowercase or capital letters of the standard alphabet
Feature = String
is_feature(s :: String) = match(r"(R=|L=|\+|-)?[a-zA-Z]+", s).offset == 1
is_raisingfeat(f :: Feature) = f == "+M"
is_loweringfeat(f :: Feature) = f == "-M"


function is_head(features :: Vector{Feature})
    index = -1
    for i in 1:length(features)
        if contains(features[i], "M")
            index = i
            break
        end
    end
    return index
end





#############
##  Label  ##
#############

type Label
    category :: String
    features :: Vector{Feature}
    explored :: Bool
end

function Label()
    Label("root", [], false)
end

function Label(s :: AbstractString)
    splititem = map(String, split(s, ';'))
    category = strip(splititem[1])
    features = map(Feature, split(splititem[2]))
    if !all(map(is_feature, features))
        error(s, "contains a non feature. Check formatting.")
    end
    Label(category, features, false)
end

function show(io :: IO, label :: Label)
    print(io, "{$(label.category) ;")
    map(x -> print(io, " $x"), label.features)
    print(io, "}")
end
show(lex :: Label) = show(STDOUT, lex)

##############
##  MGTree  ##
##############

type MGTree
    d :: Tree{Label}
end

##################
##  Make a tree ##
##################

"This function takes as input a string representation of a derivation tree and creates a MGTree object. The format required for the input string is as follows:

[.{Phrase Label} [{<Head Label>}] [<Complement>...]]

Labels are of the format:
<category> ; <space separated list of features>
eg:  v ; +M

"
function get_label(str :: AbstractString, index :: Int)
    label_s = ""
    while str[index] != '}'
        label_s = string(label_s, str[index])
        index += 1
    end
    #print(label_s)
    label = Label(label_s)
    return (label, index)
end

function MGTree(str :: AbstractString)
    root = Label()
    node = TreeNode(root)
    index = 1
    #str = replace(str, " ", "")[2:end-1]
    while index != length(str)
        #print(str[index])
        if str[index] == '['
            index+=1
            if str[index] == '{'
                index+=1
                label, index = get_label(str, index)
            else
                print("Tree not properly formatted. See comment about format.")
                break
            end
            insert_child!(node, label)
            node = node.children[end]
        elseif str[index] == ']'
            index+=1
            node = node.parent
        else
            index+=1
        end
    end
    MGTree(node)
end
