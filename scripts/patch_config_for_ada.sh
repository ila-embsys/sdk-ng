#!/bin/bash

config=$1

grep -qF 'CT_EXPERIMENTAL' ${config} || echo "CT_EXPERIMENTAL=y" >> ${config}
grep -qF 'CT_CC_LANG_ADA' ${config} || echo "CT_CC_LANG_ADA=y" >> ${config}
sed -i 's/CT_CC_GCC_EXTRA_CONFIG_ARRAY="/CT_CC_GCC_EXTRA_CONFIG_ARRAY="--disable-libada /' ${config}

printf "\n###\nPatch config: ${config}\n###\n"
cat ${config} | grep CT_EXPERIMENTAL
cat ${config} | grep CT_CC_LANG_ADA
cat ${config} | grep CT_CC_GCC_EXTRA_CONFIG_ARRAY
printf "###\n"
