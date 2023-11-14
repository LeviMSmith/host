#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <memory.h>

int host(const char* hostname, struct addrinfo** info) {
  struct addrinfo hints;

  memset(&hints, 0, sizeof hints); // make sure the struct is empty
  hints.ai_family = AF_UNSPEC;     // don't care IPv4 or IPv6
  hints.ai_socktype = SOCK_STREAM; // TCP stream sockets
  hints.ai_flags = AI_PASSIVE;

  int status = getaddrinfo(hostname, NULL, &hints, info);

  if (status != 0) {
    return status;
  }

  return 0;
}

void print_addrinfo(const struct addrinfo* const info) {
  void* addr;
  char ipstr[INET6_ADDRSTRLEN];

  if (info->ai_addr->sa_family == AF_INET) {
    struct sockaddr_in* ipv4 = (struct sockaddr_in*)info->ai_addr;
    addr = &ipv4->sin_addr;
  }
  else if (info->ai_addr->sa_family == AF_INET6) {
    struct sockaddr_in6* ipv6 = (struct sockaddr_in6*)info->ai_addr;
    addr = &ipv6->sin6_addr;
  }

  if (inet_ntop(info->ai_family, addr, ipstr, sizeof(ipstr)) != NULL) {
    printf("%s\n", ipstr);
  } 
  else {
    perror("inet_ntop");
  }

  if (info->ai_next != NULL) {
    print_addrinfo(info->ai_next);
  }
}

int main(int argc, char** argv) {
  if (argc != 2) {
    printf("Please give me a hostname to lookup!\n");
    printf("host [hostname]\n");
    return 1;
  }

  struct addrinfo* info;
  host(argv[1], &info);

  print_addrinfo(info);

  freeaddrinfo(info);

  return 0;
}

