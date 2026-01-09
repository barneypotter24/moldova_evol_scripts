import os


if __name__ == "__main__":
    fastq_dir = "FASTQ/"
    config_dir = "config/"
    nbatches = 4

    per_cfg = 10

    total_samples = 0

    config_count = 0
    batch_samples = []

    batch_sets = [] # for validation

    for b in range(nbatches):
        batch_dir = os.path.join(fastq_dir, f"{b}")
        print(f"Processing batch directory: {batch_dir}")
        b_seqs = set()
        for fname in os.listdir(batch_dir):
            fname = fname.strip("\n")  # remove newline characters
            if fname.endswith(".fastq.gz"):
                if "_L00" in fname:
                    sep = "_L00"
                else:
                    sep = "_R"
            sample = fname.split(sep)[0]
            b_seqs.add(sample)
        print (f"Found {len(b_seqs)} unique samples in batch {b}")
        batch_sets.append(b_seqs)


        nest = [[]]
        # nest is a list of lists of sequnces
        print(f"Writing config files for batch {b}...")
        for sample in b_seqs:
            total_samples += 1
            if len(nest[-1]) < per_cfg:
                nest[-1].append(sample)
            else:
                nest.append([sample])

        batch_samples.append(nest)
        config_count += len(nest)
        # batch samples should be a list of lists of lists
        # each outer list is a batch, each inner list is a
        # config, and each innermost list is samples in
        # that config

    print(f"Total samples across all batches: {total_samples}")
    print(f"Total config files to be created: {config_count}")
    print("Creating config files...")

    config_index = 0
    for i, batch in enumerate(batch_samples):
        # i is the batch index
        for j, samps in enumerate(batch):
            cfg_fname = f"{config_dir}/config{config_index}.yaml"
            print("Creating config file:", cfg_fname)
            with open(cfg_fname, "w") as o:
                o.write(f"batch: \"{i}\"\n")
                o.write("samples:\n")
                for k, s in enumerate(samps):
                    line = f"    {k}: \"{s}\"\n"
                    o.write(line)
            config_index += 1

    print(f"Finished creating {config_index} config files.")

    print("Creating full config files...")
    for i, bset in enumerate(batch_sets):
        cfg_fname = f"{config_dir}/BATCH_{i}_FULL_CONFIG.yaml"
        print("Creating full config file:", cfg_fname)
        with open(cfg_fname, "w") as o:
            o.write(f"batch: \"{i}\"\n")
            o.write("samples:\n")
            for k, s in enumerate(bset):
                line = f"    {k}: \"{s}\"\n"
                o.write(line)

    print("Validating batch sample sets...")
    overlap = batch_sets[0] & batch_sets[1] & batch_sets[2] & batch_sets[3]
    if len(overlap) > 0:
        print("Warning: Overlapping samples found between batches:")
        for s in overlap:
            print(s)
    else:
        print("No overlapping samples found between batches.")

    print("Full batch sizes:")
    for i, bset in enumerate(batch_sets):
        print(f"\tBatch {i}: {len(bset)} samples")
