#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

typedef int (*operation)(int, int);
int main() {
  char op[6];
  int num1, num2;
  while (1) {

    int e = scanf("%5s %d %d", op, &num1, &num2);
    if (e != 3) {
      break;
    }
    char lib_name[16] = "./lib";
    strcat(lib_name, op);
    char final[10] = ".so";
    strcat(lib_name, final);

    void *handler = dlopen(lib_name, RTLD_LAZY);
    operation function = (operation)dlsym(handler, op);

    printf("%d\n", function(num1, num2));
    dlclose(handler);
  }
  return 0;
}
