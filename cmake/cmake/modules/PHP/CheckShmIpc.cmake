#[=============================================================================[
Check for sysvipc shared memory support.

The module sets the following variables if sysvipc support is found:

HAVE_SHM_IPC
  Set to 1 if SysV IPC SHM support is available.
]=============================================================================]#
include(CheckCSourceRuns)

message(STATUS "Checking for sysvipc shared memory support")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no (cross-compiling)")
else()
  check_c_source_runs("
    #include <sys/types.h>
    #include <sys/wait.h>
    #include <sys/ipc.h>
    #include <sys/shm.h>
    #include <unistd.h>
    #include <string.h>

    int main(void) {
      pid_t pid;
      int status;
      int ipc_id;
      char *shm;
      struct shmid_ds shmbuf;

      ipc_id = shmget(IPC_PRIVATE, 4096, (IPC_CREAT | SHM_R | SHM_W));
      if (ipc_id == -1) {
        return 1;
      }

      shm = shmat(ipc_id, NULL, 0);
      if (shm == (void *)-1) {
        shmctl(ipc_id, IPC_RMID, NULL);
        return 2;
      }

      if (shmctl(ipc_id, IPC_STAT, &shmbuf) != 0) {
        shmdt(shm);
        shmctl(ipc_id, IPC_RMID, NULL);
        return 3;
      }

      shmbuf.shm_perm.uid = getuid();
      shmbuf.shm_perm.gid = getgid();
      shmbuf.shm_perm.mode = 0600;

      if (shmctl(ipc_id, IPC_SET, &shmbuf) != 0) {
        shmdt(shm);
        shmctl(ipc_id, IPC_RMID, NULL);
        return 4;
      }

      shmctl(ipc_id, IPC_RMID, NULL);

      strcpy(shm, \"hello\");

      pid = fork();
      if (pid < 0) {
        return 5;
      } else if (pid == 0) {
        strcpy(shm, \"bye\");
        return 6;
      }
      if (wait(&status) != pid) {
        return 7;
      }
      if (!WIFEXITED(status) || WEXITSTATUS(status) != 6) {
        return 8;
      }
      if (strcmp(shm, \"bye\") != 0) {
        return 9;
      }
      return 0;
    }
  " HAVE_SHM_IPC)
endif()
