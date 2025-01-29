#VCFtools - 0.1.16
#(C) Adam Auton and Anthony Marcketta 2009
#
#Parameters as interpreted:
#        --vcf sample_0_genotyped_segments.vcf
#        --recode-INFO-all
#        --keep-only-indels
#        --out /data/Retratos/231207_A01123_0169_AHLHYNDRX3/arthur/teste_vcftools/INDELS_segments
#        --recode


#!/bin/bash
indel_vcf_folder='/home/shuzoarthur/mestrado/resultados_vcf/indels_resultados'


# Selecionar a coluna QUAL do arquivo .vcf
cat $indel_vcf_folder/INDELS_segments_sample_0.recode.vcf | grep -v '#' | cut -f 5,6 > $indel_vcf_folder/qual_column.txt


# Agrupar em DUP e DEL e Ordernar
cat $indel_vcf_folder/qual_column.txt | grep 'DUP' | cut -f 2 | sort -n > $indel_vcf_folder/dup_arquivo.txt
cat $indel_vcf_folder/qual_column.txt | grep 'DEL' | cut -f 2 | sort -n > $indel_vcf_folder/del_arquivo.txt


# Crriacao de arquivos .vcf para DUP e DEL
cat $indel_vcf_folder/INDELS_segments_sample_0.recode.vcf | grep 'DUP' > $indel_vcf_folder/DUP_segments_sample_0.recode.vcf
cat $indel_vcf_folder/INDELS_segments_sample_0.recode.vcf | grep 'DEL' > $indel_vcf_folder/DEL_segments_sample_0.recode.vcf


# Função para calcular média, mediana e desvio padrão
calcula_estatisticas () {
    local arquivo=$1
    local saida=$2
    local DUP_DEL_vcf=$3

    # Verificar se o arquivo está vazio
    if [[ ! -s "$arquivo" ]]; then
        echo "Arquivo $arquivo está vazio. Não há dados para calcular." >> "$saida"
        return
    fi

    # Calcular a média
    media=$(awk '{sum+=$1} END {if (NR > 0) print sum/NR}' "$arquivo")

    # Contagem de valores
    count=$(wc -l < "$arquivo")

    # Calcular a mediana
    if (( count % 2 == 1 )); then
        # Ímpar: Mediana é o valor do meio
        mediana=$(awk "NR == $((count/2+1))" "$arquivo")
    else
        # Par: Mediana é a média dos dois valores do meio
        mediana=$(awk "NR == $((count/2)) || NR == $((count/2+1))" "$arquivo" | awk '{sum+=$1} END {print sum/2}')
    fi

    # Calcular o desvio padrão
    desvio_padrao=$(awk -v media="$media" '{sum+=($1-media)^2} END {if (NR > 0) print sqrt(sum/NR)}' "$arquivo")

    # Exibir os resultados
    echo "Arquivo: $arquivo" > "$saida"
    echo "Média: $media" > "$saida"
    echo "Mediana: $mediana" > "$saida"
    echo "Desvio Padrão: $desvio_padrao" > "$saida"
    echo "----------------------------" > "$saida"

    # VCFTools para filtrar a coluna QUAL pelo treshold estabelecido pela MEDIANA
    vcftools --vcf $indel_vcf_folder/$DUP_DEL_vcf --recode-INFO-all --minQ $mediana --out $indel_vcf_folder/PASS_"$DUP_DEL_vcf" --recode

}

# Arquivo para salvar os resultados de estatísticas
saida_dup="$indel_vcf_folder/dup_estatisticas_sample_0.txt"
saida_del="$indel_vcf_folder/del_estatisticas_sample_0.txt"

# Calcular estatísticas para DUP e DEL
cd $indel_vcf_folder
calcula_estatisticas "$indel_vcf_folder/dup_arquivo.txt" "$saida_dup" "DUP_segments_sample_0.recode.vcf"
calcula_estatisticas "$indel_vcf_folder/del_arquivo.txt" "$saida_del" "DEL_segments_sample_0.recode.vcf"


## Funcao que plota o histograma
#python $indel_vcf_folder/histograma_distri_qual.py

# Remove os arquivos temporarios
rm  $indel_vcf_folder/dup_arquivo.txt $indel_vcf_folder/del_arquivo.txt $indel_vcf_folder/qual_column.txt

