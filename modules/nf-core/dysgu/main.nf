process DYSGU {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/dysgu%3A1.6.2--py310h770aed0_0' :
        'biocontainers/dysgu:1.6.2--py310h770aed0_0' }"

    input:
    tuple val(meta), path(input_bam), path(input_bam_index)
    tuple val(meta2), path(fasta), path(fai)

    output:
    tuple val(meta), path('*.vcf.gz')       , emit: vcf
    tuple val(meta), path('*.vcf.gz.tbi')   , emit: tbi
    path 'versions.yml'                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """

    dysgu run \\
        -p ${task.cpus} \\
        $fasta \\
        . \\
        $input_bam \\
        | bgzip ${args2} --threads ${task.cpus} --stdout > ${prefix}.vcf.gz
    tabix ${args3} ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dysgu: \$(dysgu --version 2>&1)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo "" | gzip > ${prefix}.vcf.gz
    touch ${prefix}.vcf.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dysgu: \$(dysgu --version 2>&1)
    END_VERSIONS
    """
}
