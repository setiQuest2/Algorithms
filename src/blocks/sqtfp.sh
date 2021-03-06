#!/bin/bash

FFTLEN=8388608
WINDOW="wola"

#                1         2         3         4         5         6         7
#       123456789012345678901234567890123456789012345678901234567890123456789012
usage () 
{
    echo "                                                                        " >&2
    echo "NAME                                                                    " >&2
    echo "  sqtfp - creates time-frequency-power data file which can be made      " >&2
    echo "        - into a waterfall      " >&2
    echo "SYNOPSIS                                                                " >&2
    echo "  sqtfp [OPTIONS] files...                                              " >&2
    echo "OPTIONS                                                                 " >&2
    echo "  -l integer (optional), FFT length; default value is 8388608           " >&2
    echo "  -w window type [wola, hann]; default is wola                          " >&2
    echo "  -p show progress                                                      " >&2
    echo "  -h show help(this)                                                    " >&2
    echo "EXAMPLE                                                                 " >&2
    echo "  sqtfp -l 4194304 -w hann -p 2010-10-15-crab_1420_1-8bit-{01,02,03}.dat" >&2
    echo "                                                                        " >&2
}

while getopts l:w:ph OPT
    do
        case $OPT in
        l) FFTLEN=$OPTARG;;
        w) WINDOW=$OPTARG;;
        p) SHOW_PROGRESS=1;;
        h) usage && exit 1;;
    esac
done

shift $(expr $OPTIND - 1)

FILES=$*
    
if [ ! "$FILES" ]; then
    usage
    exit 1
fi

# Process data to a time-frequency-power file
if [ "$WINDOW" == "wola" ]; then
    WINDOW_BLOCK="sqwola -f 9 -o 0"
else
    WINDOW_BLOCK="sqwindow -w $WINDOW"
fi

FILESIZE=0
if [ "$SHOW_PROGRESS" == 1 ]; then
    for filename in $FILES
    do
        FILESIZE=$(echo "$FILESIZE+$(stat -c%s "$filename")" | bc)
    done
fi

cat $FILES | sqsample -l $FFTLEN -s $FILESIZE 2>&2 | $WINDOW_BLOCK -l $FFTLEN | sqfft -l $FFTLEN | sqpower -l $FFTLEN | sqreal -l $FFTLEN