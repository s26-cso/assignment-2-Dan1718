#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Node {
  int val;
  struct Node *left;
  struct Node *right;
};

struct Node *make_node(int val);
struct Node *insert(struct Node *root, int val);
struct Node *get(struct Node *root, int val);
int getAtMost(int val, struct Node *root);

int main(void) {
  struct Node *root = NULL;
  char command[32];
  int value;

  printf("Commands: make <x>, insert <x>, get <x>, atmost <x>, quit\n");

  while (scanf("%31s", command) == 1) {
    if (strcmp(command, "quit") == 0) {
      break;
    }

    if (strcmp(command, "make") == 0) {
      if (scanf("%d", &value) != 1) {
        return 1;
      }

      struct Node *node = make_node(value);
      if (node == NULL) {
        printf("NULL\n");
      } else {
        printf("node val=%d left=%p right=%p\n", node->val, (void *)node->left,
               (void *)node->right);
      }
      continue;
    }

    if (strcmp(command, "insert") == 0) {
      if (scanf("%d", &value) != 1) {
        return 1;
      }

      root = insert(root, value);
      if (root == NULL) {
        printf("root=NULL\n");
      } else {
        printf("root=%d\n", root->val);
      }
      continue;
    }

    if (strcmp(command, "get") == 0) {
      struct Node *found;

      if (scanf("%d", &value) != 1) {
        return 1;
      }

      found = get(root, value);
      if (found == NULL) {
        printf("NULL\n");
      } else {
        printf("%d\n", found->val);
      }
      continue;
    }

    if (strcmp(command, "atmost") == 0) {
      if (scanf("%d", &value) != 1) {
        return 1;
      }

      printf("%d\n", getAtMost(value, root));
      continue;
    }

    return 1;
  }

  return 0;
}
