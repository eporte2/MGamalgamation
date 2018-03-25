

##################
##  Operations  ##
##################

## Removes M feature when raising or lowering is applied to a node
function remove_M_feat(Node)
    index = is_head(Node.data.features)
    deleteat!(Node.data.features, index)
end

## Returns closest lower head to lower to
## Recursive function
function find_lower_head(current_node, move_node, found_head)
    head = is_head(move_node.data.features)
    if head != -1
        found_head = true
    end
    lower_head = move_node
    if (found_head == false && !isterminal(lower_head))
        for child in move_node.children
            if child != current_node
                lower_head, found_head = find_lower_head(current_node, child, found_head)
            end
            if found_head
                break
            end
        end
    end
    return (lower_head, found_head)
end

## Returns closest higher head to raise to
## Recursive function
function find_higher_head(current_node, move_node, found_head)
    head = is_head(move_node.data.features)
    if head != -1
        found_head = true
    end
    higher_head = move_node
    if (found_head == false && typeof(higher_head.parent.data.category) != "root")
        for child in higher_head.parent
            if child != current_node
                head = is_head(child.data.features)
                if head != -1
                    found_head = true
                end
                if found_head
                    higher_head = child
                    break
                end
            end
        end
        if !found_head
            higher_head, found_head = find_higher_head(move_node, move_node.parent, found_head)
        end
    end
    return (higher_head, found_head)
end



#Lowering
function apply_lowering(current_node)
    #set node as explored
    current_node.data.explored = true
    #remember current nodes parent to return to in amalgamation bottom-up sweep
    move_node = current_node.parent
    #find closest lower head in hierarchical structure to amalgamate to.
    lower_head, found_head = find_lower_head(current_node, move_node, false)
    if found_head
        parent = lower_head.parent
        #create new intermediate node which will now carry head feature (branching head)
        label =Label(lower_head.data.category,copy(lower_head.data.features),lower_head.data.explored)
        new_lower_head = TreeNode(label, parent)
        #remove head feature from internal copy of head and add to children of intermediate head
        remove_M_feat(lower_head)
        insert_child!(new_lower_head, lower_head)
        #remove head feature from raising head and add to children of intermediate head
        remove_M_feat(current_node)
        insert_child!(new_lower_head, current_node)
        #insert new intermediate head into structure in place of head which was lowered to.
        replace_child!(parent, lower_head, new_lower_head)
        #erase lowering head from original merge position
        remove_child!(move_node, current_node)
    else
        print("Could not find lower head to amalgamate with for node $(current_node.data)")
    end
    return move_node
end



#Raising
function apply_raising(current_node)
    #set node as explored
    current_node.data.explored = true
    #remember current nodes parent to return to in amalgamation bottom-up sweep
    move_node = current_node.parent
    #find closest higher head in hierarchical structure to amalgamate to.
    higher_head, found_head = find_higher_head(current_node, move_node, false)
    if found_head
        parent = higher_head.parent
        #create new intermediate node which will now carry head feature (branching head)
        label =Label(higher_head.data.category,copy(higher_head.data.features),higher_head.data.explored)
        new_higher_head = TreeNode(label, parent)
        #remove head feature from internal copy of head and add to children of intermediate head
        remove_M_feat(higher_head)
        insert_child!(new_higher_head, higher_head)
        #remove head feature from raising head and add to children of intermediate head
        remove_M_feat(current_node)
        insert_child!(new_higher_head, current_node)
        #insert new intermediate head into structure in place of head which was raised to.
        replace_child!(parent, higher_head, new_higher_head)
        #erase raising head from original merge position
        remove_child!(move_node, current_node)
    else
        print("Could not find higher head to amalgamate with for node $(current_node.data)")
    end
    return move_node
end


#########################
## Apply Amalgamation  ##
#########################

# check if node has unexplored children ie: check for heads and spec of phrasal projections along spine
function has_unexploredchildren(tree)
    unexplored = false
    for child in tree.children
        if child.data.explored == false
            unexplored = true
            break
        end
    end
    return unexplored
end


function apply_amalgamation(tree :: MGTree)
    #Find bottom of tree: move down tree spine via right child until we reach a terminal TreeNode
    current_node = tree.d
    while !isterminal(current_node)
        next_node = current_node.children[end]
        current_node = next_node
    end
    #While not at root look for heads to apply Amalgamation
    while current_node.data.category != "root"
        #check if node has unexplored children and explore
        if has_unexploredchildren(current_node)
            #print(string("1: ", current_node.data, " / "))
            for i in 1:length(current_node.children)
                index = (length(current_node.children)+1 -i)
                if current_node.children[index].data.explored == false
                    next_node = current_node.children[index]
                    current_node = next_node
                end
            end
        #elseif node is a head, check for lowering or raisng feature
        elseif is_head(current_node.data.features) != -1
            #print(string("2: ", current_node.data, " / "))
            index = is_head(current_node.data.features)
            M = current_node.data.features[index]
            if is_loweringfeat(M)
                current_node = apply_lowering(current_node)
            elseif is_raisingfeat(M)
                current_node = apply_raising(current_node)
            else
                current_node.data.explored = true
                next_node = current_node.parent
                current_node = next_node
            end
        #else move to parent
        else
            #print(string("3: ", current_node.data, " / "))
            current_node.data.explored = true
            next_node = current_node.parent
            current_node = next_node
        end
    end
    return MGTree(current_node.children[1])
end
