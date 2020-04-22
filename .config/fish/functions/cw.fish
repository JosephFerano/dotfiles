function cw
    set -l wpath (wslpath -a -w (readlink -f "$argv[1]"))
    echo Copied \"$wpath\" to clipboard
    echo -n $wpath | clip.exe
end
