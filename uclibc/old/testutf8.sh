#! /ffp/bin/sh

fast_chr() {
    local __octal
    local __char
    printf -v __octal '%03o' $1
    printf -v __char \\$__octal
    REPLY=$__char
}

function unichr {
    local c=$1  # ordinal of char
    local l=0   # byte ctr
    local o=63  # ceiling
    local p=128 # accum. bits
    local s=''  # output string

    (( c < 0x80 )) && { fast_chr "$c"; echo -n "$REPLY"; return; }

    while (( c > o )); do
        fast_chr $(( t = 0x80 | c & 0x3f ))
        s="$REPLY$s"
        (( c >>= 6, l++, p += o+1, o>>=1 ))
    done

    fast_chr $(( t = p | c ))
    echo -n "$REPLY$s"
}

## test harness 
for (( i=0x2500; i<0x2600; i++ )); do
    unichr $i
done