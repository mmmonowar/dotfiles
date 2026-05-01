#!/bin/bash

# ==========================================
# 🚀  DOCUMENTS LOGIC
# ==========================================

function documents_menu() {
    local query=$1
    local dim="\033[2m"
    local reset="\033[0m"
    local docs_path="${REPO_PATH}/project-manager"
    
    if [[ ! -d "$docs_path" ]]; then
        echo -e "󰅙  Project Manager directory missing!"
        sleep 2
        main_menu
        return
    fi

    local list_items=""
    local idx=1
    while IFS= read -r file; do
        local rel_path="${file#$docs_path/}"
        local display_name=$(echo "$rel_path" | sed -E 's/\.md$//; s/[\/-]/ /g; s/\b(.)/\u\1/g')
        list_items+="$idx | 󰈙  $display_name | ${dim}Read $rel_path${reset} | $file
"
        ((idx++))
    done < <(find "$docs_path" -type f -name "*.md" | sort)

    local selection=$(echo -e "$list_items" | fzf 
        --ansi 
        --height 100% 
        --reverse 
        --border rounded 
        --prompt "󱓡  " 
        --query "$query" 
        --header "Select Document (Type index or name)" 
        --delimiter ' \| ' 
        --with-nth 1,2,3)

    if [[ -n "$selection" ]]; then
        local selected_file=$(echo "$selection" | cut -d '|' -f 4 | xargs)
        read_document "$selected_file"
        documents_menu
    else
        main_menu
    fi
}
