# Subtitle Merge Script

This shell script merges two .ass subtitle files, aligning the timing of the second subtitle file to match the timing of the first one. It also adjusts the alignment of the subtitles to display them at the top of the screen.

## Prerequisites

- This script requires `ffmpeg` to be installed on your system.

## Usage

```sh
./merge_subtitles.sh file1.ass file2.ass
```

- `file1.ass`: The reference subtitle file.
- `file2.ass`: The subtitle file to be merged and aligned with `file1.ass`.

## Output

The merged subtitle file will be created with the name `file2.merged.ass` in the same directory as the script.

## Details

1. Checks if exactly two arguments are provided.
2. Identifies the Alignment field in the subtitle files and modifies it to display subtitles at the top of the screen.
3. Extracts the dialogues from both files.
4. Determines the time difference between the start times of the two subtitle files.
5. Adjusts the timing of the second subtitle file using `ffmpeg`.
6. Merges the modified second file with the first file, adjusting the alignment and timing.
7. Cleans up temporary files.

## Note

- This script assumes the subtitle files are in Advanced SubStation Alpha (.ass) format. You can convert subtitle files to the `.ass` format using `ffmpeg`. For example:
  ```sh
  ffmpeg -i input.srt output.ass
  ```
- If `ffmpeg` is not available, the script will not be able to adjust the timing of the subtitles.
