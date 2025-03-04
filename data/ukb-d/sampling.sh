#!/bin/bash

# Set the output directory for sampled files
output_dir="sampled_files"
mkdir -p "$output_dir"  # Create the output directory if it doesn't exist

# Set the sample size
sample_size=100000

# Loop over all .tsv.gz files in the current directory
for input_file in *.tsv.gz; do
    # Check if there are any .tsv.gz files
    if [[ ! -e "$input_file" ]]; then
        echo "No .tsv.gz files found in the directory."
        exit 1
    fi

    # Get the base name of the file (without the .gz extension)
    base_name=$(basename "$input_file" .gz)

    # Set the output file name
    output_file="$output_dir/${base_name}.sampled"

    # Get the header from the compressed file
    header=$(zcat < "$input_file" | head -n 1)

    # Sample the specified number of rows (excluding the header)
    zcat < "$input_file" | shuf -n "$sample_size" | tail -n +2 > sampled_rows.tsv

    # Prepend the header to the sampled rows
    echo -e "$header\n$(cat sampled_rows.tsv)" > "$output_file"

    # Compress the output file
    gzip "$output_file"

    # Clean up the temporary file
    rm sampled_rows.tsv

    echo "Sampled data from $input_file and saved to ${output_file}.gz"
done

