if not set -q BMS_FILE
    set -gx BMS_FILE $HOME/.config/fish/bmarks
end

touch $BMS_FILE

set title_col (set_color white)
set text_col (set_color green)
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
                echo -n $error_col
                echo -e "Error: Please provide the bookmark name"
                echo -n $text_col
                return 1
            end
            set bname $argv[2]
            if grep -q "^$bname " $BMS_FILE
                echo -n $error_col
                echo "Error: No bookmark by the name of $bname exists."
                echo -n $text_col
                return 1
            end
            set bpath (cut -f2- -d' ')
            if [ -e $bpath ]
            else
                
            end
            
        case "add"
            if [ (count $argv) -gt 1 ]
                set bname $argv[2]
                if echo $bname | not grep -q "^[a-zA-Z0-9_-]*\$"
                    echo -n $error_col
                    echo -e "Error: Bookmark names may only contain alphanumeric characters and underscores."
                    echo -n $text_col
                    return 1
                end
                if [ (count $argv) -gt 2 ]
                    set bpath (readlink -f $argv[3])
                    if not [ -e $bpath ]
                        echo -n $error_col
                        echo -e "Error: No directory or path exist for provided argument."
                        echo -n $text_col
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
                echo -n $error_col
                echo "Error: Bookmark $bname already exists."
                echo -n $text_col
                return 1
            end
            echo "$bname $bpath" >> $BMS_FILE
            set -l ftype ([ -d $bname ] && echo "file" || echo "directory")
            echo "Bookmark '$bname' added for $ftype $bpath"
            __bookmarks_update_completions

        case "remove"
            # if grep -q "^

        case "list"
            cat $BMS_FILE
    end
        
end

function go_to_bookmark --description "Go to (cd) to the directory associated with a bookmark"
    if [ (count $argv) -lt 1 ]
        echo -e "\033[0;31mERROR: '' bookmark does not exist\033[00m"
        return 1
    end
    if not _check_help $argv[1];
        cat $BMS_FILE | grep "^export DIR_" | sed "s/^export /set -x /" | sed "s/=/ /" | .
        set -l target (env | grep "^DIR_$argv[1]=" | cut -f2 -d "=")
        if [ ! -n "$target" ]
            echo -e "\033[0;31mERROR: '$argv[1]' bookmark does not exist\033[00m"
            return 1
        end
        if [ -d "$target" ]
            cd "$target"
            return 0
        else
            echo -e "\033[0;31mERROR: '$target' does not exist\033[00m"
            return 1
        end
    end
end

function print_bookmark --description "Print the directory associated with a bookmark"
    if [ (count $argv) -lt 1 ]
        echo -e "\033[0;31mERROR: bookmark name required\033[00m"
        return 1
    end
    if not _check_help $argv[1];
        cat $BMS_FILE | grep "^export DIR_" | sed "s/^export /set -x /" | sed "s/=/ /" | .
        env | grep "^DIR_$argv[1]=" | cut -f2 -d "="
    end
end

function delete_bookmark --description "Delete a bookmark"
    if [ (count $argv) -lt 1 ]
        echo -e "\033[0;31mERROR: bookmark name required\033[00m"
        return 1
    end
    if not _valid_bookmark $argv[1];
        echo -e "\033[0;31mERROR: bookmark '$argv[1]' does not exist\033[00m"
        return 1
    else
        sed -i='' "/DIR_$argv[1]=/d" $BMS_FILE
        _update_completions
    end
end

function list_bookmarks --description "List all available bookmarks"
    if not _check_help $argv[1];
        cat $BMS_FILE | grep "^export DIR_" | sed "s/^export /set -x /" | sed "s/=/ /" | .
        env | sort | awk '/DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
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
