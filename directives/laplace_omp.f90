program laplace

  implicit none

  interface same
    logical function samer4(a, b, error)
    real(4) a, b, error
    end function
    logical function samer8(a, b, error)
    real(8) a, b, error
    end function
  end interface

  integer, parameter :: fp_kind=kind(1.0)  ! Change to 1.0d0 for DP
  integer, parameter :: n=512, m=512, iter_max=1000
  integer :: i, j, iter
  real(fp_kind), dimension (:,:), allocatable :: A, Anew
  real(fp_kind), dimension (:),   allocatable :: y0
  real(fp_kind), parameter :: pi=2.0_fp_kind*asin(1.0_fp_kind)
  real(fp_kind), parameter :: tol1=1.0e-5_fp_kind
  real(fp_kind), parameter :: tol2=1.0e-3_fp_kind
  real(fp_kind) :: error=1.0_fp_kind

  allocate ( A(0:n-1,0:m-1), Anew(0:n-1,0:m-1) )
  allocate ( y0(0:m-1) )

  A = 0.0_fp_kind
  Anew = 0.0_fp_kind

  !$omp target data map(tofrom:A) map(to:Anew)

  ! Set B.C.
  !$omp target teams loop
  do i=0,m-1
    y0(i) = sin(pi* real(i) /(m-1))
    A(i,0)   = y0(i)
    A(i,m-1) = y0(i)*exp(-pi)
  end do

  write(*,'(a,i5,a,i5,a)') 'Jacobi relaxation Calculation:', n, ' x', m, ' mesh'
  iter=0

  !$omp target teams loop
  do i=1,n-1
    Anew(i,0)   = y0(i)
    Anew(i,m-1) = y0(i)*exp(-pi)
  end do

  do while ( error .gt. tol1 .and. iter .lt. iter_max )

    error=0.0_fp_kind

    !$omp target teams loop collapse(2) reduction(max:error)
    do j=1,m-2
      do i=1,n-2
        Anew(i,j) = 0.25_fp_kind * ( A(i+1,j  ) + A(i-1,j  ) + &
                                     A(i  ,j-1) + A(i  ,j+1) )
        error = max( error, abs(Anew(i,j)-A(i,j)) )
      end do
    end do

    if(mod(iter,100).eq.0 ) write(*,'(i5,f10.6)'), iter, error
    iter = iter +1

    !$omp target teams loop collapse(2)
    do j=0,m-1
      do i=0,n-1
        A(i,j) = Anew(i,j)
      end do
    end do

  end do

  !$omp end target data
  
  print *, "Final error, iter: ", error, iter
  if (same(error, 0.0002397_fp_kind, tol2)) then
     print *, " PASS "
  else
     print *, " FAIL "
  end if

  deallocate (A,Anew,y0)

end program laplace

logical function samer4(a, b, error)

  implicit none

  real(4) a, b, error, x

  if (a .eq. 0.0) then
     x = b
  else if (b .eq. 0.0) then
     x = a
  else
     x = (a - b) / a
  end if

  samer4 = abs(x) .lt. error

end function samer4

logical function samer8(a, b, error)

  implicit none

  real(8) a, b, error, x

  if (a .eq. 0.0d0) then
     x = b
  else if (b .eq. 0.0d0) then
     x = a
  else
     x = (a - b) / a
  end if

  samer8 = abs(x) .lt. error

end function samer8
