#!/usr/bin/env python3
"""
Checks if doc.yaml has generate_pdf flag and if is True
"""
import os
import sys
import yaml

doc_dir = sys.argv[1]
doc_yaml_path = os.path.join(os.path.abspath(doc_dir), "doc.yaml")

if os.path.isfile(doc_yaml_path):
    with open(doc_yaml_path, "r") as yaml_file:
        conf = yaml.safe_load(yaml_file)
    if conf.get("generate_pdf", False):
        sys.exit(0)
    sys.exit(1)
else:
    print(f"Couldn't open file '{doc_yaml_path}'")
    sys.exit(1)
