. $(gbl log)

gblcmd_create_new_doc(){
    local DIR dst_dir relative_DIR
    DIR=$(pwd)
    dst_dir="$1"
    [ -z "$dst_dir" ] && fatal "Destination directory argument is missing"
    set -e
    [ ! -d "$dst_dir" ] && mkdir -p "$dst_dir"
    cd "$dst_dir"
    # we can always relink conf.py
    relative_DIR=$(realpath --relative-to="." "$DIR")
    ln -sf "$relative_DIR"/sphinx_conf.py ./conf.py
    ln -sf "$relative_DIR"/tpls/d.tpl.bl.sh ./d.bl.sh

    cp "$DIR"/tpls/gitignore.tpl.conf ./.gitignore
    if [ ! -e ./doc.yaml ] ; then
        cp "$DIR"/tpls/new_doc.tpl.yaml ./doc.yaml
    else
        log "doc.yaml exists ... ignoring it"
    fi
    if [ ! -e ./index.rst ] ; then
        cp "$DIR"/tpls/index.tpl.rst ./index.rst
        cp "$DIR"/tpls/Introduction.tpl.md ./Introduction.md
        cp "$DIR"/tpls/Glossary.tpl.md ./Glossary.md
    else
        log "index.rst exists ... ignoring it"
    fi
}