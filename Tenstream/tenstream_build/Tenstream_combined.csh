#! /bin/csh -f 


export LIB=/home/thl/tenstream/build/lib 
export LIB=/home/thl/petsc/fast_double/lib:$LIB 
export INC=/home/thl/petsc/include/petsc/finclude
export INC=/home/thl/petsc/include/petsc/private:$INC
export INC=/home/thl/petsc/fast_double/include:$INC
export INC=/home/thl/petsc/include:$INC
export INC=/home/thl/petsc/include/petsc:$INC
export INC=/home/thl/pycles-test/Tenstream/tenstream_build:$INC

# build wrapper for Tenstream
gfortran -I/home/thl/petsc/include/petsc/finclude -I/home/thl/petsc/include/petsc/private -I/home/thl/petsc/fast_double/include -I/home/thl/petsc/include -I/home/thl/petsc/include/petsc -I/home/thl/pycles-test/Tenstream/tenstream_build   -L/home/thl/tenstream/build/lib -L/home/thl/petsc/fast_double/lib -c -fPIC tenstr_wrapper.f90
#gfortran -L${LIB} -c -fPIC tenstr_wrapper.f90
#gfortran -c -fPIC tenstr_wrapper.f90

ld -r parkind.f90.o \
  parrrtm.f90.o rrlw_cld.f90.o rrlw_con.f90.o \
  rrlw_kg01.f90.o rrlw_kg02.f90.o rrlw_kg03.f90.o rrlw_kg04.f90.o \
  rrlw_kg05.f90.o rrlw_kg06.f90.o rrlw_kg07.f90.o rrlw_kg08.f90.o \
  rrlw_kg09.f90.o rrlw_kg10.f90.o rrlw_kg11.f90.o rrlw_kg12.f90.o \
  rrlw_kg13.f90.o rrlw_kg14.f90.o rrlw_kg15.f90.o rrlw_kg16.f90.o \
  rrlw_ref.f90.o rrlw_tbl.f90.o rrlw_vsn.f90.o \
  rrlw_wvn.f90.o \
  parrrsw.f90.o rrsw_aer.f90.o rrsw_cld.f90.o rrsw_con.f90.o \
  rrsw_kg16.f90.o rrsw_kg17.f90.o rrsw_kg18.f90.o rrsw_kg19.f90.o \
  rrsw_kg20.f90.o rrsw_kg21.f90.o rrsw_kg22.f90.o rrsw_kg23.f90.o \
  rrsw_kg24.f90.o rrsw_kg25.f90.o rrsw_kg26.f90.o rrsw_kg27.f90.o \
  rrsw_kg28.f90.o rrsw_kg29.f90.o \
  rrsw_ncpar.f90.o rrsw_ref.f90.o rrsw_tbl.f90.o rrsw_vsn.f90.o \
  rrsw_wvn.f90.o \
  rrtmg_lw_cldprmc.f90.o rrtmg_lw_cldprop.f90.o rrtmg_lw_rtrn.f90.o \
  rrtmg_lw_rtrnmc.f90.o rrtmg_lw_rtrnmr.f90.o rrtmg_lw_setcoef.f90.o \
  rrtmg_lw_taumol.f90.o rrtmg_lw_k_g.f90.o rrtmg_lw_init.f90.o \
  rrtmg_sw_cldprmc.f90.o rrtmg_sw_cldprop.f90.o rrtmg_sw_reftra.f90.o \
  rrtmg_sw_vrtqdr.f90.o rrtmg_sw_taumol.f90.o \
  rrtmg_sw_spcvmc.f90.o rrtmg_sw_spcvrt.f90.o rrtmg_sw_setcoef.f90.o \
  rrtmg_sw_k_g.f90.o rrtmg_sw_init.f90.o \
  rrtmg_lw_rad.nomcica.f90.o \
  rrtmg_sw_rad.nomcica.f90.o  \
  tenstr_rrtmg.f90.o  tenstr_rrtm_lw.f90.o tenstr_rrtm_lw_toZero.f90.o tenstr_rrtm_sw.f90.o\
  mcica_random_numbers.f90.o mcica_subcol_gen_lw.f90.o mcica_subcol_gen_sw.f90.o\
  boxmc.f90.o   eddington.f90.o   helper_functions_dp.f90.o  interpolation.f90.o  nca.f90.o\
  optprop_ANN.f90.o  optprop_LUT.f90.o    schwarzschild.f90.o  tenstream_options.f90.o\
  data_parameters.f90.o  f2c_tenstream.f90.o  helper_functions.f90.o     mersenne.f90.o\
  netcdfio.f90.o  optprop.f90.o      optprop_parameters.f90.o  tenstream.f90.o      twostream.f90.o\
  tenstr_wrapper.o \
  -o ../tenstr_rrtmg_combined.o



