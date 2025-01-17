module read_data_mod
    use :: netcdf
    use :: netcdf_check, only : nc_check
    use, intrinsic :: iso_fortran_env, only : error_unit, DP => real64
    use :: error_status, only : ALLOCATION_ERR
    implicit none

    private
    public :: read_data

    interface read_data
        module procedure load_1D
        module procedure load_1D_int
        module procedure load_2D
        module procedure load_2D_int
        module procedure load_3D
    end interface read_data

contains

    subroutine load_1D(fname, varname, array)
        implicit none

        character(len=*), intent(in) :: fname, varname

        integer :: ncid, varid
        integer :: stat
        integer, dimension(1) :: dimids, dimlens
        real, dimension(:), allocatable, intent(out) :: array

        call nc_check(nf90_open(fname, nf90_nowrite, ncid))
        call nc_check(nf90_inq_varid(ncid, varname, varid))
        call nc_check(nf90_inquire_variable(ncid, varid, dimids=dimids))

        call nc_check(nf90_inquire_dimension(ncid, dimids(1), len=dimlens(1)))

        allocate (array(dimlens(1)), stat=stat)
        if (stat /= 0) then
            write(unit=error_unit, fmt='(2A)') "Error allocating 1D array for variable ", varname
            stop ALLOCATION_ERR
        end if

        call nc_check(nf90_get_var(ncid, varid, array))

        call nc_check(nf90_close(ncid))
    end subroutine load_1D


    subroutine load_1D_int(fname, varname, array)
        implicit none

        character(len=*), intent(in) :: fname, varname

        integer :: ncid, varid
        integer :: stat
        integer, dimension(1) :: dimids, dimlens
        integer, dimension(:), allocatable, intent(out) :: array

        call nc_check(nf90_open(fname, nf90_nowrite, ncid))
        call nc_check(nf90_inq_varid(ncid, varname, varid))
        call nc_check(nf90_inquire_variable(ncid, varid, dimids=dimids))

        call nc_check(nf90_inquire_dimension(ncid, dimids(1), len=dimlens(1)))

        allocate (array(dimlens(1)), stat=stat)
        if (stat /= 0) then
            write(unit=error_unit, fmt='(2A)') "Error allocating 1D array for variable ", varname
            stop ALLOCATION_ERR
        end if

        call nc_check(nf90_get_var(ncid, varid, array))

        call nc_check(nf90_close(ncid))
    end subroutine load_1D_int
    


    subroutine load_2D(fname, varname, array)
        implicit none

        character(len=*), intent(in) :: fname, varname

        integer :: ncid, dimid, varid
        integer :: ndims
        integer :: i, stat
        integer, dimension(2) :: dimids, dimlens
        real, dimension(:,:), allocatable, intent(out) :: array

        call nc_check(nf90_open(fname, nf90_nowrite, ncid))
        call nc_check(nf90_inq_varid(ncid, varname, varid))
        call nc_check(nf90_inquire_variable(ncid, varid, ndims=ndims))
        call nc_check(nf90_inquire_variable(ncid, varid, dimids=dimids))

        do i=1,ndims
            dimid = dimids(i)
            call nc_check(nf90_inquire_dimension(ncid, dimid, len=dimlens(i)))
        end do

        allocate (array(dimlens(1),dimlens(2)), stat=stat)
        if (stat /= 0) then
            write(unit=error_unit, fmt='(2A)') "Error allocating 2D array for variable ", varname
            stop ALLOCATION_ERR
        end if

        call nc_check(nf90_get_var(ncid, varid, array))

        call nc_check(nf90_close(ncid))
    end subroutine load_2D


    subroutine load_2D_int(fname, varname, array)
        implicit none

        character(len=*), intent(in) :: fname, varname

        integer :: ncid, dimid, varid
        integer :: ndims
        integer :: i, stat
        integer, dimension(2) :: dimids, dimlens
        integer, dimension(:,:), allocatable, intent(out) :: array

        call nc_check(nf90_open(fname, nf90_nowrite, ncid))
        call nc_check(nf90_inq_varid(ncid, varname, varid))
        call nc_check(nf90_inquire_variable(ncid, varid, ndims=ndims))
        call nc_check(nf90_inquire_variable(ncid, varid, dimids=dimids))

        do i=1,ndims
            dimid = dimids(i)
            call nc_check(nf90_inquire_dimension(ncid, dimid, len=dimlens(i)))
        end do

        allocate (array(dimlens(1),dimlens(2)), stat=stat)
        if (stat /= 0) then
            write(unit=error_unit, fmt='(2A)') "Error allocating 2D array for variable ", varname
            stop ALLOCATION_ERR
        end if

        call nc_check(nf90_get_var(ncid, varid, array))

        call nc_check(nf90_close(ncid))
    end subroutine load_2D_int


    subroutine load_3D(fname, varname, array)
        implicit none

        character(len=*), intent(in) :: fname, varname

        integer :: ncid, dimid, varid
        integer :: ndims
        integer :: i, stat
        integer, dimension(3) :: dimids, dimlens
        real(kind=DP), dimension(:,:,:), allocatable, intent(out) :: array

        call nc_check(nf90_open(fname, nf90_nowrite, ncid))
        call nc_check(nf90_inq_varid(ncid, varname, varid))
        call nc_check(nf90_inquire_variable(ncid, varid, ndims=ndims))
        call nc_check(nf90_inquire_variable(ncid, varid, dimids=dimids))

        do i=1,ndims
            dimid = dimids(i)
            call nc_check(nf90_inquire_dimension(ncid, dimid, len=dimlens(i)))
        end do

        allocate (array(dimlens(1),dimlens(2),dimlens(3)), stat=stat)

        if (stat /= 0) then
            write(unit=error_unit, fmt='(2A)') "Error allocating 3D array for variable ", varname
            stop ALLOCATION_ERR
        end if

        call nc_check(nf90_get_var(ncid, varid, array))

        call nc_check(nf90_close(ncid))
    end subroutine load_3D


end module read_data_mod