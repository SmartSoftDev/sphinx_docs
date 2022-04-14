#!/usr/bin/env python3
"""
 Copyright (C) Smartsoftdev.eu SRL - All Rights Reserved
 Proprietary and confidential license.
 Unauthorized copying via any medium or use of this file IS STRICTLY prohibited
 For any license violations or more about commercial licensing please contact:
 SmartSoftDev.eu

Provides utilities to get information for Sphinx documents generated with various automatic information.
see Readme.md
see https://www.sphinx-doc.org/en/master/usage/markdown.html for markdown support
"""
import os
import yaml
import subprocess


def get_config(conf_py_fpath):
    cwd = os.path.abspath(os.path.realpath(os.path.dirname(conf_py_fpath)))
    doc = {
        "project": "NoProjectName",
        "title": "NoTitle",
        "author": "noAuthor",
        "version": "0.1",
        "copyright": "noCopyright",
        "generate_git_version": True,
        "generate_change_history": False,  # TODO-SSD: de implementat istoricul din yaml sau din git.
        "tags": [],
    }

    doc_fpath = os.path.join(cwd, "doc.yaml")
    print(doc_fpath)
    if os.path.exists(doc_fpath):
        with open(doc_fpath) as f:
            _doc = yaml.safe_load(f)
        print(_doc)
        doc.update(_doc)
    version = doc.get("version")
    if doc.get("generate_git_version"):
        git_commits_out = subprocess.check_output(["git", "log", "--format=%H", "."], cwd=cwd).decode().split("\n")
        git_commits = []
        for i in git_commits_out:
            i = i.strip()
            if not len(i):
                continue
            git_commits.append(i)
        git_diff_out = subprocess.check_output(["git", "diff", "--name-only", "."], cwd=cwd).decode().split("\n")
        git_diff_out = [i.strip() for i in git_diff_out if len(i.strip())]
        if len(git_commits):
            if version.endswith("."):
                version += str(len(git_commits))
            else:
                version += "." + str(len(git_commits))
            version += "." + git_commits[0][:6]
        if len(git_diff_out):
            version += " (dirty)"
    doc["version"] = version
    return doc


extensions = [
    "sphinx.ext.todo",
    "sphinx.ext.coverage",
    "sphinx.ext.mathjax",
    "sphinx.ext.ifconfig",
    "sphinx.ext.viewcode",
    "sphinx_rtd_theme",
    "myst_parser",
]

templates_path = ["_templates"]
source_suffix = {".rst": "restructuredtext", ".md": "markdown"}
master_doc = "index"
doc = get_config(__file__)

title = doc.get("title")
project = doc.get("project")
copyright = doc.get("copyright")
author = doc.get("author")
version = doc.get("version")
release = version

language = None
exclude_patterns = []
pygments_style = "sphinx"
todo_include_todos = True
html_theme = "sphinx_rtd_theme"
html_static_path = []
htmlhelp_basename = "hh_doc"
latex_elements = {
    # The paper size ('letterpaper' or 'a4paper').
    #
    # 'papersize': 'letterpaper',
    # The font size ('10pt', '11pt' or '12pt').
    #
    # 'pointsize': '10pt',
    # Additional stuff for the LaTeX preamble.
    #
    # 'preamble': '',
    # Latex figure (float) alignment
    #
    # 'figure_align': 'htbp',
}
latex_documents = [
    (master_doc, "documentation.tex", title, author, "manual"),
]
man_pages = [(master_doc, "documentation", title, [author], 1)]
texinfo_documents = [
    (master_doc, title, title, author, title, title, "Miscellaneous"),
]
