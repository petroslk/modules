process MD5SUM {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "conda-forge::coreutils=8.25" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/coreutils:8.31--h14c3975_0' :
        'quay.io/biocontainers/coreutils:8.31--h14c3975_0' }"

    input:
    tuple val(meta), path(file)

    output:
    tuple val(meta), path("*.md5"), emit: checksum
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    md5sum \\
        $args \\
        ${file} \\
        > ${file}.md5

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        md5sum: \$(echo \$(md5sum --version 2>&1 | head -n 1| sed 's/^.*) //;' ))
    END_VERSIONS
    """
}
