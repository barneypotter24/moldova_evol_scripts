import os

if __name__ == "__main__":
    vcf_dir = "VCF"

    rename_count = 0
    for fname in os.listdir(vcf_dir):
        if fname.endswith(".vcf"):
            extension = ".vcf"
        elif fname.endswith(".vcf.idx"):
            extension = ".vcf.idx"
        else:
            print(f"Skipping non-VCF file: {fname}")
            continue

        if "_f" in fname:
            sep = "_f"
            fbase = fname.split(sep)[0]
            new_fname = f"{vcf_dir}/{fbase}{extension}"
            print(f"Renaming {vcf_dir}/{fname} to {new_fname}")
            # os.rename(f"{vcf_dir}/{fname}", new_fname)
            rename_count += 1
        else:
            print(f"Skipping file without lane info: {fname}")

    print(f"Total files renamed: {rename_count}")
