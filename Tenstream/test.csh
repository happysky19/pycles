#! /bin/csh -f 

set echo 

set TENSTR = '/home/thl/tenstream/build/include'
set BPATH  = $cwd/tenstream_build

mkdir -p obj_tenstr
cd obj_tenstr

# build wrapper for Tenstream
gfortran -L${TENSTR} -c ../tenstr_wrapper.f90

#ld -L${TENSTR} -r tenstr_wrapper.o \
#   -o ../tenstr_conbined.o

