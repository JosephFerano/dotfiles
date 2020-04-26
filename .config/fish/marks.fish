if not set -q BMS_FILE
    set -gx BMS_FILE $HOME/.config/fish/bmarks
end
if not set -q BMS_OPENER
    set -gx BMS_OPENER xdg-open
end

if [ ! -e "$BMS_FILE" ]
    touch $BMS_FILE
end

set title_col (set_color cyan)
set text_col (set_color normal)
set error_col (set_color red)

function bookmark --description "Bookmark files and directories in fish"
    if [ (count $argv) -lt 1 ]; or [ "-h" = $argv[1] ]; or [ "-help" = $argv[1] ]; or [ "--help" = $argv[1] ]
        echo ''
        echo 'Create bookmarks to all your favorite files and directories. Data written to $HOME/.config/fish/bmarks'
        echo ''
        echo -n 'add <bookmark name> <dir|file name> - Adds the file/directory directory as "bookmark_name". '
        echo    'If no name is provided, the current working directory is used.'
        echo 'go <bookmark_name> - Goes to the bookmark. Uses cd, $EDITOR, and kOPENER'
        echo 'remove <bookmark_name> - Deletes the bookmark'
        echo 'list - Lists all available bookmarks'
        echo ''
    end

    switch $argv[1]
        case "go"
            if [ (count $argv) -lt 2 ]
                __bookmarks_print_error "Please provide the bookmark name"
                return 1
            end
            set -l bname $argv[2]
            if not grep -q "^$bname " $BMS_FILE
                __bookmarks_print_error "No bookmark by the name of $bname exists."
                return 1
            end
            set bpath (grep "^$bname " $BMS_FILE | cut -f2- -d' ')
            if [ -e "$bpath" ]
                if [ -d "$bpath" ]
                    cd "$bpath"
                    return 0
                else
                    __bookmarks_opener "$bpath"
                end
            else
                __bookmarks_print_error "Bookmark is no longer valid for $bpath."
                read -l -P 'Would you like to remove it?? [y/N] ' confirm
                switch $confirm
                    case Y y
                        sed -i "/^$bname /d" $BMS_FILE
                        echo "Bookmark '$bname' removed."
                        __bookmarks_update_completions
                    case '' n N
                        return 1
                end
            end
            
        case "add"
            if [ (count $argv) -gt 1 ]
                set bname $argv[2]
                if echo $bname | not grep -q "^[a-zA-Z0-9_-]*\$"
                    __bookmarks_print_error "Bookmark names may only contain alphanumeric characters and underscores."
                    return 1
                end
                if [ (count $argv) -gt 2 ]
                    set bpath (readlink -f $argv[3])
                    if not [ -e "$bpath" ]
                        __bookmarks_print_error "No directory or path exist for provided argument."
                        return 1
                    end
                else
                    set bpath (pwd)
                end
            else
                set bname (string replace -ar [^a-zA-Z0-9] _ (basename (pwd)))
                set bpath (pwd)
            end
            if grep -q "^$bname " $BMS_FILE
                __bookmarks_print_error "Bookmark $bname already exists."
                return 1
            end
            echo "$bname $bpath" >> $BMS_FILE
            set -l ftype ([ -d $bname ] && echo "file" || echo "directory")
            __bookmarks_update_completions
            echo "Bookmark '$bname' added for $ftype $bpath"

        case "remove"
            if [ (count $argv) -lt 2 ]
                __bookmarks_print_error "Please provide the bookmark name"
                return 1
            end
            set -l bname $argv[2]
            if not grep -q "^$bname " $BMS_FILE
                __bookmarks_print_error "No bookmark by the name of $bname exists."
                return 1
            end
            sed -i "/^$bname /d" $BMS_FILE
            __bookmarks_update_completions
            echo "Bookmark '$bname' removed."

        case "list"
            set bpath (grep "^$bname " $BMS_FILE | cut -f2- -d' ')
            # Use a random delimeter {*#*} that's unlikely that someone has used for a file/dir name
            # If not directories with spaces will be split into columns
            echo -n (set_color green)
            echo " Name {*#*} Path" | cat - $BMS_FILE | sed "2,\$ s/^\([[:alnum:]_-]\+\)/$title_col &{*#*}$text_col/" | column -t -s "{*#*}"
            echo
    end
        
end

function __bookmarks_opener --description "Default opener"
    set -l f "$argv[1]"
    switch (file --mime-type -b "$f")
        case "text/*"
            $EDITOR "$f"
        case "application/*"
            file "$f" | grep -iq text && $EDITOR "$f" || $BMS_OPENER "$f"
        case "image/*"
            sxiv "$f" 2> /dev/null && $BMS_OPENER "$f"
        case "*"
            $BMS_OPENER "$f"
    end
end

function __bookmarks_print_error
    echo -n $error_col
    echo -n "Error: "
    echo -n $text_col
    echo $argv[1]
end

function __bookmarks_update_completions
    set -l bmarks $HOME/.config/fish/bmarks
    set -l cmds add remove go list
    set -l cnd __fish_seen_subcommand_from $cmds
    # set -l sub_cmd_cnd "(not __fish_seen_subcommand_from) $cmds"
    complete -f -c bookmark -a "$cmds[1]" -n "not $cnd" -d "Description 1 with more words hello there"
    complete -f -c bookmark -a "$cmds[2]" -n "not $cnd" -d "Description 2 how about this will this help create the other style?"
    complete -f -c bookmark -a "$cmds[3]" -n "not $cnd" -d "Description 3"
    complete -f -c bookmark -a "$cmds[4]" -n "not $cnd" -d "Description 3"

    for bmark in (cat $bmarks)
        set -l bname (echo $bmark | cut -f1  -d' ')
        set -l bpath (echo $bmark | cut -f2- -d' ')
        if [ -e "$bpath" ]
            set description (echo -n $bpath; [ -d $bpath ] && echo -n ' - Dir' || echo -n ' - File')
        else
            set description "Bookmark target no longer exists"
        end

        complete -x -c bookmark -a "$bname" -n "__fish_seen_subcommand_from go remove" -d "$description"
    end

    complete -c g -w bookmark
end
