#!/bin/python3
# pdfpng - convert pdf to png
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

import sys
import fitz as pdf

if len(sys.argv) != 2:
    print("usage: pdfpng [file]")
    sys.exit()

doc = pdf.open(sys.argv[1])
for num, page in enumerate(doc):
    pixmap = page.get_pixmap()
    pixmap.save(f"{sys.argv[1].split('.')[0]}{num}.png")
doc.close()
