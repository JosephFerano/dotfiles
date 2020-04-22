if not set -q BMS_FILE
    set -gx BMS_FILE $HOME/.config/fish/bmarks
end
if not set -q BMS_OPENER
    set -gx BMS_OPENER xdg-open
end

touch $BMS_FILE

set title_col (set_color cyan)
set text_col (set_color normal)
set error_col (set_color red)

function bookmark --description "Bookmark files and directories in fish"
    if [ (count $argv) -lt 1 ]; or [ "-h" = $argv[1] ]; or [ "-help" = $argv[1] ]; or [ "--help" = $argv[1] ]
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
                # TODO Add prompt for deletion
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
            echo "Bookmark '$bname' added for $ftype $bpath"
            __bookmarks_update_completions

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
            sed -i "/^$bname /d" bmarks
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

function _valid_bookmark
    if begin; [ (count $argv) -lt 1 ]; or not [ -n $argv[1] ]; end
        return 1
    else
        cat $BMS_FILE | grep "^export DIR_" | sed "s/^export /set -x /" | sed "s/=/ /" | .
        set -l bookmark (env | grep "^DIR_$argv[1]=" | cut -f1 -d "=" | cut -f2 -d "_" )
        if begin; not [ -n "$bookmark" ]; or not [ $bookmark=$argv[1] ]; end
            return 1
        else
            return 0
        end
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
    cat $BMS_FILE | grep "^export DIR_" | sed "s/^export /set -x /" | sed "s/=/ /" | .
    set -x _marks (env | grep "^DIR_" | sed "s/^DIR_//" | cut -f1 -d "=" | tr '\n' ' ')
    complete -c print_bookmark -a $_marks -f
    complete -c delete_bookmark -a $_marks -f
    complete -c go_to_bookmark -a $_marks -f
    if not set -q NO_FISHMARKS_COMPAT_ALIASES
        complete -c p -a $_marks -f
        complete -c d -a $_marks -f
        complete -c g -a $_marks -f
    end
end
