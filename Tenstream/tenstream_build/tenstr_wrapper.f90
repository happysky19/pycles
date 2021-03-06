! refer to Fabian's tents_rrtmg.f90
module tenstr_wrapper

      use m_data_parameters, only : init_mpi_data_parameters, iintegers, ireals, mpiint, zero, one

      use iso_c_binding

      use m_tenstr_rrtmg, only : tenstream_rrtmg
      

      implicit none

      !double precision, allocatable, dimension(:,:,:) :: edir,edn,eup,abso   
  
contains
      
      subroutine c_tenstr &
                  (comm, nxp, nyp, nzp, nz_full, dx, dy, phi0, theta0,      &
                   albedo_thermal, albedo_solar, c_atm_filename,     &
                   lthermal, lsolar,                               &
!                   edir_ir,edn_ir,eup_ir,abso_ir,                             
                   d_plev, d_tlev, d_tlay, d_h2ovmr, d_o3vmr,      &
                   d_co2vmr, d_ch4vmr, d_n2ovmr,  d_o2vmr,         &
                   d_lwc, d_reliq, d_iwc, d_reice, nxproc, nyproc, &
                   nrankx, nranky,                                  &
                   opt_time ) bind(c)
 
          integer(c_int), value :: comm      ! MPI Comunicator
          integer(c_int), intent(in) :: nxp, nyp, nzp, nz_full
          real(c_double), intent(in) :: dx, dy   ! horizontal grid spacing in [m]
          real(c_double), intent(in) :: phi0, theta0 ! Sun's angles, azimuth phi(0=North, 90=East), zenith(0 high sun, 80=low sun)
          real(c_double), intent(in) :: albedo_solar, albedo_thermal ! broadband ground albedo for solar and thermal spectrum
   
          ! Filename of background atmosphere file. ASCII file with columns:
          ! z(km)  p(hPa)  T(K)  air(cm-3)  o3(cm-3) o2(cm-3) h2o(cm-3)  co2(cm-3)
          ! no2(cm-3)
          character(kind = c_char), intent(in) :: c_atm_filename
          
          ! Compute solar or thermal radiative transfer. Or compute both at
          ! once.
          logical, intent(in) :: lsolar, lthermal
          
          ! dim(nlay_dynamics+1, nxp, nyp)
          real(c_double),intent(in) :: d_plev(nzp+1,nxp,nyp) ! pressure on layer interfaces [hPa]
          real(c_double),intent(in) :: d_tlev(nzp+1,nxp,nyp) ! Temperature on layer interfaces [K]

          ! all have dim(nlay_dynamics, nxp, nyp)
          real(c_double),intent(in),optional :: d_tlay   (nzp,nxp,nyp) ! layer mean temperature [K]
          real(c_double),intent(in),optional :: d_h2ovmr (nzp,nxp,nyp) ! watervapor volume mixing ratio [e.g. 1e-3]
          real(c_double),intent(in),optional :: d_o3vmr  (nzp,nxp,nyp) ! ozone volume mixing ratio      [e.g. .1e-6]
          real(c_double),intent(in),optional :: d_co2vmr (nzp,nxp,nyp) ! CO2 volume mixing ratio        [e.g. 407e-6]
          real(c_double),intent(in),optional :: d_ch4vmr (nzp,nxp,nyp) ! methane volume mixing ratio    [e.g. 2e-6]
          real(c_double),intent(in),optional :: d_n2ovmr (nzp,nxp,nyp) ! n2o volume mixing ratio        [e.g. .32]
          real(c_double),intent(in),optional :: d_o2vmr  (nzp,nxp,nyp) ! oxygen volume mixing ratio     [e.g. .2]
          real(c_double),intent(in),optional :: d_lwc    (nzp,nxp,nyp) ! liq water content [g/kg]
          real(c_double),intent(in),optional :: d_reliq  (nzp,nxp,nyp) ! effective radius [micron]
          real(c_double),intent(in),optional :: d_iwc    (nzp,nxp,nyp) ! ice water content [g/kg]
          real(c_double),intent(in),optional :: d_reice  (nzp,nxp,nyp) ! ice effective radius [micron]

          ! nxproc dimension of nxproc is number of ranks along x-axis, and entries in nxproc are the size of local Nx
          ! nyproc dimension of nyproc is number of ranks along y-axis, and entries in nyproc are the number of local Ny
          ! if not present, we let petsc decide how to decompose the fields(probably does not fit the decomposition of a host model)
          integer(c_int),intent(in),optional :: nxproc(nrankx), nyproc(nranky)
          integer(c_int),intent(in):: nrankx, nranky

          ! ------ Output ------
          ! Fluxes and absorption in [W/m2] and [W/m3] respectively.
          ! Dimensions will probably be bigger than the dynamics grid, i.e. will have the size of the merged grid. If you only want to use heating rates on the
          ! the size of the merged grid. If you only want to use heating rates on the
          ! dynamics grid, use the lower layers, i.e.,
          !   edn(ubound(edn,1)-nlay_dynamics : ubound(edn,1) )
          ! or:
          !   abso(ubound(abso,1)-nlay_dynamics+1 : ubound(abso,1) )
          !real(c_double), dimension(:,:,:), intent(out) :: edir,edn,eup
          !real(c_double), dimension(:,:,:), intent(out) :: abso
          !real(c_double), dimension(nz_full,nxp,nyp), intent(out) :: edir,edn,eup
          !real(c_double), dimension(nz_full-1,nxp,nyp), intent(out) :: abso
          !real(c_double), dimension(nzp,nxp,nyp), intent(out) :: edir,edn,eup
          !real(c_double), dimension(nzp-1,nxp,nyp), intent(out) :: abso
          real(ireals), allocatable, dimension(:,:,:) ::  edir_ir,edn_ir,eup_ir,abso_ir        
    
          !character(len=*),parameter :: bg_file='afglus_100m.dat'
          real(c_double), optional, intent(in) :: opt_time
          character(len=250) :: atm_filename           

          atm_filename = c_to_string(c_atm_filename)
          
          call init_mpi_data_parameters(comm)
          !call init_mpi_data_parameters(comm)
          write (*,*), "Here"
          write (*,*), nxp, nyp, nzp
          !write (*,*), d_tlay
          !write (*,*), d_tlev 
          write (*,*), "Here",comm, dx, dy, phi0, theta0, albedo_thermal, albedo_solar, atm_filename, lthermal, lsolar, nxproc, &
          nyproc
          

          call tenstream_rrtmg (comm, real(dx, kind=ireals), real(dy,kind=ireals),      &
                   real(phi0,kind=ireals), real(theta0,kind=ireals),                    &
                   real(albedo_thermal,kind=ireals), real(albedo_solar,kind=ireals),    &
                   atm_filename,  lthermal, lsolar,                                &
                   edir_ir,edn_ir,eup_ir,abso_ir,                                       &
                   d_plev=real(d_plev,kind=ireals), d_tlev=real(d_tlev,kind=ireals),                  &
                   !d_h2ovmr = real(d_h2ovmr,kind=ireals),                &
                   d_tlay=real(d_tlay,kind=ireals), d_h2ovmr = real(d_h2ovmr,kind=ireals),                &
                   d_o3vmr=real(d_o3vmr,kind=ireals),                                           &
                   d_co2vmr=real(d_co2vmr,kind=ireals), d_ch4vmr=real(d_ch4vmr,kind=ireals),              &
                   d_n2ovmr=real(d_n2ovmr,kind=ireals),  d_o2vmr=real(d_o2vmr,kind=ireals),              &
                   d_lwc=real(d_lwc,kind=ireals), d_reliq=real(d_reliq,kind=ireals),                  &
                   d_iwc=real(d_iwc,kind=ireals), d_reice=real(d_reice,kind=ireals),                  &
                   nxproc = nxproc, nyproc = nyproc,               & 
                   opt_time = real(opt_time,kind=ireals))                   
!real(phi0,kind=ireals), theta0,                     &
         !          albedo_thermal, albedo_solar, 'afglus_100m.dat',     &
 !                  albedo_thermal, albedo_solar, atm_filename,     &
         !          albedo_thermal, albedo_solar, bg_file,     &
  !                 lthermal, lsolar,                               &
    !               edir_ir,edn_ir,eup_ir,abso_ir,                  &
   !                d_plev, d_tlev, d_tlay, d_h2ovmr, d_o3vmr,      &
     !              d_co2vmr, d_ch4vmr, d_n2ovmr,  d_o2vmr,         &
      !             d_lwc, d_reliq, d_iwc, d_reice,                 &
       !            nxproc = nxproc, nyproc = nyproc,               & 
        !           opt_time = opt_time)
          


      end subroutine c_tenstr
       
      ! c_to_string function from Fabian's c_tenstream.f90 file
      function c_to_string(s) result(str)
         use iso_c_binding
         character(kind=c_char, len=1), intent(in) :: s(*)
         character(len=:), allocatable :: str
         integer i, nchars
         i = 1
         do
           if (s(i) == c_null_char) exit
           i = i + 1
         end do
         nchars = i - 1   ! Exclude null character from Fortran string 
         allocate(character(len=nchars) :: str)
         str = transfer(s(1:nchars), str)
      end function c_to_string
      

 
end module
