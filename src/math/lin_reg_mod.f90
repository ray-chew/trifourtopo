module lin_reg_mod
    use :: topo_mod, only : topo_t
    use, intrinsic :: iso_fortran_env, only : error_unit
    use :: error_status, only : LINALG_ERR

    implicit none

    private

    public :: do_lin_reg

contains

    subroutine do_lin_reg(coeffs, topo_obj, mask)
        implicit none
        real, dimension(:,:), intent(in) :: coeffs
        type(topo_t), intent(inout) :: topo_obj
        real, dimension(size(coeffs,dim=1)) :: h_hat, Sol
        real, dimension(size(coeffs,dim=1),size(coeffs,dim=1)) :: M, Minv
        integer :: nc, nd, istat, nwork
        integer, dimension(size(coeffs,dim=1)) :: ipiv
        real, dimension(size(coeffs,dim=1)) :: work
        real, dimension(size(coeffs,dim=2)) :: z_recon

        logical, intent(in) :: mask(:,:)

        nc = size(coeffs,dim=1)
        nd = size(coeffs,dim=2)
        nwork = size(coeffs,dim=1)

        ! h_hat = matmul(coeffs, topo_obj%topo_tri)
        ! M = matmul(coeffs, transpose(coeffs))

        call dgemm('n','n', nc, 1, nd, 1.0, coeffs, nc, topo_obj%topo_tri, nd, 0.0, h_hat, nc)
        call dgemm('n','t', nc, nc, nd, 1.0, coeffs, nc, coeffs, nc, 0.0, M, nc)

        ! could just replace M...
        Minv = M

        call dgetrf(nc,nc,Minv,nc,ipiv,istat)

        if (istat /= 0) then
            write(unit=error_unit, fmt='(A128,I5)') adjustl(trim("Triangulation of matrix unsuccessful! Error code: ")), istat
            stop LINALG_ERR
        end if

        call dgetri(nc,Minv,nc,ipiv,work,nwork,istat)

        if (istat /= 0) then
            write(unit=error_unit, fmt='(A128,I5)') "Inversion of matrix unsuccessful! Error code: ", istat 
            stop LINALG_ERR
        end if

        ! Sol = matmul(Minv, h_hat)
        ! z_recon = matmul(transpose(coeffs), Sol)

        call dgemm('n','n', nc, 1, nc, 1.0, Minv, nc, h_hat, nc, 0.0, Sol, nc)
        call dgemm('t','n', nd, 1, nc, 1.0, coeffs, nc, Sol, nc, 0.0, z_recon, nd)

        call recon_2D(topo_obj, z_recon, mask)
    end subroutine

    subroutine recon_2D(topo_obj, z_recon, mask)
        implicit none
        type(topo_t), intent(inout) :: topo_obj
        real, intent(in) :: z_recon(:)
        logical, intent(in) :: mask(:,:)
        real, allocatable :: z_recon_2D(:,:)

        integer :: i, j, k

        allocate (z_recon_2D(size(topo_obj%lat),size(topo_obj%lon)))
        z_recon_2D = 0.0

        k = 1
        do j=1,size(mask,2)
            do i=1,size(mask,1)
                if (mask(i,j) .eqv. .true.) then
                    z_recon_2D(i,j) = z_recon(k)
                    k = k+1
                end if
            end do
        end do
        topo_obj%topo_recon_2D = z_recon_2D

        ! print *, shape(z_recon_2D)
    end subroutine recon_2D

end module lin_reg_mod