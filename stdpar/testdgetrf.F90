program testdgetrf

  implicit none

  integer, parameter :: M = 1000, N = M, NRHS=2
  real(8), allocatable :: A(:,:), B(:,:), X(:,:)
  integer, allocatable :: IPIV(:)
  real(8), parameter :: eps = 1.0d-10
  real(8) :: rmx1, rmx2

  integer :: i, j, lda, ldb, info1, info2

  allocate(A(M,N), B(M,NRHS), X(M,NRHS), IPIV(M))

  call random_number(A)

  do concurrent (i = 1 : M)
     A(i,i) = A(i,i) * 10.0d0
     B(i,1) = sum(A(i,:))
     B(i,2) = B(i,1) * 2.0d0
  end do

  ! Factor and solve
  lda = M
  ldb = M

  call dgetrf(M, N, A, lda, IPIV, info1)
  call dgetrs('n', n, NRHS, A, lda, IPIV, B, ldb, info2)

  if ((info1 .ne. 0) .or. (info2 .ne. 0)) then
     print *, "Test FAILED", info1, info2
  else
     rmx1 = 0.0d0
     rmx2 = 0.0d0
     do concurrent (i = 1 : M) ! reduce(max:rmx1,rmx2)
        rmx1 = max(rmx1,abs(B(i,1) - 1.0d0))
        rmx2 = max(rmx2,abs(B(i,2) - 2.0d0))
        ! if (abs(B(i,1) - 1.0d0) .gt. rmx1) rmx1 = abs(B(i,1) - 1.0d0)
        ! if (abs(B(i,2) - 2.0d0) .gt. rmx2) rmx2 = abs(B(i,2) - 2.0d0)
     end do
     if ((rmx1 .gt. eps) .or. (rmx2 .gt. eps)) then
        print *,"Test FAILED"
     else
        print *,"Test PASSED"
     endif
  end if

end program testdgetrf
