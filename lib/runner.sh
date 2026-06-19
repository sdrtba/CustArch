#!/usr/bin/env bash

run_tasks() {
    local mode="$1"
    local task

    for task in "$SCRIPT_DIR"/tasks/*.sh; do
        [[ -e "$task" ]] || continue
        unset -f run_live run_chroot run_post
        source "$task"

        if declare -F "run_${mode}" >/dev/null 2>&1; then
            log "Running $(basename "$task") [$mode]"
            "run_${mode}"
        fi
    done

    unset -f run_live run_chroot run_post
}
