module fourier_mod
    use :: topo_mod, only : topo_t
    use :: utils_mod, only : get_N_unique
    use :: stdlib_sorting, only : ord_sort
    implicit none

    private
    integer, parameter ::   nhar_i = 15, &
                            nhar_j = 15
    real, parameter :: PI = acos(-1.0)

    public :: llgrid_t, set_triangle_verts, get_coeffs, points_in_triangle

    type :: llgrid_t
        real :: lat_res, lon_res
        real, dimension(3) :: vi, vj
    end type llgrid_t

contains

    subroutine set_triangle_verts(llgrid, vi, vj)
        real, dimension(3), intent(in):: vi, vj
        type(llgrid_t), intent(inout) :: llgrid

        llgrid%vi = vi
        llgrid%vj = vj
    end subroutine set_triangle_verts


    ! translated from Niraj's code
    elemental function points_in_triangle(i, j, ll_grid) result(mask)
        implicit none
        real, intent(in) :: i, j
        type(llgrid_t), intent(in) :: ll_grid
        real, dimension(3) :: tmp_vi, tmp_vj, ei, ej, p2ei, p2ej
        real :: r1, r2, r3
        logical :: mask

        associate (vi => ll_grid%vi, vj => ll_grid%vj)

        tmp_vi = (/vi(2), vi(3), vi(1)/)
        tmp_vj = (/vj(2), vj(3), vj(1)/)
        ei = tmp_vi - vi
        ej = tmp_vj - vj

        p2ei = vi - i
        p2ej = vj - j

        end associate

        r1 = cross_2D(ei(1), ej(1), p2ei(1), p2ej(1))
        r2 = cross_2D(ei(2), ej(2), p2ei(2), p2ej(2))
        r3 = cross_2D(ei(3), ej(3), p2ei(3), p2ej(3))
        
        if (r1 .gt. 0 .and. r2.gt. 0 .and. r3 .gt. 0) then
            mask = .true.
        else if (r1 .lt. 0 .and. r2 .lt. 0 .and. r3 .lt. 0) then
            mask = .true.
        else
            mask = .false.
        end if
    end function points_in_triangle


    pure function cross_2D(x1,x2,y1,y2) result(res)
        implicit none
        real, intent(in) :: x1, x2, y1, y2
        real :: res

        res = x1 * y2 - (y1 * x2)

    end function cross_2D


    subroutine get_coeffs(topo_obj, mask, coeffs)
        implicit none
        type(topo_t), intent(inout) :: topo_obj
        logical, dimension(:,:), intent(in) :: mask
        real, dimension(count(mask)) :: lat_tri, lon_tri, topo_tri
        integer, dimension(count(mask)) :: II, JJ, JJ_tmp
        real :: d_lat, d_lon
        integer :: Ni, Nj, i, j, k, l, N_cos, N_sin

        real, dimension(:), allocatable :: tmp
        real, dimension(:,:), allocatable :: coeffs

        ! we get lat, lon and topo in the triangle using the mask
        lat_tri = pack(topo_obj%lat_grid, mask=mask)
        lon_tri = pack(topo_obj%lon_grid, mask=mask)
        topo_tri = pack(topo_obj%topo, mask=mask)

        ! get grid spacing assuming equidistant grid.
        d_lat = topo_obj%lat(2) - topo_obj%lat(1)
        d_lon = topo_obj%lon(2) - topo_obj%lon(1)

        II = ceiling((lat_tri - minval(lat_tri)) / d_lat)
        JJ = ceiling((lon_tri - minval(lon_tri)) / d_lon)

        Ni = get_N_unique(II)
        JJ_tmp = JJ
        call ord_sort(JJ_tmp)
        Nj = get_N_unique(JJ_tmp)

        N_cos = nhar_i * nhar_j
        N_sin = nhar_i * nhar_j - 1

        allocate (tmp(N_cos))
        allocate (coeffs(N_cos + N_sin, size(topo_tri)))

        do k=1,size(topo_tri)
            l = 1
            do i=0,nhar_i-1
                do j=0,nhar_j-1
                    tmp(l) = 2.0 * PI * (i*II(k)/real(Ni) + j*JJ(k)/real(Nj))
                    l = l + 1
                end do
            end do
            coeffs(1:N_cos,k) = cos(tmp)
            coeffs(N_cos+1:N_cos+N_sin,k) = sin(tmp(2:size(tmp)))
        end do

        topo_obj%lat_tri = lat_tri
        topo_obj%lon_tri = lon_tri
        topo_obj%topo_tri = topo_tri

    end subroutine get_coeffs

    ! elemental function cos_all(x) result(y)
    !     implicit none
    !     real, intent(in) :: x
    !     real :: y
    !     y = cos(x)
    ! end function cos_all

    ! elemental function sin_all(x) result (y)
    !     implicit none
    !     real, intent(in) :: x
    !     real :: y
    !     y = sin(x)
    ! end function sin_all

end module fourier_mod