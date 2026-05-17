#!/usr/bin/env bash

set -Eeuo pipefail



OUTDIR="${1:-output}"
DATADIR="${OUTDIR}/geo_raw"
TMPDIR="${OUTDIR}/tmp"

GEO_URL="http://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE45719&format=file"
ARCHIVE="${TMPDIR}/gse45719.tar"

STAGES=(
  zy
  early2cell
  mid2cell
  late2cell
  4cell
  8cell
  16cell
  earlyblast
  midblast
  lateblast
)

mkdir -p "${DATADIR}" "${TMPDIR}"



log() {
    printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}



fetch_dataset() {
    log "Downloading GEO archive"

    wget -q -O "${ARCHIVE}" "${GEO_URL}"

    log "Extracting archive"

    tar -xf "${ARCHIVE}" -C "${DATADIR}"

    log "Decompressing expression files"

    find "${DATADIR}" -name '*.gz' -print0 | xargs -0 gunzip
}


find_stage_files() {
    local stage="$1"

    case "$stage" in
        zy)
            compgen -G "${DATADIR}/GSM111*_zy*" ;;
        early2cell)
            compgen -G "${DATADIR}/GSM111*_early2cell_*" ;;
        mid2cell)
            compgen -G "${DATADIR}/GSM111*_mid2cell_*" ;;
        late2cell)
            compgen -G "${DATADIR}/GSM111*_late2cell_*" ;;
        4cell)
            compgen -G "${DATADIR}/GSM111*_4cell_*" ;;
        8cell)
            compgen -G "${DATADIR}/*_8cell_*-*" ;;
        16cell)
            compgen -G "${DATADIR}/GSM111*_16cell_*" ;;
        earlyblast)
            compgen -G "${DATADIR}/GSM111*_earlyblast_*" ;;
        midblast)
            compgen -G "${DATADIR}/GSM111*_midblast_*" ;;
        lateblast)
            compgen -G "${DATADIR}/GSM111*_lateblast_*" ;;
    esac | sort
}

############################################
# Header generation
############################################

sample_name_from_file() {
    local filepath="$1"
    local stage="$2"

    local base
    base=$(basename "$filepath")

    local sample_id

    sample_id=$(echo "$base" | grep -oE '[0-9]+' | tail -n 1)

    printf '%s_%s\n' "$stage" "$sample_id"
}


extract_matrix() {
    local stage="$1"
    local column_offset="$2"
    local outfile="$3"

    mapfile -t files < <(find_stage_files "$stage")

    [[ ${#files[@]} -gt 0 ]] || fail "No files found for stage: ${stage}"

    log "Processing ${stage} (${#files[@]} samples)"

    local headers=()

    for f in "${files[@]}"; do
        headers+=("$(sample_name_from_file "$f" "$stage")")
    done

    {
        printf '%s\n' "$(IFS=$'\t'; echo "${headers[*]}")"

        paste "${files[@]}" |
        tail -n +2 |
        awk -v start_col="$column_offset" '
        BEGIN {
            OFS="\t"
        }

        {
            row=""

            for (i = start_col; i <= NF; i += 6) {
                row = row (row == "" ? "" : OFS) $i
            }

            print row
        }'
    } > "$outfile"
}



extract_gene_names() {
    local source_file

    source_file=$(find "${DATADIR}" -name 'GSM1112767_zy2_expression.txt' | head -n 1)

    [[ -n "$source_file" ]] || fail "Reference expression file not found"

    awk -F'\t' 'NF > 0 && $1 != "" { print $1 }' "$source_file" \
        > "${OUTDIR}/gene_names.txt"
}



combine_outputs() {
    local prefix="$1"
    local final_name="$2"

    mapfile -t matrices < <(find "${TMPDIR}" -name "${prefix}_*.tsv" | sort)

    paste "${OUTDIR}/gene_names.txt" "${matrices[@]}" \
        > "${OUTDIR}/${final_name}"
}


main() {
    fetch_dataset

    extract_gene_names

    log "Generating read-count matrices"

    for stage in "${STAGES[@]}"; do
        extract_matrix \
            "$stage" \
            4 \
            "${TMPDIR}/reads_${stage}.tsv"
    done

    combine_outputs "reads" "deng_reads.tsv"

    log "Generating RPKM matrices"

    for stage in "${STAGES[@]}"; do
        extract_matrix \
            "$stage" \
            3 \
            "${TMPDIR}/rpkm_${stage}.tsv"
    done

    combine_outputs "rpkm" "deng_rpkm.tsv"

    log "Done"
}

main "$@"