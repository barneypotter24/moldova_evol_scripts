import os

if __name__ == "__main__":
    bam_dir = "BAM"

    rename_count = 0
    for fname in os.listdir(bam_dir):
        if fname.endswith(".bam"):
            extension = ".bam"
        elif fname.endswith(".bam.bai"):
            extension = ".bam.bai"
        elif fname.endswith(".bai"):
            extension = ".bai"
        else:
            print(f"Skipping non-BAM file: {fname}")
            continue

        if "_f" in fname:
            sep = "_f"
            fbase = fname.split(sep)[0]
            new_fname = f"{bam_dir}/{fbase}{extension}"
            print(f"Renaming {bam_dir}/{fname} to {new_fname}")
            os.rename(f"{bam_dir}/{fname}", new_fname)
            rename_count += 1
        else:
            print(f"Skipping file without _f ta: {fname}")

    print(f"Total files renamed: {rename_count}")
