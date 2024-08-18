#!/bin/bash

cd configs
  
for config in $(ls); do grep -qF 'CT_EXPERIMENTAL' ${config} || echo "CT_EXPERIMENTAL=y" >> ${config}; done
for config in $(ls); do grep -qF 'CT_CC_LANG_ADA' ${config} || echo "CT_CC_LANG_ADA=y" >> ${config}; done
for config in $(ls); do sed -i 's/CT_CC_GCC_EXTRA_CONFIG_ARRAY="/CT_CC_GCC_EXTRA_CONFIG_ARRAY="--disable-libada /' ${config}; done
for config in $(ls); do echo "\n###\n${config}\n###"
cat ${config} | grep CT_EXPERIMENTAL
cat ${config} | grep CT_CC_LANG_ADA
cat ${config} | grep CT_CC_GCC_EXTRA_CONFIG_ARRAY; done
