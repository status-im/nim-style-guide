#include <stdio.h>
#include <stdlib.h>

/* Import functions from Nim */
void* startNode(const char* url, void* user, void* callback);
void stopNode(void* ctx);

void callback(void* user, const void* data, size_t len) {
  printf("Callback! %lu\n", len);
}

int main(int argc, char** argv) {
  printf("Starting node\n");
  void* ctx = startNode("127.0.0.1:60000", 0, callback);
  printf("Node is listening on http://127.0.0.1:60000\nType `q` and press enter to stop\n");

  int stop = 0;
  while (getchar() != 'q');

  printf("Stopping node\n");

  stopNode(ctx);
}
