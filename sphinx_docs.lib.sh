
# This library finds and builds sphinx documents

SPHINXOPTS=-W
SPHINXBUILD=sphinx-build
SPHINX_DEFAULT_TARGET="singlehtml"

declare -a DOCS_REQS  # initialing

function docs_find(){
    local path='.' this_dir abs_path
    if [ "$1" != "" ] ; then
        path="$1"
    fi
    local this_dir="$( readlink -f $( dirname "${BASH_SOURCE[0]}" ))"

    for pfile in $(find $path -name "conf.py") ; do
        local abs_path=$(dirname $(readlink -f $pfile))
        if [ "$abs_path" == "$this_dir" ] ; then
            DOCS_REQS+=( $(dirname "$pfile") )
        fi
    done
    log "Found ${#DOCS_REQS[@]} documents"
}

function docs_build_one(){
    local path target this_dir puml_exec
    path="$1"
    target="$SPHINX_DEFAULT_TARGET"
    if [ "$2" != "" ] ; then
        target="$2"
    fi
    local this_dir="$( dirname "${BASH_SOURCE[0]}" )"
    local puml_exec="$(readlink -f "$this_dir/tools/plantuml.jar")"
    echo "Start building document $path"
    for pfile in $(find -L $path -name "*.puml" -type f) ; do
        if [ "$pfile" -nt "$pfile.png" ] ;then
            java -jar "$puml_exec" "$pfile" || { echo "failed to convert PUML to PNG: '$pfile'" ; return 1 ; }
            mv "${pfile:0:(-5)}.png" "$pfile.png"
            echo "Converted puml file: $pfile.png"
        else
            echo "$pfile.png already up to date"
        fi
    done

    if [ "$(yq .generate_pdf $path/doc.yaml)" == "true" ] ; then
      $SPHINXBUILD -M "pdf" "$path" "${path}/.sphinx_docs_build" "${SPHINXOPTS}"
    fi
    $SPHINXBUILD -M "$target" "$path" "${path}/.sphinx_docs_build" "${SPHINXOPTS}"
}

function docs_build(){
    if [ "$1" != "" ] ; then
        target="$1"
    fi
    for path in "${DOCS_REQS[@]}" ; do
        docs_build_one "$path" || return 1
    done
}

function docs_build_all(){
    local path='.'
    if [ "$1" != "" ] ; then
        path=$1
    fi
    docs_find "$path" || return 1
    docs_build || return 1
}

function docs_show_all_singlehtml(){
    local path='.'
    if [ "$1" != "" ] ; then
        path=$1
    fi
    local browser="chromium"
    [ "x$2" != "x" ] && browser="$2"

    docs_find
    case $browser  in
    "")
        for i in $browser_files ; do
            readlink -f "$i"
        done
    ;;
    "pdf")
        local pdf_files=""
        for path in "${DOCS_REQS[@]}" ; do
            if [ ! -d "${path}/.sphinx_docs_build" ] ; then
                docs_build_one "$path" "$target"
            fi
            local proj_name=$(yq -r .project ${path}/doc.yaml)
            pdf_files="$browser_files ${path}/.sphinx_docs_build/pdf/*${proj_name}.pdf"
        done
        for i in $pdf_files ; do
            xdg-open "$i"
        done
    ;;
    *)
        local browser_files=""
        for path in "${DOCS_REQS[@]}" ; do
            if [ ! -d "${path}/.sphinx_docs_build" ] ; then
                docs_build_one "$path" "$target"
            fi
            browser_files="$browser_files ${path}/.sphinx_docs_build/$SPHINX_DEFAULT_TARGET/index.html"
        done
        $browser "$browser_files" >/dev/null 2>&1 &
    ;;
    esac
}

function docs_install_dependencies(){
    # ERROR: sphinx-rtd-theme 1.0.0 has requirement docutils<0.18, but you'll have docutils 0.18.1 which is incompatible.
    sudo -H pip3 install --upgrade --quiet docutils==0.17 Sphinx recommonmark sphinx-rtd-theme myst_parse
    sudo apt install graphviz
}


function docs_clean_all(){
    local path='.'
    if [ "$1" != "" ] ; then
        path=$1
    fi
    docs_find "$path" || return 1
    for path in "${DOCS_REQS[@]}" ; do
        local doc_build_path="${path}/.sphinx_docs_build"
        echo "$doc_build_path"
        if [ -d "$doc_build_path" ] ; then
            rm -rf "$doc_build_path"
        fi
    done

}
