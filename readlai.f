! $Id: readlai.f,v 1.3 2004/12/02 21:48:39 bmy Exp $
      SUBROUTINE READLAI( MM )
!
!******************************************************************************
!  Subroutine READLAI reads the leaf area indices from disk for two months.
!  (yhw, gmg, djj, 1994; bmy, 7/20/04)
!
!  Arguments as Input:
!  ============================================================================
!  (1 ) MM (INTEGER) : Current month number (1-12)
!
!  NOTES:
!  (1 ) Be sure to force double precision with the DBLE function and the "D" 
!        exponent, wherever necessary (bmy, 10/6/99)             
!  (2 ) Now reads the LAI files directly from the data directory, so you don't
!        have to create symbolic links anymore (bmy, 7/5/01)           
!  (3 ) Deleted obsolete code (bmy, 9/4/01, 2/27/02)                        
!  (4 ) Replaced IMX with IGLOB and JMX with JGLOB (bmy, 6/25/02)
!  (5 ) Now reference IU_FILE from "file_mod.f" (bmy, 7/31/02)   
!  (6 ) Now define FILENAME and echo FILENAME to stdout.  Now use F90 style
!        declaration statements.  Cleaned up old code. (bmy, 11/13/02)
!  (7 ) Now references DATA_DIR from "directory_mod.f" (bmy, 7/20/04)
!******************************************************************************
!     
      ! References to F90 modules
      USE DIRECTORY_MOD, ONLY : DATA_DIR
      USE FILE_MOD,      ONLY : IU_FILE

      IMPLICIT NONE

#     include "CMN_SIZE"   ! Size parameters
#     include "CMN_DEP"    ! IREG, ILAND, IUSE
#     include "CMN_VEL"    ! XLAI, XLAI2

      ! Arguments
      INTEGER, INTENT(IN) :: MM
      
      ! Local variables
      INTEGER             :: I, INDEX, J, K, MMM
      CHARACTER(LEN=2)    :: CMONTH(12) = (/ '01','02','03','04',
     &                                       '05','06','07','08',
     &                                       '09','10','11','12'/)
      CHARACTER(LEN=255)  :: FILENAME

      !=================================================================
      ! READLAI begins here!
      !=================================================================

      ! Zero XLAI, XLAI2
      DO J = 1, JGLOB
      DO I = 1, IGLOB
      DO K = 1, IREG(I,J)
         XLAI(I,J,K)  = 0.D0
         XLAI2(I,J,K) = 0.D0
      ENDDO
      ENDDO
      ENDDO

      !=================================================================
      ! Read current month's lai (XLAI) at (I,J) and for landtype K
      !=================================================================

      ! File name
      FILENAME = TRIM( DATA_DIR ) // 'leaf_area_index_200202/lai' //
     &           CMONTH(MM)       // '.global'

      ! Echo filename
      WRITE( 6, 100 ) TRIM( FILENAME )
 100  FORMAT( '     - READLAI: Reading ', a )
      
      ! Open file
      OPEN( IU_FILE, FILE=TRIM( FILENAME ), STATUS='OLD' )

      ! Read until EOF
 10   READ( IU_FILE, '(3i3,20f5.1)', END=20 ) 
     &     I, J, INDEX, ( XLAI(I,J,K), K=1,INDEX )
      GOTO 10

      ! Close file
 20   CLOSE( IU_FILE )
      
      ! Save for next month
      MMM = MM
      IF(MMM .EQ. 12) MMM = 0

      !=================================================================
      ! Read following month's lai (XLAI2) at (I,J) and for landtype K 
      !=================================================================

      ! File name
      FILENAME = TRIM( DATA_DIR ) // 'leaf_area_index_200202/lai' //
     &           CMONTH(MMM+1)    // '.global'

      ! Echo filename
      WRITE( 6, 100 ) TRIM( FILENAME )

      ! Open file
      OPEN( IU_FILE, FILE=TRIM( FILENAME ), STATUS='OLD' )

      ! Read until EOF
 30   READ( IU_FILE, '(3i3,20f5.1)', END=40 ) 
     &     I, J, INDEX, ( XLAI2(I,J,K), K=1,INDEX )
      GOTO 30

      ! Close file
 40   CLOSE( IU_FILE )
      
      ! Return to calling program
      END SUBROUTINE READLAI
