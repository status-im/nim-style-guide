#include <stdio.h>
#include <stdlib.h>

/* Import functions from Nim */
void* startNode(const char* url, void (*onHeader)(void*, const char*, size_t), void* user);
void stopNode(void** ctx);

void onHeader(void* user, const char* headers, size_t len) {
  printf("Received headers! %lu\n", len);
  printf("%.*s\n\n", (int)len, headers);
}

int main(int argc, char** argv) {
  printf("Starting node\n");
  void* ctx = startNode("127.0.0.1:60000", onHeader, 0);
  printf("Node is listening on http://127.0.0.1:60000\nType `q` and press enter to stop\n");

  int stop = 0;
  while (getchar() != 'q');

  printf("Stopping node\n");

  stopNode(&ctx);
}
