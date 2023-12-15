#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 file1.ass file2.ass"
    exit 1
fi

# Assigning arguments to variables
file1="$1"
file2="$2"
output_file="${file2%.*}.merged.ass"

# Function to modify the Alignment value
modify_alignment() {
    local file=$1
    local temp_file=$(mktemp /tmp/tempfile.XXXXXX.ass)

    # Find the position of the Alignment field
    local format_line=$(grep -m 1 '^\Format:' "$file")
    local alignment_position=$(echo $format_line | tr ',' '\n' | grep -n 'Alignment' | cut -d: -f1)

    # Use awk to modify the alignment value
    awk -v pos=$alignment_position -F, 'BEGIN{OFS=","} /^Style:/ {$pos=8; print; next} {print}' "$file" > "$temp_file"

    # Echo the temp file
    echo "$temp_file"
}

get_dialogue() {
    file=$1

    # Find the line number for '[V4+ Styles]' in file and subtract 1
    styles_line=$(grep -n '\[V4+ Styles\]' "$file" | cut -d: -f1)

    # Check if the line was found
    if [ -z "$styles_line" ]; then
        echo "Unable to find '[V4+ Styles]' in $file2"
        exit 2
    fi

    let styles_line=styles_line-1

    tail -n +$styles_line "$file"
}



# Function to extract the start time from the first dialogue line of a file
extract_first_time() {
    grep -m 1 '^Dialogue:' "$1" | cut -d ',' -f2
}

# Function to convert time format to seconds
time_to_seconds() {
    hour=$(echo $1 | cut -d ':' -f1)
    min=$(echo $1 | cut -d ':' -f2)
    sec=$(echo $1 | cut -d ':' -f3)
    echo "$hour*3600 + $min*60 + $sec" | bc
}

# Extracting times from both files
time1=$(extract_first_time "$1")
time2=$(extract_first_time "$2")

# Converting times to seconds
sec1=$(time_to_seconds "$time1")
sec2=$(time_to_seconds "$time2")

# Calculating the difference
diff=$(echo "$sec2 - $sec1" | bc)

# Modify subtitles to be at the top of the screen
modified_file1=$(modify_alignment "$file1")

# Shift subtitles in file1
shifted_file1=$(mktemp -u /tmp/tempfile.XXXXXX.ass)
ffmpeg -itsoffset $diff -i "$modified_file1" -c copy "$shifted_file1"
rm "$modified_file1"

# Merging the files
sed -i 's/Default,/Top,/g' "${shifted_file1}"
cat "${file2}" <(get_dialogue "${shifted_file1}") > "${output_file}"

# Cleanup
rm "$shifted_file1"

echo "Merged file created: $output_file"

