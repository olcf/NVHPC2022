program testdgetrf

  !@acc use cutensorex

  implicit none

  integer, parameter :: M = 1000, N = M, NRHS=2
  real(8), allocatable :: A(:,:), B(:,:), X(:,:),ASAVE(:,:)
  integer, allocatable :: IPIV(:)
  real(8), parameter :: eps = 1.0d-10
  real(8) :: rmx1, rmx2

  integer :: i, j, lda, ldb, info1, info2

  allocate(A(M,N),B(M,NRHS),X(M,NRHS),IPIV(M),ASAVE(M,N))

  call random_number(A)

  do concurrent (i = 1 : M)
     A(i,i) = A(i,i) * 10.0d0
     B(i,1) = sum(A(i,:))
     B(i,2) = B(i,1) * 2.0d0
  end do

  do concurrent (j = 1 : N, i = 1 : M)
     ASAVE(i,j) = A(i,j)
  end do

  ! Factor and solve
  lda = M
  ldb = M

  call dgetrf(M,N,A,lda,IPIV,info1)
  call dgetrs('n',n,NRHS,A,lda,IPIV,B,ldb,info2)

  if ((info1.ne.0) .or. (info2.ne.0)) then
     print *,"1st test FAILED", info1, info2
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
        print *,"1st test FAILED"
     else
        print *,"1st test PASSED"
     endif
  end if

  call random_number(B)

  do concurrent (j = 1 : NRHS, i = 1 : M)
     X(i,j) = B(i,j)
  end do

  ! call dgetrf(M,N,A,lda,IPIV,info1) ! No need to factor again
  call dgetrs('n',n,NRHS,A,lda,IPIV,X,ldb,info2)

  if ((info1.ne.0) .or. (info2.ne.0)) then
     print *,"2nd test FAILED", info1, info2
  else
     B = B - matmul(ASAVE,X)
     do j = 1, NRHS
#if defined USE_CUBLAS
        !@acc block; use cublas
        i = idamax(M, B(1,j), 1)
        rmx1 = abs(B(i,j))
        !@acc end block
#elif defined USE_DOCONCURRENT
        rmx1 = 0.0d0
        do concurrent (i = 1 : M) ! reduce(max:rmx1)
           rmx1 = max(rmx1,abs(B(i,j)))
        end do
#else
        rmx1 = 0.0d0
        do i = 1, M
           rmx1 = max(rmx1,abs(B(i,j)))
        end do
#endif
        if (rmx1 .gt. eps) then
           print *,"2nd test, column ",j," FAILED", rmx1
        else
           print *,"2nd test, column ",j," PASSED"
        endif
     end do
  endif

end program testdgetrf
