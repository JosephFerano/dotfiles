# Copy a windows path to clipboard
function w2u
    set -l wpath (wslpath "$argv[1]")
    echo Copied \"$wpath\" to clipboard
    echo -n "$wpath" | clip.exe
end
