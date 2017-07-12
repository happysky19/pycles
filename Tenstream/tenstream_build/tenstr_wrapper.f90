! refer to Fabian's tents_rrtmg.f90
module tenstr_wrapper

      use iso_c_binding

      use m_tenstr_rrtmg, only : tenstream_rrtmg
      

      implicit none

     
contains
      
      subroutine c_tenstr &
                  (comm, nxp, nyp, nzp, dx, dy, phi0, theta0,      &
                   albedo_thermal, albedo_solar, atm_filename,     &
                   lthermal, lsolar,                               &
                   edir,edn,eup,abso,                              &
                   d_plev, d_tlev, d_tlay, d_h2ovmr, d_o3vmr,      &
                   d_co2vmr, d_ch4vmr, d_n2ovmr,  d_o2vmr,         &
                   d_lwc, d_reliq, d_iwc, d_reice,                 &
                   nxproc, nyproc, icollapse,                      &
                   opt_time, solar_albedo_2d) bind(c)

          integer(c_int), value :: comm      ! MPI Comunicator
          integer(c_int), intent(in) :: nxp, nyp, nzp
          real(c_double), intent(in) :: dx, dy   ! horizontal grid spacing in [m]
          real(c_double), intent(in) :: phi0, theta0 ! Sun's angles, azimuth phi(0=North, 90=East), zenith(0 high sun, 80=low sun)
          real(c_double), intent(in) :: albedo_solar, albedo_thermal ! broadband ground albedo for solar and thermal spectrum
   
          ! Filename of background atmosphere file. ASCII file with columns:
          ! z(km)  p(hPa)  T(K)  air(cm-3)  o3(cm-3) o2(cm-3) h2o(cm-3)  co2(cm-3)
          ! no2(cm-3)
          character(kind =c_char), intent(in) :: atm_filename

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
          integer(c_int),intent(in),optional :: nxproc(nxp), nyproc(nyp)

          integer(c_int),intent(in),optional :: icollapse ! experimental, dont use it if you dont know what you are doing.

          ! opt_time is the model time in seconds. If provided we will track the error growth of the solutions and compute new solutions only after threshold estimate is exceeded.
          ! If solar_albedo_2d is present, we use a 2D surface albedo
          real(c_float), optional, intent(in) :: opt_time, solar_albedo_2d(nxp,nyp)


          ! ------ Output ------
          ! Fluxes and absorption in [W/m2] and [W/m3] respectively.
          ! Dimensions will probably be bigger than the dynamics grid, i.e. will have the size of the merged grid. If you only want to use heating rates on the
          ! the size of the merged grid. If you only want to use heating rates on the
          ! dynamics grid, use the lower layers, i.e.,
          !   edn(ubound(edn,1)-nlay_dynamics : ubound(edn,1) )
          ! or:
          !   abso(ubound(abso,1)-nlay_dynamics+1 : ubound(abso,1) )
          real(c_double), dimension(nzp,nxp,nyp), intent(out) :: edir,edn,eup
          real(c_double), dimension(nzp-1,nxp,nyp), intent(out) :: abso

          call tenstream_rrtmg &
                  (comm, dx, dy, phi0, theta0,                     &
                   albedo_thermal, albedo_solar, atm_filename,     &
                   lthermal, lsolar,                               &
                   edir,edn,eup,abso,                              &
                   d_plev, d_tlev, d_tlay, d_h2ovmr, d_o3vmr,      &
                   d_co2vmr, d_ch4vmr, d_n2ovmr,  d_o2vmr,         &
                   d_lwc, d_reliq, d_iwc, d_reice,                 &
                   nxproc, nyproc, icollapse,                      &
                   opt_time, solar_albedo_2d)


      end subroutine c_tenstr
        
end module
