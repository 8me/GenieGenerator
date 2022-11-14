#!/bin/bash 

GENIE_VERSION=master
if [ ! -z "$1" ] ; then 
  GENIE_VERSION=$1
fi

export GENIEBASE=$(pwd)
export GENIE=$GENIEBASE/Generator 
export GENIE_BIN=$GENIE/bin
export GENIE_LIB=$GENIE/lib
export PYTHIA6=$PYTHIA_FQ_DIR/lib 
export LHAPDF5_INC=$LHAPDF_INC 
export LHAPDF5_LIB=$LHAPDF_LIB 
export XSECSPLINEDIR=$GENIEBASE/data 
export GENIE_REWEIGHT=$GENIEBASE/Reweight 
export PATH=$GENIE/bin:$GENIE_REWEIGHT/bin:$PATH 
export LD_LIBRARY_PATH=$GENIE_LIB:$GENIE_REWEIGHT/lib:$LD_LIBRARY_PATH 
unset GENIEBASE 

if [ ! -z "$2" ] ; then
  GENIE_CONFIG_DIR=$2
  echo Requested Genie config $GENIE_CONFIG_DIR 
  if [ -d "$GENIE/$GENIE_CONFIG_DIR" ]; then
    GALGCONF=$GENIE/$GENIE_CONFIG_DIR
    export GALGCONF
    echo Genie config directory $GALGCONF
  else 
    if [ -d "$GENIE_CONFIG_DIR" ]; then 
      GALGCONF=$GENIE_CONFIG_DIR
      export GALGCONF
      echo Genie config directory $GALGCONF
    fi
  fi
else
  unset GALGCONF
fi

git clone https://github.com/GENIE-MC/Generator.git Generator 

cd $GENIE 

git checkout "$GENIE_VERSION" 
echo "Requested Genie Git Branch $GENIE_VERSION"

source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh && retval="$?"
source /cvmfs/fermilab.opensciencegrid.org/products/genie/bootstrap_genie_ups.sh 
source /cvmfs/fermilab.opensciencegrid.org/products/common/etc/setups 
setup ifdhc v2_6_6
export IFDH_CP_MAXRETRIES=0

source /grid/fermiapp/products/larsoft/setup

setup root v6_12_06a -q e17:debug 
setup lhapdf v5_9_1k -q e17:debug 
setup log4cpp v1_1_3a -q e17:debug 
setup pdfsets v5_9_1b 
setup gdb v8_1 
setup git v2_15_1 

./configure \
--enable-rwght \
--enable-flux-drivers \
--enable-geom-drivers \
--disable-doxygen \
--enable-test \
--enable-mueloss \
--enable-dylibversion \
--enable-t2k \
--enable-fnal \
--enable-atmo \
--enable-nucleon-decay \
--enable-rwght \
--disable-masterclass \
--disable-debug \
--with-optimiz-level=O2 \
--disable-debug \
--disable-profiler  \
--enable-validation-tools \
--disable-cernlib \
--enable-lhapdf5 \
--with-log4cpp-inc=${LOG4CPP_INC} \
--with-log4cpp-lib=${LOG4CPP_LIB} \
--with-libxml2-inc=${LIBXML2_INC} \
--with-libxml2-lib=${LIBXML2_LIB} \
--with-lhapdf5-lib=${LHAPDF_LIB} \
--with-lhapdf5-inc=${LHAPDF_INC} \
--with-pythia6-lib=${PYTHIA_LIB}
#--enable-incl \
#--with-incl-inc=${INCL_FQ_DIR}/include/inclxx \
#--with-incl-lib=${INCL_FQ_DIR}/lib  \
#--with-boost-inc=${BOOST_FQ_DIR}/include \
#--with-boost-lib=${BOOST_FQ_DIR}/lib

make

cd ..
