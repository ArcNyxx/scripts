#!/bin/python3
# line_count.py - count the number of lines per file extension recursively
# Copyright (C) 2021 FearlessDoggo21
# see LICENCE file for licensing information

import os, sys

allowed = ["c", "cpp", "s", "sh", "py"]

def main():
    total, indiv, filels = 0, [0] * len(allowed), []

    for path, dirs, files in os.walk(sys.argv[1]):
        filels += [os.path.join(path, f) for f in files if f.split(".")[-1] in allowed]

    for file in filels:
        with open(file, "r", encoding="utf-8") as fopen:
            text = fopen.read()
            count = len(text.split("\n"))
            total += count
            indiv[allowed.index(file.split(".")[-1])] += count

    for i, val in enumerate(allowed):
        print(f"{allowed[i]}:\t Lines: {indiv[i]} Total: {indiv[i] / total if total else 0}")
    print(f"Total: {total}")

if len(sys.argv) != 2:
    print("An argument must be supplied.")
elif __name__ == "__main__":
    main()
