# VASP-on-K-computer
Makefile and shell script for using VASP on K computer

## Note 
1. Makefile: compile VASP 5.3.5 on K-computer via Fujitsu Fortran Compiler (frtpx, mpifrtpx)
   Fujitsu Fortran Driver Version 1.2.0 P-id: L30000-14 (Nov 30 2016 13:50:48) K-1.2.0-22)

2. submit-vasp-job.sh: Job script file used to submit job
   usage: chmod +x submit-vasp-job.sh
          ksub submit-vasp-job.sh
          or
          pjsub submit-vasp-job.sh

   Before job submission, some lines need to be modified in submit-vasp-job.sh accordingly, e.g.
   
   #PJM --stgin "rank=*../../../bin/vasp535_std   %r:./"
   
   #PJM --mail-list "xxx@gmail.com"

3. checkjob.sh: a shell script file to check whether the VASP job is finished normally or not.
   usage: chmod +x checkjob.sh

4. getjobs.sh: a shell script file to check the job status and the correspoding work directories.
   usage: chmod +x  getjobs.sh
