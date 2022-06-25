program main
    use read_data_mod
    use write_data_mod
    use utils_mod
    use topo_mod, only : topo_t, get_topo, dealloc_obj

    implicit none
    character(len=1024) :: fn_grid, fn_topo
    real, dimension(:), allocatable :: lat_center, lon_center
    real, dimension(:,:), allocatable :: lat_vert, lon_vert, topo_lat, topo_lon
    real, dimension(:,:,:), allocatable :: topo_dat
    real :: lat_ref, lon_ref
    real :: start, finish
    integer :: ncid, lat_dim_id, lon_dim_id, lat_var_id, lon_var_id, topo_var_id

    type(topo_t) :: topo_obj

    ! hard-coded index for test.
    integer, parameter :: ref_idx = 441 !13680 
    ! 441 corresponds to the topography around the Elbrus mountain

    print *, "Reading grid data..."

    call cpu_time(start)
    call get_fn(fn_grid, fn_topo)
    fn_grid = trim(fn_grid)
    fn_topo = trim(fn_topo)

    call read_data(fn_grid, "clat", lat_center)
    call read_data(fn_grid, "clon", lon_center)
    call read_data(fn_grid, "clat_vertices", lat_vert)
    call read_data(fn_grid, "clon_vertices", lon_vert)

    call rad_to_deg(lat_center)
    call rad_to_deg(lon_center)

    lat_ref = lat_center(ref_idx)
    lon_ref = lon_center(ref_idx)

    print *, "Reference (lat, lon): ", lat_ref, lon_ref

    print *, "Reading topo data..."
    call read_data(fn_topo, "lat", topo_lat)
    call read_data(fn_topo, "lon", topo_lon)
    call read_data(fn_topo, "topo", topo_dat)

    print *, "Read topo_lat with shape: ", shape(topo_lat)
    print *, "Read topo_lon with shape: ", shape(topo_lon)
    print *, "Read topo_dat with shape: ", shape(topo_dat)

    print *, "Gathering subpoints..."
    call get_topo(topo_lat, topo_lon, lat_ref, lon_ref, 2.0, topo_dat, topo_obj)
    call cpu_time(finish)
    print '("Time = ",f6.3," seconds.")',finish-start

    print *, "Writing data output..."
    ncid = create_dataset('output.nc')
    lat_dim_id = create_dim(ncid, 'nlat', size(topo_obj%lat))
    lon_dim_id = create_dim(ncid, 'nlon', size(topo_obj%lon))
    lat_var_id = write_data(ncid, 'lat', topo_obj%lat, (/lat_dim_id/))
    call write_attrs(ncid, lat_var_id, 'units', 'degrees')
    lon_var_id = write_data(ncid, 'lon', topo_obj%lon, (/lon_dim_id/))
    call write_attrs(ncid, lon_var_id, 'units', 'degrees')
    topo_var_id = write_data(ncid, 'topo', topo_obj%topo, (/lon_dim_id,lat_dim_id/))
    call write_attrs(ncid, topo_var_id, 'units', 'degrees')
    call close_dataset(ncid)

    call dealloc_all()
    call dealloc_obj(topo_obj)

contains

    subroutine dealloc_all()
    implicit none
        deallocate(lat_center)
        deallocate(lon_center)
        deallocate(lat_vert)
        deallocate(lon_vert)
    
        deallocate(topo_lat)
        deallocate(topo_lon)
        deallocate(topo_dat)
    end subroutine dealloc_all

end program main