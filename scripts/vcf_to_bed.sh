
# Apos filtrar os arquivos .vcf do GATK-gCNV, esse scrpit serve para preparar os arquivos para
# rodar o software ClassifyCNV (.vcf --> .bed)

#!/bin/bash

bed_dir='/home/shuzoarthur/mestrado/resultados_vcf/indels_resultados/bed_files'

# Verifica se o arquivo .vcf foi fornecido
if [ $# -lt 1 ]; then
    echo "Uso: $0 arquivo.vcf"
    exit 1
fi

input_vcf=$1
output_bed="${input_vcf%.vcf}.bed"

# Processa o arquivo .vcf e gera o arquivo .bed
awk -v OFS="\t" '{
    if ($1 !~ /^#/){  # Ignora linhas de cabeçalho que começam com #
        chrom=$1                 # Coluna 1 (cromossomo)
        start=$2                 # Coluna 2 (posição inicial)
        end=""; gsub("END=", "", $8); end=$8  # Coluna 8 (extraindo apenas os números do campo END)
        alt=$5; gsub(/[<>]/, "", alt)  # Coluna 5 (extraindo apenas as letras da deleção ou inserção)
        print chrom, start, end, alt   # Imprime as colunas no formato .bed
    }
}' "$input_vcf" > "$output_bed"

echo "Arquivo .bed gerado: $output_bed"

# Mover para outro diretório
mv $output_bed /home/shuzoarthur/mestrado/resultados_vcf/indels_resultados/bed_files
